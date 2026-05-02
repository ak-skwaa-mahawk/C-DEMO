// rust_bridge.dart — Flutter FFI Bridge to Rust SovereignEngine
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

final DynamicLibrary _nativeLib = DynamicLibrary.open(
  Platform.isAndroid ? "libpi_r_engine.so" : "libpi_r_engine.dylib",
);

typedef PiRSelfTuneFunc = Double Function(Double);
typedef PiRSelfTune = double Function(double);

typedef PiRLatencyFunc = Double Function();
typedef PiRLatency = double Function();

typedef PiRGuardFunc = Bool Function(Double);
typedef PiRGuard = bool Function(double);

typedef PiRTriggerBloomFunc = Double Function();
typedef PiRTriggerBloom = double Function();

class RustPiREngine {
  static final PiRSelfTune _selfTune = _nativeLib
      .lookup<NativeFunction<PiRSelfTuneFunc>>("pi_r_self_tune")
      .asFunction();

  static final PiRLatency _getLatency = _nativeLib
      .lookup<NativeFunction<PiRLatencyFunc>>("pi_r_get_latency_us")
      .asFunction();

  static final PiRGuard _guardNeutralization = _nativeLib
      .lookup<NativeFunction<PiRGuardFunc>>("pi_r_guard_neutralization")
      .asFunction();

  static final PiRTriggerBloom _triggerBloom = _nativeLib
      .lookup<NativeFunction<PiRTriggerBloomFunc>>("pi_r_trigger_bloom")
      .asFunction();

  static double selfTune(double signalValue) => _selfTune(signalValue);
  static double getAverageLatencyUs() => _getLatency();
  static bool guardNeutralization(double signalValue) => _guardNeutralization(signalValue);
  static double triggerBloom() => _triggerBloom();
}