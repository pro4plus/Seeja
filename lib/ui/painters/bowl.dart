// رسّام الصحن الطيني: صحن طين عريض بحافة سفلية داكنة وشريط
// غرزة كريمي متقطع، وداخله حصوات بلون الحجارة الموجودة فيه فعلاً
// (حجر اللاعب في صحن «باقي»، وحجر الخصم في صحن «أكلت»).
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class BowlPainter extends CustomPainter {
  final PebbleDef pebble;
  final int count;

  const BowlPainter({required this.pebble, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final rimY = h * 0.36;
    final rimRx = w * 0.48;
    final rimRy = h * 0.22;

    // ---- الظل الأرضي ----
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, h * 0.96), width: w * 0.92, height: h * 0.12),
      Paint()..color = Colors.black.withValues(alpha: 0.20),
    );

    // ---- جسم الصحن ----
    final body = Path()
      ..moveTo(cx - rimRx, rimY)
      ..cubicTo(cx - rimRx * 0.94, h * 0.80, cx - w * 0.24, h * 0.99, cx, h * 0.99)
      ..cubicTo(cx + w * 0.24, h * 0.99, cx + rimRx * 0.94, h * 0.80, cx + rimRx, rimY)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD2793F), Color(0xFFB85A2C), Color(0xFF8E4220)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // ---- شريط الغرزة ----
    final stitch = Paint()
      ..color = const Color(0xFFF3E2C8)
      ..strokeWidth = h * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stitchPath = Path()
      ..moveTo(cx - w * 0.40, rimY + h * 0.16)
      ..quadraticBezierTo(cx, rimY + h * 0.34, cx + w * 0.40, rimY + h * 0.16);
    const dash = 5.0;
    const gap = 4.0;
    for (var d = 0.0; d < 1.0; d += (dash + gap) / 100) {
      final d2 = math.min(d + dash / 100, 1.0);
      final a = _pointOn(stitchPath, d);
      final b = _pointOn(stitchPath, d2);
      canvas.drawLine(a, b, stitch);
    }

    // ---- الفتحة (داخل غامق) ----
    final rim = Rect.fromCenter(
        center: Offset(cx, rimY), width: rimRx * 2, height: rimRy * 2);
    canvas.drawOval(rim, Paint()..color = const Color(0xFF2A1A10));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, rimY + h * 0.02),
          width: rimRx * 1.86,
          height: rimRy * 1.72),
      Paint()..color = const Color(0xFF3A2418),
    );

    // ---- الحصى داخل الفتحة ----
    final n = count.clamp(0, 12);
    if (n > 0) {
      canvas.save();
      canvas.clipPath(Path()..addOval(rim));
      final pr = math.min(w * 0.115, h * 0.17);
      final span = w * 0.74;
      final rows = n > 6 ? 2 : 1;
      for (var i = 0; i < n; i++) {
        final row = rows == 1 ? 0 : i ~/ 6;
        final idxInRow = rows == 1 ? i : i % 6;
        final inRow = rows == 1 ? n : math.min(n - row * 6, 6);
        if (inRow <= 0) continue;
        final t = inRow == 1 ? 0.5 : idxInRow / (inRow - 1);
        final x = cx - span / 2 + t * span + (row == 1 ? w * 0.06 : 0);
        final y = rimY - h * 0.05 + row * pr * 1.05;
        canvas.drawCircle(Offset(x, y), pr, Paint()..color = pebble.base);
        canvas.drawCircle(
          Offset(x - pr * 0.28, y - pr * 0.3),
          pr * 0.42,
          Paint()..color = pebble.light.withValues(alpha: 0.75),
        );
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x - pr * 0.3, y - pr * 0.42),
              width: pr * 0.46,
              height: pr * 0.26),
          Paint()..color = Colors.white.withValues(alpha: 0.85),
        );
      }
      canvas.restore();
    }

    // ---- الحافة الأمامية تغطي أسفل الحصى ----
    canvas.drawArc(
      rim,
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFB85A2C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.10,
    );
    canvas.drawArc(
      rim,
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF6E3216)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // حافة علوية رفيعة.
    canvas.drawArc(
      rim,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFE08A50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.05,
    );
  }

  /// نقطة على مسار رباعي عند نسبة t.
  Offset _pointOn(Path path, double t) {
    final metric = path.computeMetrics().first;
    return metric.getTangentForOffset(metric.length * t)?.position ??
        Offset.zero;
  }

  @override
  bool shouldRepaint(covariant BowlPainter oldDelegate) =>
      oldDelegate.pebble != pebble || oldDelegate.count != count;
}
