import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';

class LanternPainter extends CustomPainter {
  final bool isLit;
  LanternPainter({this.isLit = true});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2, cy = size.height / 2;
    if (isLit) canvas.drawCircle(Offset(cx, cy), size.width * 0.48, Paint()..color = SudaneseTheme.sunGold.withOpacity(0.35));
    final framePaint = Paint()..color = SudaneseTheme.earthBlack..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final glassRect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 2), width: size.width * 0.45, height: size.height * 0.52), const Radius.circular(6));
    canvas.drawRRect(glassRect, Paint()..color = isLit ? SudaneseTheme.sunGold : SudaneseTheme.mudBrickDark.withOpacity(0.5));
    canvas.drawRRect(glassRect, framePaint);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy - size.height * 0.24), width: size.width * 0.5, height: 14), 3.14, 3.14, true, Paint()..color = SudaneseTheme.earthBlack);
    canvas.drawCircle(Offset(cx, cy - size.height * 0.36), 4, framePaint);
  }

  @override
  bool shouldRepaint(covariant LanternPainter oldDelegate) => oldDelegate.isLit != isLit;
}
