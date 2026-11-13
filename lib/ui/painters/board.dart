// لوحة السيجا الكرتونية: لوح رمل مدوّر بسُمك ثلاثي الأبعاد وخط خارجي سميك،
// وحفر غائرة بظل داخلي. أبعاد الشبكة (pitCenter/pitDiameter) كما كانت.
import 'dart:math' as math;
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

  static const _ink = SudaneseTheme.woodDark;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final side = canvasSize.shortestSide;
    final rect = Rect.fromLTWH(
        (canvasSize.width - side) / 2, (canvasSize.height - side) / 2, side, side);
    final top = RRect.fromRectAndRadius(
        rect.deflate(1).translate(0, -4), const Radius.circular(30));

    // سُمك اللوح (الوجه الجانبي)
    for (var i = 8; i >= 1; i--) {
      canvas.drawRRect(top.shift(Offset(0, i.toDouble())),
          Paint()..color = Color.lerp(const Color(0xFFB5793A), const Color(0xFF8C5A28), i / 8)!);
    }
    canvas.drawRRect(
        top.shift(const Offset(0, 8)),
        Paint()
          ..color = _ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5);
    // الوجه العلوي
    canvas.drawRRect(top, Paint()..color = const Color(0xFFF3CF8C));
    canvas.drawRRect(top.deflate(7), Paint()..color = const Color(0xFFE9B964));
    canvas.drawRRect(
        top,
        Paint()
          ..color = _ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5);
    // لمعة حافة علوية
    final shine = Path()
      ..moveTo(rect.left + 26, rect.top + 7)
      ..lineTo(rect.right - 60, rect.top + 7);
    canvas.drawPath(
        shine,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);

    final inner = side - 16;
    final cell = inner / size;
    final pitR = cell * 0.36;
    final centre = size ~/ 2;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final p = Offset(rect.left + 8 + (c + 0.5) * cell,
            rect.top + 8 + (r + 0.5) * cell - 4);
        _pit(canvas, p, pitR);
        if (r == centre && c == centre && !centreOccupied) {
          paintDashedCircle(canvas, p, pitR * 0.9, SudaneseTheme.palmGreen, 3, dashes: 14);
          paintEightStar(canvas, p, pitR * 0.42, SudaneseTheme.tabaqRed);
        }
      }
    }
  }

  void _pit(Canvas canvas, Offset p, double r) {
    // حافة بارزة أسفل (تعطي إحساس الغور)
    canvas.drawCircle(p + Offset(0, r * 0.12), r * 1.04, Paint()..color = Colors.white.withValues(alpha: 0.55));
    canvas.drawCircle(p, r, Paint()..color = _ink);
    canvas.drawCircle(p + Offset(0, r * 0.05), r * 0.9, Paint()..color = const Color(0xFFB8782F));
    // ظل داخلي علوي
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: p, radius: r * 0.9)));
    canvas.drawCircle(p + Offset(0, r * 0.42), r * 0.95, Paint()..color = const Color(0xFFD9A04C));
    canvas.restore();
    canvas.drawArc(
        Rect.fromCircle(center: p, radius: r * 0.62), math.pi * 1.05, math.pi * 0.45, false,
        Paint()
          ..color = const Color(0xFF7A4A1E).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) =>
      old.size != size || old.centreOccupied != centreOccupied;
}
