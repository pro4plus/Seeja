import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';

class MatPainter extends CustomPainter {
  final bool showFringe;
  MatPainter({this.showFringe = true});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFE3C485));
    final reedPaint = Paint()..color = SudaneseTheme.mudBrickLight.withOpacity(0.22)..strokeWidth = 1.5;
    for (double x = 0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), reedPaint);
    }
    _drawWovenBand(canvas, size.width, size.height * 0.08);
    _drawWovenBand(canvas, size.width, size.height * 0.87);

    if (showFringe) {
      final fringePaint = Paint()..color = SudaneseTheme.earthBlack..strokeWidth = 2;
      double yStart = size.height - 14;
      for (double x = 6; x < size.width; x += 12) {
        canvas.drawLine(Offset(x, yStart), Offset(x - 3, size.height), fringePaint);
        canvas.drawLine(Offset(x, yStart), Offset(x + 3, size.height), fringePaint);
      }
    }
  }

  void _drawWovenBand(Canvas canvas, double width, double y) {
    canvas.drawRect(Rect.fromLTWH(0, y, width, 12), Paint()..color = SudaneseTheme.earthBlack);
    final redPaint = Paint()..color = SudaneseTheme.tabaqRed;
    for (double x = 0; x < width; x += 24) {
      canvas.drawRect(Rect.fromLTWH(x + 4, y + 3, 12, 6), redPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
