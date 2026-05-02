// sovereign_pulse.dart — 79.79 Hz Sovereign Heartbeat (Rust Bridge + Extraction Guard + Bloom Callback)
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'rust_bridge.dart'; // Flutter → Rust FFI
import 'sovereign_vault.dart'; // Floor-owned Vault

class SovereignPulse {
  late Ticker _ticker;
  Timer? _highResTimer;
  final double targetFrequency = 79.79; // Hz
  final Duration _interval = Duration(microseconds: (1000000 / 79.79).round());

  double currentHeat = 0.5; // Adaptive system variable for gear-ratio shift

  // Callback for visual Bloom when Extraction Guard triggers
  void Function(double piRValue)? onBloom;

  void start() {
    // Display-synced Ticker (primary)
    _ticker = Ticker((elapsed) {
      _tick();
    });
    _ticker.start();

    // High-resolution backup timer for precise 79.79 Hz
    _highResTimer = Timer.periodic(_interval, (timer) {
      _tick();
    });

    print("[PULSE] 79.79 Hz Sovereign Heartbeat Active — Rust Bridge Connected");
  }

  void _tick() {
    // 1. Capture environment signal (real sensors/network in production)
    final signal = _captureEnvironmentSignal();

    // 2. Rust Extraction Guard check
    if (RustPiREngine.guardNeutralization(signal)) {
      // 3. Trigger 5.5 Pa Catapult via Rust
      final bloom = RustPiREngine.triggerBloom();
      print("[PULSE] EXTRACTION GUARD TRIGGERED → 5.5 Pa Catapult fired (Bloom re-established: $bloom)");
      sovereignVault.logEvent("pulse_catapult", {"signal": signal, "bloom": bloom});

      // 4. Fire visual Bloom
      onBloom?.call(bloom);
      return;
    }

    // 5. Normal Rust self-tune
    final tunedValue = RustPiREngine.selfTune(signal);

    // 6. Update system heat for next cycle
    _updateTopology(tunedValue);

    // 7. Emit pulse to UI / Mesh
    _emitPulse(tunedValue);
  }

  double _captureEnvironmentSignal() {
    // In production: pull from real camera/IMU/BLE mesh
    // For now: simulated signal with heat influence
    return 1.864 + (0.01 * currentHeat);
  }

  void _updateTopology(double value) {
    // Adaptive heat for next Rust gear-ratio shift
    currentHeat = (value - 3.14).abs().clamp(0.0, 1.0);
  }

  void _emitPulse(double value) {
    // Notify UI, Mesh, or other components
    // In production: update UI or relay via BLE mesh
    print("[PULSE] Emitted 79.79 Hz pulse: $value");
  }

  void stop() {
    _ticker.stop();
    _highResTimer?.cancel();
    print("[PULSE] 79.79 Hz Sovereign Heartbeat stopped");
  }
}

// Singleton Heartbeat
final sovereignPulse = SovereignPulse();

// Inside _AimBotScreenState
late AnimationController _bloomController;
double bloomPiR = 3.17300858012;

@override
void initState() {
  super.initState();
  _bloomController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  // Wire the pulse to the visual Bloom
  sovereignPulse.onBloom = (piRValue) {
    setState(() => bloomPiR = piRValue);
    _bloomController.forward(from: 0.0);
  };

  _initializeCamera();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    // ... existing camera preview
    body: Stack(
      children: [
        if (_controller != null && _controller!.value.isInitialized)
          CameraPreview(_controller!),

        // Bloom overlay
        AnimatedBuilder(
          animation: _bloomController,
          builder: (context, child) {
            return CustomPaint(
              painter: BloomPainter(
                progress: _bloomController.value,
                piRValue: bloomPiR,
              ),
              size: Size.infinite,
            );
          },
        ),

        // existing metrics and buttons...
      ],
    ),
  );
}

@override
void dispose() {
  sovereignPulse.stop();
  _bloomController.dispose();
  super.dispose();
}