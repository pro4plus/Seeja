// رسّام جدار الألواح الخشبية: ألواح عمودية بعروق وأخاديد،
// تُستخدم كخلفية لشاشة الإعداد (كما في المرجع).
import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlankWallPainter extends CustomPainter {
  const PlankWallPainter({this.seed = 7});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    // ألواح بعرض متفاوت وألوان قريبة.
    const tones = [
      Color(0xFF96754F),
      Color(0xFF8A6A47),
      Color(0xFF9A7952),
      Color(0xFF80603F),
      Color(0xFF8E6E4A),
    ];

    var x = 0.0;
    while (x < size.width) {
      final w = 26.0 + rng.nextDouble() * 16;
      final tone = tones[rng.nextInt(tones.length)];
      canvas.drawRect(
        Rect.fromLTWH(x, 0, w, size.height),
        Paint()..color = tone,
      );
      // أخاديد.
      canvas.drawRect(
        Rect.fromLTWH(x + w - 3, 0, 3, size.height),
        Paint()..color = const Color(0xFF5E432A).withValues(alpha: 0.85),
      );
      // خط فاتح على حافة اللوح.
      canvas.drawRect(
        Rect.fromLTWH(x + 2, 0, 2, size.height),
        Paint()..color = const Color(0xFFA9855C).withValues(alpha: 0.55),
      );
      // عرق الخشب.
      if (rng.nextDouble() > 0.45) {
        final gx = x + 8 + rng.nextDouble() * (w - 16);
        final path = Path()
          ..moveTo(gx, 0)
          ..cubicTo(
            gx + 4, size.height * 0.3,
            gx - 4, size.height * 0.7,
            gx + 2, size.height,
          );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF6E5233).withValues(alpha: 0.30)
            ..strokeWidth = 1.6
            ..style = PaintingStyle.stroke,
        );
      }
      x += w;
    }
  }

  @override
  bool shouldRepaint(covariant PlankWallPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
