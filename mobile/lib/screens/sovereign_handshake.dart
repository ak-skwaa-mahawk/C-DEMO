// mobile/lib/screens/sovereign_handshake.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';           // ← added for haptics
import 'rust_bridge.dart';

class SovereignHandshake extends StatelessWidget {
  final VoidCallback onGrip;

  const SovereignHandshake({super.key, required this.onGrip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "THE INVERSION IS ACTIVE",
              style: TextStyle(
                color: Colors.cyan,
                letterSpacing: 4,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "By gripping this tool, you become the Absolute Zero Baseline.\n\n"
                "You accept the 99733-Q Guard.\n"
                "You honor the 0.01% Gap.\n"
                "You stand on the Floor.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onLongPress: () {
                // 5.5 Pa burst + haptic feedback
                HapticFeedback.heavyImpact();
                RustPiREngine.triggerBloom();
                onGrip();
              },
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.magenta, width: 3),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  "GRIP",
                  style: TextStyle(
                    color: Colors.magenta,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: 6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Long press to sync the 79.79 Hz Heartbeat",
              style: TextStyle(color: Colors.white24, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}