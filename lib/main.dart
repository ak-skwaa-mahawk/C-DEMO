// main.dart — Sovereign Aim Bot with Kalman Filter Tracking
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:typed_data';
import 'sovereign_vault.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const SovereignAimBotApp());
}

class SovereignAimBotApp extends StatelessWidget {
  const SovereignAimBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sovereign Aim Bot — Floor Client',
      theme: ThemeData.dark(),
      home: const AimBotScreen(),
    );
  }
}

class AimBotScreen extends StatefulWidget {
  const AimBotScreen({super.key});

  @override
  State<AimBotScreen> createState() => _AimBotScreenState();
}

class _AimBotScreenState extends State<AimBotScreen> {
  CameraController? _controller;
  double stability = 0.0;
  double vitality = 0.0;
  bool isMeshNode = false;

  // === KALMAN FILTER (Floor-owned smoothing) ===
  final KalmanFilter _kalman = KalmanFilter();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
    await _controller!.startImageStream(_processCameraImage);
  }

  // === ADVANCED CONTOUR + KALMAN TRACKING ===
  void _processCameraImage(CameraImage image) async {
    // Raw frame owned by the Floor
    await sovereignVault.storeState({
      "width": image.width,
      "height": image.height,
      "timestamp": DateTime.now().millisecondsSinceEpoch / 1000,
    }, purpose: "vision_target");

    // Convert to RGB
    final rgbImage = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: Uint8List.fromList(image.planes[0].bytes),
      format: img.Format.uint8,
    );

    // Contour collection (adaptive red detection)
    List<int> contourX = [];
    List<int> contourY = [];

    const blockSize = 4;
    for (int y = 0; y < rgbImage.height; y += blockSize) {
      for (int x = 0; x < rgbImage.width; x += blockSize) {
        final pixel = rgbImage.getPixel(x, y);
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);

        if ((r > 100 && g < 80 && b < 80) || (r > 170 && g < 60 && b < 60)) {
          contourX.add(x);
          contourY.add(y);
        }
      }
    }

    if (contourX.length > 40) {
      double sumX = 0, sumY = 0;
      for (int i = 0; i < contourX.length; i++) {
        sumX += contourX[i];
        sumY += contourY[i];
      }
      final measuredX = sumX / contourX.length;
      final measuredY = sumY / contourY.length;
      final area = contourX.length.toDouble();
      final radius = (area / 3.14).sqrt();

      // === KALMAN FILTER: Smooth measurement ===
      _kalman.update(measuredX, measuredY);

      final filteredX = _kalman.x;
      final filteredY = _kalman.y;

      final derivedState = {
        "center_x": filteredX,
        "center_y": filteredY,
        "radius": radius,
        "contour_points": contourX.length,
      };

      await sovereignVault.storeState(derivedState, purpose: "vision_target");

      final metric = await sovereignVault.computeMetric("aim_lock_stability");
      final derivedVitality = (radius / 150).clamp(0.0, 1.0);

      setState(() {
        stability = metric["stability_score"] ?? 0.0;
        vitality = derivedVitality;
      });
    }
  }

  void _enableMeshNode() async {
    await sovereignVault.enableMeshNodeMode();
    setState(() => isMeshNode = true);
    sovereignVault.runAsNode();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sovereign Aim Bot — Floor Client")),
      body: Column(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            Expanded(child: CameraPreview(_controller!))
          else
            const Expanded(child: Center(child: CircularProgressIndicator())),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text("Vitality: ${vitality.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 24, color: Colors.green)),
                Text("Stability: ${stability.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 24, color: Colors.cyan)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _enableMeshNode,
                  child: Text(isMeshNode ? "Mesh Node ACTIVE" : "Enable Floor Mesh Node Mode"),
                ),
                const SizedBox(height: 10),
                const Text("Kalman Filter tracking + real camera owned by Ch’anchyah Vault\n"
                    "Only derived metrics used for control + mesh relay",
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// === 2D KALMAN FILTER (Floor-owned smoothing) ===
class KalmanFilter {
  double x = 0, y = 0;      // position
  double vx = 0, vy = 0;    // velocity
  double P = 1.0;           // covariance (simplified scalar for phone speed)

  void update(double measuredX, double measuredY) {
    // Simple constant-velocity Kalman update
    const dt = 0.033; // \~30 fps
    const q = 0.01;   // process noise
    const r = 0.5;    // measurement noise

    // Predict
    x += vx * dt;
    y += vy * dt;
    P += q;

    // Update
    final k = P / (P + r); // Kalman gain
    vx = vx + k * (measuredX - x);
    vy = vy + k * (measuredY - y);
    x = x + k * (measuredX - x);
    y = y + k * (measuredY - y);
    P = (1 - k) * P;
  }
}