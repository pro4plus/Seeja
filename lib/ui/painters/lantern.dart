// رسّام الفانوس: فانوس معدني بمقبض وغطاء وجسم زجاجي وقضبان
// وقاعدة. مضيء: هالة دافئة وزجاج ذهبي وشعلة. مطفأ: زجاج غامق.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class LanternPainter extends CustomPainter {
  final bool lit;

  /// طور الوميض من 0 إلى 1، مرتبط بحركة الشخصية المحيطة.
  final double flicker;

  const LanternPainter({required this.lit, this.flicker = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    if (lit) {
      // هالة دافئة: حلقات متحدة المركز خافتة.
      final pulse = 0.9 + 0.1 * math.sin(flicker * math.pi * 2);
      for (final (r, a) in [
        (0.62, 0.10),
        (0.50, 0.13),
        (0.38, 0.18),
      ]) {
        canvas.drawCircle(
          Offset(cx, h * 0.52),
          w * r * pulse,
          Paint()..color = SudaneseTheme.sunGold.withValues(alpha: a * pulse),
        );
      }
    }

    final frame = Paint()..color = const Color(0xFF3A2418);

    // مقبض.
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, h * 0.17), width: w * 0.34, height: h * 0.22),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF3A2418)
        ..strokeWidth = w * 0.075
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // الغطاء.
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * 0.26, h * 0.27)
        ..lineTo(cx + w * 0.26, h * 0.27)
        ..lineTo(cx + w * 0.13, h * 0.15)
        ..lineTo(cx - w * 0.13, h * 0.15)
        ..close(),
      frame,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.16, h * 0.24, w * 0.32, h * 0.05),
      Paint()..color = const Color(0xFF4E3120),
    );

    // جسم الزجاج.
    final glass = Path()
      ..moveTo(cx - w * 0.28, h * 0.32)
      ..lineTo(cx + w * 0.28, h * 0.32)
      ..lineTo(cx + w * 0.22, h * 0.76)
      ..lineTo(cx - w * 0.22, h * 0.76)
      ..close();
    if (lit) {
      canvas.drawPath(
        glass,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0B8), Color(0xFFF7C64A), Color(0xFFE39A1E)],
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
      canvas.drawCircle(
        Offset(cx, h * 0.52),
        w * 0.09,
        Paint()..color = const Color(0xFFFFE9A8),
      );
    } else {
      canvas.drawPath(glass, Paint()..color = const Color(0xFF4A423C));
    }

    // قضبان الجسم.
    final bar = Paint()
      ..color = const Color(0xFF3A2418)
      ..strokeWidth = w * 0.045;
    canvas.drawLine(Offset(cx, h * 0.32), Offset(cx, h * 0.76), bar);
    canvas.drawLine(
        Offset(cx - w * 0.20, h * 0.36), Offset(cx - w * 0.16, h * 0.72),
        bar..strokeWidth = w * 0.03);
    canvas.drawLine(
        Offset(cx + w * 0.20, h * 0.36), Offset(cx + w * 0.16, h * 0.72),
        bar..strokeWidth = w * 0.03);

    // إطار أعلى وأسفل.
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.30, h * 0.29, w * 0.60, h * 0.05),
      frame,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.24, h * 0.74, w * 0.48, h * 0.05),
      frame,
    );

    // القاعدة.
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.24, h * 0.78, w * 0.48, h * 0.08),
      Paint()..color = const Color(0xFF3A2418),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.29, h * 0.86, w * 0.58, h * 0.07),
      Paint()..color = const Color(0xFF4E3120),
    );

    // اللهب فوق الغطاء عند الإضاءة.
    if (lit) {
      final flameHeight = h * 0.05 + h * 0.012 * math.sin(flicker * math.pi * 2);
      canvas.drawPath(
        Path()
          ..moveTo(cx, h * 0.05)
          ..quadraticBezierTo(
              cx - w * 0.07, h * 0.10, cx, h * 0.05 + flameHeight)
          ..quadraticBezierTo(
              cx + w * 0.07, h * 0.10, cx, h * 0.05)
          ..close(),
        Paint()..color = const Color(0xFFFFD87A),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LanternPainter oldDelegate) =>
      oldDelegate.lit != lit || oldDelegate.flicker != flicker;
}
