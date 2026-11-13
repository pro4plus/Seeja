// رسّام جدار الحوش (§5.2 + لوحة التصميم):
// جدار مبيّض، قاعدة طوب لبن، باب مقوّس بإطار فيروزي وإفريز
// أحمر متقطع، وبداخله مشهد غروب (سماء بنفسجي→برتقالي، شمس طبق،
// أهرامات مروي، النيل، نخلة تتمايل)، و6 أطباق في الحائط.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import 'tabaq.dart';

class WallPainter extends CustomPainter {
  /// ارتفاع الشمس داخل الباب 0..1 (0 = عند الأفق، 1 = أعلى الباب).
  final double sunT;

  /// تمايل النخلة بالراديان.
  final double palmSway;

  /// مقياس ظهور كل طبق من الأطباق الستة 0..1 (لظهور متدرج في البداية).
  final List<double> plates;

  /// توهج الباب (للبداية).
  final double glow;

  /// أعلى الباب كنسبة من ارتفاع الجدار: يجب أن يكون تحت منطقة
  /// العنوان (الرئيسية والبداية تضعان العنوان فوق الجدار).
  final double doorTopFraction;

  /// ارتفاع الباب كنسبة من ارتفاع الجدار.
  final double doorHeightFraction;

  const WallPainter({
    this.sunT = 1.0,
    this.palmSway = 0.0,
    this.plates = const [1, 1, 1, 1, 1, 1],
    this.glow = 0.0,
    this.doorTopFraction = 0.06,
    this.doorHeightFraction = 0.82,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ---- الجدار المبيّض ----
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = SudaneseTheme.whitewash,
    );
    // بقع جص خافتة.
    final smudge = Paint()
      ..color = SudaneseTheme.sandDark.withValues(alpha: 0.10);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.2, size.height * 0.25),
            width: 90,
            height: 46),
        smudge);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.85, size.height * 0.6),
            width: 70,
            height: 34),
        smudge);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.5, size.height * 0.08),
            width: 120,
            height: 30),
        smudge);

    // ---- الباب المقوّس ----
    final doorW = size.width * 0.56;
    final doorH = size.height * doorHeightFraction;
    final doorLeft = (size.width - doorW) / 2;
    final doorTop = size.height * doorTopFraction;
    final archR = doorW / 2;
    final doorRect = Rect.fromLTWH(doorLeft, doorTop, doorW, doorH);
    final archPath = Path()
      ..moveTo(doorRect.left, doorRect.bottom)
      ..lineTo(doorRect.left, doorRect.top + archR)
      ..arcTo(
        Rect.fromCircle(
            center: Offset(doorRect.center.dx, doorRect.top + archR),
            radius: archR),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(doorRect.right, doorRect.bottom)
      ..close();

    // الإطار الفيروزي.
    canvas.drawPath(archPath, Paint()..color = SudaneseTheme.turquoise);
    // الإفريز الأحمر المتقطع على الإطار.
    _paintFrieze(canvas, doorRect, archR);

    // ---- مشهد الغروب داخل الباب ----
    const frame = 13.0;
    final innerRect = Rect.fromLTWH(
      doorRect.left + frame,
      doorRect.top + frame,
      doorRect.width - frame * 2,
      doorRect.height - frame,
    );
    final innerArch = Path()
      ..moveTo(innerRect.left, innerRect.bottom)
      ..lineTo(innerRect.left, innerRect.top + archR - frame)
      ..arcTo(
        Rect.fromCircle(
            center:
                Offset(innerRect.center.dx, innerRect.top + archR - frame),
            radius: archR - frame),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(innerRect.right, innerRect.bottom)
      ..close();
    canvas.save();
    canvas.clipPath(innerArch);
    _paintDusk(canvas, innerRect, sunT);
    canvas.restore();

    // توهج الباب (للبداية).
    if (glow > 0) {
      canvas.save();
      canvas.clipPath(archPath);
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = SudaneseTheme.sunGold.withValues(alpha: 0.25 * glow),
      );
      canvas.restore();
    }

    // ---- الأطباق الستة في الحائط (3 يمين و3 يسار) ----
    final plateSpots = <(double, double, double)>[
      (0.10, 0.22, 0.085), // يسار كبير
      (0.90, 0.22, 0.085), // يمين كبير
      (0.13, 0.48, 0.065), // يسار وسط
      (0.87, 0.48, 0.065), // يمين وسط
      (0.09, 0.72, 0.05), // يسار صغير
      (0.91, 0.72, 0.05), // يمين صغير
    ];
    for (var i = 0; i < 6; i++) {
      final s = plates[i.clamp(0, plates.length - 1)];
      if (s <= 0) continue;
      final (fx, fy, fr) = plateSpots[i];
      final center = Offset(size.width * fx, size.height * fy);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(s);
      canvas.translate(-center.dx, -center.dy);
      final rect =
          Rect.fromCircle(center: center, radius: size.width * fr);
      if (i.isEven) {
        paintPlateRings(canvas, rect);
      } else {
        paintPlateStar(canvas, rect);
      }
      canvas.restore();
    }

    // ---- قاعدة الطوب اللبن أسفل الجدار ----
    final plinthH = size.height * 0.07;
    final plinth = Rect.fromLTWH(
        0, size.height - plinthH, size.width, plinthH);
    canvas.drawRect(
        plinth, Paint()..color = SudaneseTheme.mudBrick);
    final brickPaint = Paint()
      ..color = SudaneseTheme.mudBrickDark
      ..strokeWidth = 1.5;
    for (var y = plinth.top + plinthH / 2; y < size.height; y += plinthH / 2) {
      canvas.drawLine(
          Offset(0, y), Offset(size.width, y), brickPaint);
    }
    for (var x = 0.0; x < size.width; x += 34) {
      final off = ((x / 34) % 2 == 0) ? 0.0 : 17.0;
      canvas.drawLine(Offset(x + off, plinth.top),
          Offset(x + off, size.height), brickPaint);
    }
  }

  /// إفريز أحمر: مربعات صغيرة على طول الإطار المقوّس.
  void _paintFrieze(Canvas canvas, Rect doorRect, double archR) {
    final paint = Paint()..color = SudaneseTheme.tabaqRed;
    const sq = 7.0;
    // الجانبان العموديان.
    for (var y = doorRect.top + archR + 10;
        y < doorRect.bottom - 8;
        y += 22) {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(doorRect.left + 7, y), width: sq, height: sq),
          paint);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(doorRect.right - 7, y), width: sq, height: sq),
          paint);
    }
    // القوس العلوي.
    final cx = doorRect.center.dx;
    final cy = doorRect.top + archR;
    for (var a = math.pi; a <= 2 * math.pi; a += 0.22) {
      final x = cx + (archR - 7) * math.cos(a);
      final y = cy + (archR - 7) * math.sin(a);
      canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: sq, height: sq),
          paint);
    }
  }

  /// مشهد الغروب بنمط المرجع: شرائط سماء مسطّحة، شمس برتقالية،
  /// أهرامات مروي، نيل ملتفٍّ، ونخلة كبيرة على اليمين.
  void _paintDusk(Canvas canvas, Rect rect, double sunT) {
    // سماء مسطّحة بشرائط (شكل مطبوع باليد لا غشاوة رقمية).
    const bands = [
      Color(0xFF5E4F72),
      Color(0xFF7C5C74),
      Color(0xFFA86E6E),
      Color(0xFFC98A72),
      Color(0xFFE3A97E),
    ];
    final skyH = rect.height * 0.62;
    final bandH = skyH / bands.length;
    for (var i = 0; i < bands.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
            rect.left, rect.top + i * bandH, rect.width, bandH + 1),
        Paint()..color = bands[i],
      );
    }
    // الشمس البرتقالية.
    final sunR = rect.width * 0.11;
    final sunY = rect.top + skyH * 0.32 - sunT * rect.height * 0.12;
    canvas.drawCircle(
        Offset(rect.left + rect.width * 0.29, sunY), sunR,
        Paint()..color = const Color(0xFFE2683A));

    // الأرض والخط البعيد.
    final horizonY = rect.top + skyH;
    canvas.drawRect(
      Rect.fromLTWH(rect.left, horizonY, rect.width, rect.bottom - horizonY),
      Paint()..color = const Color(0xFFC08A4E),
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.left, horizonY, rect.width, 6),
      Paint()..color = const Color(0xFFC98A72),
    );

    // أهرامات مروي.
    final pyr = Paint()..color = const Color(0xFF8A5A34);
    final pyrDark = Paint()..color = const Color(0xFF7A4C2C);
    for (final (fx, fw, fh) in [
      (0.04, 0.20, 0.14),
      (0.30, 0.18, 0.10),
    ]) {
      final x0 = rect.left + rect.width * fx;
      final w = rect.width * fw;
      final h = rect.height * fh;
      canvas.drawPath(
        Path()
          ..moveTo(x0, horizonY + 4)
          ..lineTo(x0 + w / 2, horizonY + 4 - h)
          ..lineTo(x0 + w, horizonY + 4)
          ..close(),
        pyr,
      );
      canvas.drawPath(
        Path()
          ..moveTo(x0 + w / 2, horizonY + 4 - h)
          ..lineTo(x0 + w, horizonY + 4)
          ..lineTo(x0 + w * 0.54, horizonY + 4)
          ..close(),
        pyrDark,
      );
    }

    // النيل: شريط ملتفٍّ.
    final nile = Path()
      ..moveTo(rect.left + rect.width * 0.52, horizonY + 2)
      ..cubicTo(
        rect.left + rect.width * 0.72,
        horizonY + rect.height * 0.10,
        rect.left + rect.width * 0.30,
        horizonY + rect.height * 0.14,
        rect.left + rect.width * 0.38,
        horizonY + rect.height * 0.24,
      )
      ..cubicTo(
        rect.left + rect.width * 0.46,
        horizonY + rect.height * 0.34,
        rect.left + rect.width * 0.22,
        horizonY + rect.height * 0.34,
        rect.left + rect.width * 0.30,
        rect.bottom,
      )
      ..lineTo(rect.left + rect.width * 0.62, rect.bottom)
      ..cubicTo(
        rect.left + rect.width * 0.52,
        horizonY + rect.height * 0.40,
        rect.left + rect.width * 0.62,
        horizonY + rect.height * 0.28,
        rect.left + rect.width * 0.56,
        horizonY + rect.height * 0.16,
      )
      ..cubicTo(
        rect.left + rect.width * 0.50,
        horizonY + rect.height * 0.06,
        rect.left + rect.width * 0.60,
        horizonY + 2,
        rect.left + rect.width * 0.52,
        horizonY + 2,
      )
      ..close();
    canvas.drawPath(nile, Paint()..color = const Color(0xFF3E8FB0));

    // النخلة الكبيرة على اليمين.
    final palmBase = rect.bottom - 2;
    final palmTop = rect.top + rect.height * 0.30;
    final palmX = rect.right - rect.width * 0.16;
    canvas.save();
    canvas.translate(palmX, palmBase);
    canvas.rotate(palmSway);
    canvas.translate(-palmX, -palmBase);
    final trunk = Path()
      ..moveTo(palmX - 7, palmBase)
      ..cubicTo(palmX - 3, palmBase - 60, palmX - 1, palmTop + 60, palmX + 2,
          palmTop)
      ..lineTo(palmX + 15, palmTop)
      ..cubicTo(palmX + 13, palmTop + 60, palmX + 15, palmBase - 60,
          palmX + 11, palmBase)
      ..close();
    canvas.drawPath(trunk, Paint()..color = const Color(0xFF6E4A2E));
    // حلقات الجذع.
    final seg = Paint()
      ..color = const Color(0xFF4E321F).withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (var i = 1; i <= 6; i++) {
      final t = i / 7;
      final y = palmBase - (palmBase - palmTop) * t;
      canvas.drawLine(Offset(palmX - 6, y), Offset(palmX + 13, y), seg);
    }
    // السعف.
    final top = Offset(palmX + 8, palmTop);
    for (final (dx, dy, len) in [
      (-40.0, 20.0, 1.05),
      (40.0, 20.0, 1.05),
      (-30.0, -24.0, 0.95),
      (30.0, -24.0, 0.95),
      (-14.0, -40.0, 0.85),
      (14.0, -40.0, 0.85),
      (-34.0, 42.0, 0.8),
      (34.0, 42.0, 0.8),
    ]) {
      final end = top + Offset(dx * len, dy * len);
      // ورقة السعفة: عريضة في الوسط ومدببة في الطرف.
      final nx = dy * 0.55;
      final ny = -dx * 0.55;
      canvas.drawPath(
        Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(
              top.dx + dx * 0.45 * len + nx * 0.5,
              top.dy + dy * 0.45 * len + ny * 0.5,
              end.dx,
              end.dy)
          ..quadraticBezierTo(
              top.dx + dx * 0.45 * len - nx * 0.5,
              top.dy + dy * 0.45 * len - ny * 0.5,
              top.dx,
              top.dy)
          ..close(),
        Paint()..color = const Color(0xFF1F6B34),
      );
      // عرق السعفة.
      canvas.drawLine(
        top,
        end,
        Paint()
          ..color = const Color(0xFF16562B)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WallPainter oldDelegate) =>
      oldDelegate.sunT != sunT ||
      oldDelegate.palmSway != palmSway ||
      oldDelegate.glow != glow ||
      oldDelegate.plates != plates ||
      oldDelegate.doorTopFraction != doorTopFraction ||
      oldDelegate.doorHeightFraction != doorHeightFraction;
}
