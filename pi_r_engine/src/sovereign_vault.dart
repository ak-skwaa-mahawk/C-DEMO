// Example usage inside SovereignVault or any screen
Future<void> exampleRustCall() async {
  final signal = 1.864; // example incoming value

  // Microsecond Rust call
  final tuned = RustPiREngine.selfTune(signal);
  print("Rust π_r self-tune result: $tuned");

  final latency = RustPiREngine.getAverageLatencyUs();
  print("Rust latency: ${latency.toStringAsFixed(2)} µs");

  // Extraction Guard
  if (RustPiREngine.guardNeutralization(signal)) {
    final bloom = RustPiREngine.triggerBloom();
    print("Extraction Guard triggered — Bloom re-established: $bloom");
  }
}