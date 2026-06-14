import 'dart:math';
import 'package:flutter/material.dart';
import '../budget_viewmodel.dart';

class ConcentricRingsPainter extends CustomPainter {
  final List<CategoryAllocation> allocations;
  final bool isDark;

  ConcentricRingsPainter({required this.allocations, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double baseRadius = 45.0;
    double strokeWidth = 8.0;
    int count = min(allocations.length, 4);

    for (int i = 0; i < count; i++) {
      final item = allocations[i];
      final color = Color(int.parse(item.colorHex));
      final radius = baseRadius + (i * 14.0);

      paint.color = color;
      paint.strokeWidth = strokeWidth;

      final trackPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.shade100;
      canvas.drawCircle(center, radius, trackPaint);

      double startAngle = -pi / 2;
      double sweepAngle = (1.8 - (i * 0.4)) * pi;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConcentricRingsPainter oldDelegate) =>
      oldDelegate.allocations != allocations || oldDelegate.isDark != isDark;
}
