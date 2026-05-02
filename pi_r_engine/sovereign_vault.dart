// Add to SovereignVault class
final dynamic _piREngine = DynamicLibrary.open("pi_r_engine.so").lookupFunction<
    Double Function(Double), double Function(double)>("pi_r_self_tune");

Future<double> computePiRFromRust(double signal) async {
  return _piREngine(signal);
}