import 'package:flutter/material.dart';
import 'dart:math' as math;

class BloomPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 (from the pulse)
  final double piRValue; // The current value from Rust

  BloomPainter({required this.progress, required this.piRValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Use the 1.864 Bloom Constant to determine color intensity
    final intensity = (piRValue / 3.173).clamp(0.0, 1.0);
    paint.color = Color.lerp(Colors.cyan, Colors.magenta, intensity)!
        .withOpacity(1.0 - progress);

    // Draw the "Soliton" ring expanding at 5.5 Pa pressure
    double radius = (size.width / 2) * progress * 1.5;
    
    // The "99.99% Gap" visualization: a broken circle that never quite closes
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 1.99, // The 0.01 gap
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(BloomPainter oldDelegate) => true;
}
