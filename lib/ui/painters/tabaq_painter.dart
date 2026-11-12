import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';

class TabaqPainter extends CustomPainter {
  final bool showYalla;
  TabaqPainter({this.showYalla = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center + const Offset(3, 5), radius, Paint()..color = SudaneseTheme.earthBlack.withOpacity(0.45));
    canvas.drawCircle(center, radius, Paint()..color = SudaneseTheme.straw);
    canvas.drawCircle(center, radius - 1.5, Paint()..color = SudaneseTheme.earthBlack..style = PaintingStyle.stroke..strokeWidth = 3);

    _drawDashedRing(canvas, center, radius * 0.84, SudaneseTheme.tabaqRed, 5.0, 24);
    _drawDashedRing(canvas, center, radius * 0.70, SudaneseTheme.palmGreen, 5.0, 20);
    _drawDashedRing(canvas, center, radius * 0.56, SudaneseTheme.dateOrange, 4.0, 16);

    if (showYalla) {
      canvas.drawCircle(center, radius * 0.44, Paint()..color = SudaneseTheme.tabaqRed);
      canvas.drawCircle(center, radius * 0.44, Paint()..color = SudaneseTheme.sunGold..style = PaintingStyle.stroke..strokeWidth = 2);
    } else {
      final wedgePaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < 16; i++) {
        wedgePaint.color = i % 2 == 0 ? SudaneseTheme.tabaqRed : SudaneseTheme.hibiscusMagenta;
        double a1 = (i * 2 * pi) / 16, a2 = ((i + 1) * 2 * pi) / 16;
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(center.dx + cos(a1) * radius * 0.42, center.dy + sin(a1) * radius * 0.42)
          ..lineTo(center.dx + cos(a2) * radius * 0.42, center.dy + sin(a2) * radius * 0.42)
          ..close();
        canvas.drawPath(path, wedgePaint);
      }
      canvas.drawCircle(center, radius * 0.14, Paint()..color = SudaneseTheme.sunGold);
    }
  }

  void _drawDashedRing(Canvas canvas, Offset center, double r, Color color, double stroke, int count) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = stroke;
    double sweep = (2 * pi) / count;
    for (int i = 0; i < count; i++) {
      if (i % 2 == 0) canvas.drawArc(Rect.fromCircle(center: center, radius: r), i * sweep, sweep * 0.75, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TabaqPainter oldDelegate) => oldDelegate.showYalla != showYalla;
}
