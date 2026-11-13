// لوحة السيجا: لوح رمل مستدير الحواف بحواف منحوتة قليلاً وحفر
// عميقة دائرية (لا مربعات ولا رقعة شطرنج)، حولها إطار خشبي غامق.
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

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final side = canvasSize.shortestSide;
    final rect = Rect.fromLTWH(
        (canvasSize.width - side) / 2, (canvasSize.height - side) / 2, side, side);
    // ظل خفيف أسفل اللوح فقط (كما في المرجع).
    final shadow = Paint()
      ..color = SudaneseTheme.earthBlack.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.deflate(10).translate(0, 7), const Radius.circular(26)),
      shadow,
    );

    // لوح الرمل: لوح مستدير الحواف بلون القش (كما في المرجع).
    final slab = _slabPath(rect.deflate(10));
    canvas.drawPath(slab, Paint()..color = const Color(0xFFE3C184));

    final rng = math.Random(422);
    canvas.save();
    canvas.clipPath(slab);
    final inner = slab.getBounds();
    for (var i = 0; i < 320; i++) {
      final p = Offset(
        inner.left + rng.nextDouble() * inner.width,
        inner.top + rng.nextDouble() * inner.height,
      );
      final color = i.isEven ? SudaneseTheme.sandDark : const Color(0xFFF2D49A);
      canvas.drawCircle(
          p,
          0.45 + rng.nextDouble() * 1.4,
          Paint()..color = color.withValues(alpha: 0.22 + rng.nextDouble() * 0.22));
    }
    canvas.restore();

    canvas.drawPath(
      slab,
      Paint()
        ..color = const Color(0xFFB98B4E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2,
    );
    canvas.drawPath(
      slab,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final inner2 = side - 16;
    final cell = inner2 / size;
    final pitR = cell * 0.36;
    final centre = size ~/ 2;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final p = Offset(
          rect.left + 8 + (c + 0.5) * cell,
          rect.top + 8 + (r + 0.5) * cell,
        );
        _paintPit(canvas, p, pitR, r, c);
        if (r == centre && c == centre && !centreOccupied) {
          paintDashedCircle(canvas, p, pitR * 0.92, SudaneseTheme.palmGreen,
              2.5, dashes: 16);
          paintEightStar(canvas, p, pitR * 0.40, SudaneseTheme.tabaqRed);
        }
      }
    }
  }

  /// لوح مستدير الحواف باحتفاف خفيف (كقطعة رمل مصبوبة يدوياً).
  Path _slabPath(Rect r) {
    const n = 26.0;
    return Path()
      ..moveTo(r.left + n, r.top + 2)
      ..cubicTo(r.left + n * 0.4, r.top - 3, r.right - n * 0.4, r.top + 4,
          r.right - n, r.top + 2)
      ..cubicTo(r.right + 2, r.top + n * 0.4, r.right + 3, r.bottom - n * 0.4,
          r.right - n, r.bottom - 2)
      ..cubicTo(r.right - n * 0.4, r.bottom + 3, r.left + n * 0.4, r.bottom - 4,
          r.left + n, r.bottom - 2)
      ..cubicTo(r.left - 3, r.bottom - n * 0.4, r.left - 2, r.top + n * 0.4,
          r.left + n, r.top + 2)
      ..close();
  }

  void _paintPit(Canvas canvas, Offset p, double r, int row, int col) {
    // الحافة الرملية المرتفعة حول الحفرة.
    canvas.drawCircle(p, r * 1.14, Paint()..color = const Color(0xFFEFD7A4));
    // تجويف الحفرة.
    canvas.drawCircle(p, r, Paint()..color = const Color(0xFFBE8748));
    // ظل داخل أعلى الحفرة (عمق).
    canvas.drawArc(
      Rect.fromCircle(center: p, radius: r * 0.94),
      math.pi * 1.05,
      math.pi * 0.8,
      false,
      Paint()
        ..color = const Color(0xFF8A6132).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.26
        ..strokeCap = StrokeCap.round,
    );
    // إضاءة أسفل الحفرة.
    canvas.drawArc(
      Rect.fromCircle(center: p, radius: r * 0.94),
      math.pi * 0.08,
      math.pi * 0.72,
      false,
      Paint()
        ..color = const Color(0xFFF6E3B8).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.16
        ..strokeCap = StrokeCap.round,
    );
    if ((row + col) % 3 == 0) {
      canvas.drawCircle(p + Offset(r * .3, -r * .16), 1.3,
          Paint()..color = const Color(0xFFE9C987).withValues(alpha: .6));
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) =>
      oldDelegate.size != size || oldDelegate.centreOccupied != centreOccupied;
}
