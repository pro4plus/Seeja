import 'dart:math';
import 'package:flutter/material.dart';
import '../../game/seega_engine.dart';
import '../../theme/sudanese_theme.dart';

class BoardPainter extends CustomPainter {
  final int size;
  final List<List<Player?>>? board;
  final Color p1Color;
  final Color p2Color;
  final Point<int>? selectedPit;
  final List<Point<int>> legalTargets;
  final Point<int>? hintFrom;
  final Point<int>? hintTo;

  BoardPainter({
    this.size = 5,
    this.board,
    this.p1Color = SudaneseTheme.indigoNight,
    this.p2Color = const Color(0xFFB86B35),
    this.selectedPit,
    this.legalTargets = const [],
    this.hintFrom,
    this.hintTo,
  });

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Rect.fromLTWH(0, 0, s.width, s.height);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(22));

    canvas.drawRRect(rRect.shift(const Offset(4, 7)), Paint()..color = SudaneseTheme.earthBlack.withOpacity(0.42));
    canvas.drawRRect(rRect, Paint()..color = const Color(0xFFD6B372));
    canvas.drawRRect(rRect, Paint()..color = SudaneseTheme.mudBrickLight..style = PaintingStyle.stroke..strokeWidth = 5);

    double pad = 14.0;
    double cellW = (s.width - pad * 2) / size;
    double cellH = (s.height - pad * 2) / size;

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        double cx = pad + (c + 0.5) * cellW;
        double cy = pad + (r + 0.5) * cellH;
        double pitR = cellW * 0.38;

        canvas.drawCircle(Offset(cx, cy), pitR, Paint()..color = const Color(0xFF9F7A42));
        canvas.drawCircle(Offset(cx, cy + 2), pitR * 0.88, Paint()..color = const Color(0xFFB69054));
        canvas.drawCircle(Offset(cx, cy), pitR, Paint()..color = SudaneseTheme.mudBrickDark.withOpacity(0.45)..style = PaintingStyle.stroke..strokeWidth = 1.8);

        if (r == size ~/ 2 && c == size ~/ 2 && (board == null || board![r][c] == null)) {
          canvas.drawCircle(Offset(cx, cy), pitR * 0.82, Paint()..color = SudaneseTheme.mudBrickDark..style = PaintingStyle.stroke..strokeWidth = 1.5);
          canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = SudaneseTheme.tabaqRed);
        }

        if (legalTargets.contains(Point(r, c))) {
          canvas.drawCircle(Offset(cx, cy), pitR * 0.9, Paint()..color = SudaneseTheme.palmGreen.withOpacity(0.32));
          canvas.drawCircle(Offset(cx, cy), pitR * 0.9, Paint()..color = SudaneseTheme.palmGreen..style = PaintingStyle.stroke..strokeWidth = 2.5);
        }

        final occupant = board != null ? board![r][c] : null;
        if (occupant != null) {
          bool isSelected = selectedPit == Point(r, c);
          Color stoneColor = occupant == Player.p1 ? p1Color : p2Color;
          double lift = isSelected ? -5.0 : 0.0;
          double stoneR = pitR * (isSelected ? 0.82 : 0.74);

          if (isSelected) {
            canvas.drawCircle(Offset(cx, cy), pitR * 1.02, Paint()..color = SudaneseTheme.sunGold..style = PaintingStyle.stroke..strokeWidth = 3.5);
          }

          canvas.drawOval(Rect.fromCenter(center: Offset(cx + 2, cy + 5), width: stoneR * 1.9, height: stoneR * 1.5), Paint()..color = SudaneseTheme.earthBlack.withOpacity(0.45));

          canvas.save();
          canvas.translate(cx, cy + lift);
          canvas.rotate(-12 * pi / 180);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: stoneR * 1.85, height: stoneR * 1.55), Paint()..color = stoneColor);
          canvas.drawOval(Rect.fromCenter(center: Offset(-stoneR * 0.35, -stoneR * 0.25), width: stoneR * 0.45, height: stoneR * 0.25), Paint()..color = Colors.white.withOpacity(0.42));
          canvas.restore();
        }
      }
    }

    if (hintFrom != null && hintTo != null) {
      Offset pA = Offset(pad + (hintFrom!.y + 0.5) * cellW, pad + (hintFrom!.x + 0.5) * cellH);
      Offset pB = Offset(pad + (hintTo!.y + 0.5) * cellW, pad + (hintTo!.x + 0.5) * cellH);
      canvas.drawLine(pA, pB, Paint()..color = SudaneseTheme.sunGold..strokeWidth = 5..strokeCap = StrokeCap.round);
      canvas.drawCircle(pB, 7, Paint()..color = SudaneseTheme.tabaqRed);
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
