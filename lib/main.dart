// main.dart — Sovereign Aim Bot with Real Camera + IMU (Phone = Floor Client)
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';      // real camera
import 'package:sensors_plus/sensors_plus.dart'; // real IMU (accelerometer + gyroscope)
import 'dart:async';
import 'sovereign_vault.dart'; // your SovereignVault.dart

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
  CameraController? _cameraController;
  double stability = 0.0;
  double vitality = 0.0;
  bool isMeshNode = false;

  StreamSubscription? _accelSubscription;
  StreamSubscription? _gyroSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startIMUSensors();
    // Start continuous Floor-owned processing
    Future.delayed(Duration.zero, _processFrame);
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  void _startIMUSensors() {
    // Real IMU data is captured but only derived metrics are used
    _accelSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      // Example: use tilt for stability calculation inside Vault
      sovereignVault.storeState({
        "accel_x": event.x,
        "accel_y": event.y,
        "accel_z": event.z,
      }, purpose: "imu");
    });

    _gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      sovereignVault.storeState({
        "gyro_x": event.x,
        "gyro_y": event.y,
        "gyro_z": event.z,
      }, purpose: "gyro");
    });
  }

  Future<void> _processFrame() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      Future.delayed(const Duration(milliseconds: 100), _processFrame);
      return;
    }

    // Capture frame (raw data never leaves Vault)
    final image = await _cameraController!.takePicture();
    final rawState = {
      "image_path": image.path, // in production: process bytes in enclave
      "timestamp": DateTime.now().millisecondsSinceEpoch / 1000,
    };
    await sovereignVault.storeState(rawState, purpose: "vision_target");

    // Vault computes derived metrics only
    final metric = await sovereignVault.computeMetric("aim_lock_stability");

    setState(() {
      stability = metric["stability_score"] ?? 0.0;
      vitality = 0.87; // simulated from contour size in real impl
    });

    // Repeat
    Future.delayed(const Duration(milliseconds: 200), _processFrame);
  }

  void _enableMeshNode() async {
    await sovereignVault.enableMeshNodeMode();
    setState(() => isMeshNode = true);
    sovereignVault.runAsNode();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _accelSubscription?.cancel();
    _gyroSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sovereign Aim Bot — Floor Client")),
      body: Column(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Expanded(
              child: CameraPreview(_cameraController!),
            )
          else
            const Expanded(child: Center(child: CircularProgressIndicator())),

          Padding(
            padding: const EdgeInsets.all(16.0),
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
                const Text("All raw camera + IMU data owned by Ch’anchyah Vault\n"
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