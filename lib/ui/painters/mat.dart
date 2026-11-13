// رسّام الخلفية (الحوش): جدار من قصب الس sud Sudan — خيوط عمودية
// بلون القش، مع حبل أحمر وأسود مضفّر أعلى الشاشة (	topThread)
// وشُراشير عند الأسفل (fringe)، تماماً كسور اللوحة.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class MatPainter extends CustomPainter {
  final bool topThread;
  final bool fringe;
  const MatPainter({this.topThread = false, this.fringe = false});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7007);

    // ---- أساس القش ----
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE0BC72),
    );

    // ---- خيوط القصب العمودية ----
    var x = 0.0;
    while (x < size.width) {
      final w = 5 + rng.nextDouble() * 9;
      final tone = 0.06 + rng.nextDouble() * 0.12;
      canvas.drawRect(
        Rect.fromLTWH(x, 0, w, size.height),
        Paint()
          ..color = SudaneseTheme.mudBrick.withValues(alpha: tone),
      );
      canvas.drawRect(
        Rect.fromLTWH(x + w, 0, 1.6, size.height),
        Paint()
          ..color = const Color(0xFFF6E3B6).withValues(alpha: 0.45),
      );
      x += w + 2.5;
    }

    // ---- حبال أفقية خفيفة (نسيج القش) ----
    for (var y = 3.0; y < size.height; y += 14) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + rng.nextDouble() * 1.6),
        Paint()
          ..color = const Color(0xFF8A5129).withValues(alpha: 0.10)
          ..strokeWidth = 1.2,
      );
    }

    // ---- حبل مضفّر (أحمر/أسود) ----
    if (topThread) {
      final bandY = size.height * 0.10;
      final bandH = math.max(10.0, size.height * 0.022);
      canvas.drawRect(
        Rect.fromLTWH(0, bandY, size.width, bandH),
        Paint()..color = const Color(0xFF241607),
      );
      var bx = 0.0;
      var i = 0;
      while (bx < size.width) {
        final seg = bandH * 0.9;
        canvas.drawRect(
          Rect.fromLTWH(bx, bandY, seg * 0.6, bandH),
          Paint()..color = i.isEven
              ? const Color(0xFFC1272D)
              : const Color(0xFFF3EAD2),
        );
        bx += seg * 0.6;
        i++;
      }
      canvas.drawRect(
        Rect.fromLTWH(0, bandY + bandH, size.width, 2),
        Paint()..color = Colors.black.withValues(alpha: 0.25),
      );
    }

    // ---- شُراشير القش عند الأسفل ----
    if (fringe) {
      final base = size.height - 18;
      for (var fx = 2.0; fx < size.width; fx += 6) {
        final len = 11 + ((fx ~/ 6) % 3) * 4;
        canvas.drawLine(
          Offset(fx, base),
          Offset(fx + (fx % 3 - 1), base + len),
          Paint()
            ..color = const Color(0xFF8A5129).withValues(alpha: 0.65)
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant MatPainter oldDelegate) =>
      oldDelegate.topThread != topThread || oldDelegate.fringe != fringe;
}
