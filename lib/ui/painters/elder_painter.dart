import 'package:flutter/material.dart';
import '../../game/seega_ai.dart';
import '../../theme/sudanese_theme.dart';

class ElderPainter extends CustomPainter {
  final AIDifficulty difficulty;
  ElderPainter({this.difficulty = AIDifficulty.hard});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2, cy = size.height * 0.56;
    final jalabiyaPaint = Paint()..color = const Color(0xFFF9F6EE);
    final bodyPath = Path()
      ..moveTo(cx - size.width * 0.38, size.height)
      ..quadraticBezierTo(cx - size.width * 0.35, cy + 14, cx, cy + 12)
      ..quadraticBezierTo(cx + size.width * 0.35, cy + 14, cx + size.width * 0.38, size.height)
      ..close();
    canvas.drawPath(bodyPath, jalabiyaPaint);
    canvas.drawLine(Offset(cx, cy + 12), Offset(cx, size.height), Paint()..color = SudaneseTheme.straw..strokeWidth = 2);

    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 8), width: 16, height: 16), Paint()..color = const Color(0xFF7D4E32));
    canvas.drawCircle(Offset(cx, cy - 10), 22, Paint()..color = const Color(0xFF8D5B3C));

    final eyePaint = Paint()..color = SudaneseTheme.earthBlack;
    canvas.drawCircle(Offset(cx - 8, cy - 11), 2.5, eyePaint);
    canvas.drawCircle(Offset(cx + 8, cy - 11), 2.5, eyePaint);

    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 18, height: 8),
      3.14,
      3.14,
      false,
      Paint()..color = difficulty == AIDifficulty.hard ? Colors.white : SudaneseTheme.earthBlack..strokeWidth = 3..style = PaintingStyle.stroke,
    );

    if (difficulty == AIDifficulty.easy) {
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy - 22), width: 42, height: 30), 3.14, 3.14, true, jalabiyaPaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - 22), width: 44, height: 5), Paint()..color = SudaneseTheme.tabaqRed);
    } else if (difficulty == AIDifficulty.medium) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 28), width: 52, height: 24), jalabiyaPaint);
      final glassPaint = Paint()..color = SudaneseTheme.earthBlack..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawCircle(Offset(cx - 8, cy - 11), 6.5, glassPaint);
      canvas.drawCircle(Offset(cx + 8, cy - 11), 6.5, glassPaint);
      canvas.drawLine(Offset(cx - 1.5, cy - 11), Offset(cx + 1.5, cy - 11), glassPaint);
    } else {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 29), width: 58, height: 28), jalabiyaPaint);
      final beardPath = Path()..moveTo(cx - 18, cy - 6)..quadraticBezierTo(cx, cy + 20, cx + 18, cy - 6)..close();
      canvas.drawPath(beardPath, jalabiyaPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ElderPainter oldDelegate) => oldDelegate.difficulty != difficulty;
}
