// رسّام اللوحة: إطار خشبي مستدير ووجه رملي وحُفَر محفورة —
// شكل لوحة الحزمة الجديدة (AlsijaGame._board)، على هندسة
// SandBoard نفسها (حشوة 8px، الخلية = (boardPx − 16) / size).
// دائرة الوسطى المتقطعة والنجمة الحمراء كما في الأصل.

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import 'tabaq.dart';

class BoardPainter extends CustomPainter {
  final int size;
  final bool centreOccupied;

  const BoardPainter({required this.size, this.centreOccupied = false});

  static Offset pitCenter(Size boardSize, int cells, int r, int c) {
    final inner = boardSize.shortestSide - 16;
    final cell = inner / cells;
    return Offset(8 + (c + 0.5) * cell, 8 + (r + 0.5) * cell);
  }

  static double pitDiameter(Size boardSize, int cells) =>
      (boardSize.shortestSide - 16) / cells * 0.72;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final side = canvasSize.shortestSide;
    final rect = Rect.fromLTWH(
      (canvasSize.width - side) / 2,
      (canvasSize.height - side) / 2,
      side,
      side,
    );
    // ظل + إطار خشبي + وجه — كما في لوحة الحزمة.
    final r = rect.deflate(9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        r.shift(const Offset(8, 10)),
        const Radius.circular(70),
      ),
      Paint()..color = const Color(0x66724820),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(70)),
      Paint()..color = const Color(0xffa4773b),
    );
    final face = r.deflate(8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(face, const Radius.circular(64)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffefd198), Color(0xffd5a85e)],
        ).createShader(face),
    );
    // الحُفَر: حافة داكنة ثم تجويف بتدرج شعاعي — كما في خلية الحزمة.
    final inner = side - 16;
    final cell = inner / size;
    final pitR = cell * 0.36;
    final centre = size ~/ 2;
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final p = Offset(
          rect.left + 8 + (col + 0.5) * cell,
          rect.top + 8 + (row + 0.5) * cell,
        );
        canvas.drawCircle(
          p,
          pitR + 1,
          Paint()..color = const Color(0xff9e7039),
        );
        final hole = Rect.fromCircle(center: p, radius: pitR - 1);
        canvas.drawCircle(
          p,
          pitR - 1,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(0.2, 0.35),
              radius: 0.75,
              colors: [Color(0xffd9b87c), Color(0xffa47941)],
            ).createShader(hole),
        );
        if (row == centre && col == centre && !centreOccupied) {
          paintDashedCircle(
            canvas,
            p,
            pitR * 0.92,
            SudaneseTheme.palmGreen,
            2.5,
            dashes: 16,
          );
          paintEightStar(canvas, p, pitR * 0.40, SudaneseTheme.tabaqRed);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) =>
      oldDelegate.size != size ||
      oldDelegate.centreOccupied != centreOccupied;
}
