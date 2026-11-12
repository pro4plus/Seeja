import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';

class WallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFF7F1E3));

    final brickPaint = Paint()..color = SudaneseTheme.straw.withOpacity(0.28);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(24, 90, 44, 18), const Radius.circular(3)), brickPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 72, 75, 48, 18), const Radius.circular(3)), brickPaint);

    double doorW = size.width * 0.46, doorH = size.height * 0.46;
    double left = (size.width - doorW) / 2, top = size.height * 0.21;

    final archPath = Path()
      ..moveTo(left, top + doorH)
      ..lineTo(left, top + doorW / 2)
      ..arcToPoint(Offset(left + doorW, top + doorW / 2), radius: Radius.circular(doorW / 2))
      ..lineTo(left + doorW, top + doorH)
      ..close();

    canvas.save();
    canvas.clipPath(archPath);
    canvas.drawRect(Rect.fromLTWH(left, top, doorW, doorH * 0.55), Paint()..color = SudaneseTheme.dateOrange);
    canvas.drawRect(Rect.fromLTWH(left, top, doorW, doorH * 0.28), Paint()..color = SudaneseTheme.hibiscusMagenta.withOpacity(0.65));
    canvas.drawCircle(Offset(left + doorW * 0.35, top + doorH * 0.32), doorW * 0.14, Paint()..color = SudaneseTheme.tabaqRed);

    final p1 = Path()
      ..moveTo(left + doorW * 0.05, top + doorH * 0.62)
      ..lineTo(left + doorW * 0.28, top + doorH * 0.34)
      ..lineTo(left + doorW * 0.50, top + doorH * 0.62)
      ..close();
    canvas.drawPath(p1, Paint()..color = SudaneseTheme.mudBrickDark);
    canvas.drawRect(Rect.fromLTWH(left, top + doorH * 0.60, doorW, doorH * 0.40), Paint()..color = SudaneseTheme.straw);

    final nilePath = Path()
      ..moveTo(left + doorW * 0.15, top + doorH)
      ..quadraticBezierTo(left + doorW * 0.65, top + doorH * 0.80, left + doorW * 0.32, top + doorH * 0.60)
      ..lineTo(left + doorW * 0.48, top + doorH * 0.60)
      ..quadraticBezierTo(left + doorW * 0.85, top + doorH * 0.80, left + doorW * 0.42, top + doorH)
      ..close();
    canvas.drawPath(nilePath, Paint()..color = SudaneseTheme.indigoNight);

    Offset palmTop = Offset(left + doorW * 0.74, top + doorH * 0.32);
    canvas.drawLine(Offset(left + doorW * 0.78, top + doorH * 0.65), palmTop, Paint()..color = SudaneseTheme.earthBlack..strokeWidth = 5);
    final frondPaint = Paint()..color = SudaneseTheme.palmGreen..strokeWidth = 4..strokeCap = StrokeCap.round;
    for (var off in [const Offset(-28, -8), const Offset(-24, 12), const Offset(24, -10), const Offset(22, 12), const Offset(0, -22)]) {
      canvas.drawLine(palmTop, palmTop + off, frondPaint);
    }
    canvas.restore();

    canvas.drawPath(archPath, Paint()..color = SudaneseTheme.nubianTurquoise..style = PaintingStyle.stroke..strokeWidth = 14);
    canvas.drawPath(archPath, Paint()..color = SudaneseTheme.tabaqRed..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
