// الحوش الكرتوني: جدار بطوب مدوّر بخطوط سميكة، باب مقوّس بإطار نيلي،
// داخله غروب كرتوني (سماء مسطحة، شمس بوجه، نيل متموّج، نخلة تتمايل)،
// وستة أطباق معلقة بحجم يتدرّج عند الظهور.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import 'tabaq.dart';

class WallPainter extends CustomPainter {
  /// ارتفاع الشمس داخل الباب 0..1.
  final double sunT;

  /// تمايل النخلة بالراديان.
  final double palmSway;

  /// مقياس ظهور كل طبق 0..1.
  final List<double> plates;

  /// توهج الباب (للبداية).
  final double glow;

  /// أعلى الباب كنسبة من ارتفاع الجدار.
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

  static const _ink = SudaneseTheme.woodDark;

  Paint _line(double w) => Paint()
    ..color = _ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    // الجدار
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFE9B8));
    const bh = 26.0, bw = 54.0;
    var r = 0;
    for (var y = 0.0; y < size.height; y += bh) {
      final off = r.isEven ? 0.0 : bw / 2;
      for (var x = -bw + off; x < size.width; x += bw) {
        final rr = RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 2, y + 2, bw - 4, bh - 4), const Radius.circular(7));
        canvas.drawRRect(rr, Paint()..color = (r + (x ~/ bw)).isEven ? const Color(0xFFFFEFC9) : const Color(0xFFFBE0A6));
        canvas.drawRRect(rr, _line(1.6)..color = _ink.withValues(alpha: 0.22));
      }
      r++;
    }
    // قاعدة الجدار
    canvas.drawRect(Rect.fromLTWH(0, size.height - 14, size.width, 14), Paint()..color = const Color(0xFFC9783A));
    canvas.drawLine(Offset(0, size.height - 14), Offset(size.width, size.height - 14), _line(3));

    _plates(canvas, size);
    _door(canvas, size);
  }

  void _plates(Canvas canvas, Size size) {
    const cols = [Color(0xFFE4493B), Color(0xFF1AA3A8), Color(0xFFF2C14E)];
    for (var i = 0; i < 6; i++) {
      final left = i < 3;
      final k = i % 3;
      final cx = left ? size.width * (0.07 + k * 0.045) : size.width * (0.86 + k * 0.045 - 0.09);
      final cy = size.height * (0.28 + (k % 2) * 0.26 + (left ? 0 : 0.05));
      final s = (i < plates.length ? plates[i] : 1.0).clamp(0.0, 1.0);
      if (s <= 0) continue;
      final rad = 13.0 * s;
      canvas.drawCircle(Offset(cx, cy), rad, Paint()..color = cols[i % 3]);
      canvas.drawCircle(Offset(cx, cy), rad * 0.62, Paint()..color = const Color(0xFFFFF4DC));
      canvas.drawCircle(Offset(cx, cy), rad * 0.3, Paint()..color = cols[(i + 1) % 3]);
      canvas.drawCircle(Offset(cx, cy), rad, _line(2.4));
    }
  }

  void _door(Canvas canvas, Size size) {
    final dw = size.width * 0.56;
    final left = (size.width - dw) / 2;
    final top = size.height * doorTopFraction;
    final bottom = top + size.height * doorHeightFraction;
    final archR = dw / 2;
    final door = Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top + archR)
      ..arcToPoint(Offset(left + dw, top + archR), radius: Radius.circular(archR))
      ..lineTo(left + dw, bottom)
      ..close();

    // الإطار
    canvas.drawPath(door.shift(const Offset(0, 5)), Paint()..color = _ink.withValues(alpha: 0.35));
    canvas.drawPath(door, Paint()..color = SudaneseTheme.indigo);
    canvas.drawPath(door, _line(4));

    final inner = Path()
      ..moveTo(left + 9, bottom)
      ..lineTo(left + 9, top + archR)
      ..arcToPoint(Offset(left + dw - 9, top + archR), radius: Radius.circular(archR - 9))
      ..lineTo(left + dw - 9, bottom)
      ..close();
    canvas.save();
    canvas.clipPath(inner);
    final h = bottom - top;
    // سماء من شرائط مسطحة
    final bands = [
      const Color(0xFF6C63D9),
      const Color(0xFFB36BD6),
      const Color(0xFFFF8FA3),
      const Color(0xFFFFB86B),
      const Color(0xFFFFE08A),
    ];
    final bandH = h * 0.78 / bands.length;
    for (var i = 0; i < bands.length; i++) {
      canvas.drawRect(Rect.fromLTWH(left, top + i * bandH, dw, bandH + 1), Paint()..color = bands[i]);
    }
    // الشمس
    final horizon = top + h * 0.74;
    final sunY = horizon - (h * 0.34) * sunT.clamp(0.0, 1.0);
    final sc = Offset(left + dw / 2, sunY);
    if (glow > 0) {
      canvas.drawCircle(sc, 44 + 26 * glow, Paint()..color = const Color(0xFFFFF1A8).withValues(alpha: 0.5 * glow));
    }
    canvas.drawCircle(sc, 20, Paint()..color = const Color(0xFFFFE066));
    canvas.drawCircle(sc, 20, _line(2.6));
    canvas.drawCircle(sc + const Offset(-6, -2), 2.4, Paint()..color = _ink);
    canvas.drawCircle(sc + const Offset(6, -2), 2.4, Paint()..color = _ink);
    canvas.drawArc(Rect.fromCenter(center: sc + const Offset(0, 3), width: 12, height: 9), 0.2, math.pi - 0.4, false, _line(2));
    // سحابتان
    for (final c in [Offset(left + dw * 0.25, top + h * 0.28), Offset(left + dw * 0.75, top + h * 0.2)]) {
      for (final d in [const Offset(-9, 2), const Offset(0, -3), const Offset(9, 2)]) {
        canvas.drawCircle(c + d, 8, Paint()..color = Colors.white.withValues(alpha: 0.9));
      }
    }
    // الأرض والنيل
    canvas.drawRect(Rect.fromLTRB(left, horizon, left + dw, bottom), Paint()..color = const Color(0xFFE0A64F));
    final nile = Path()..moveTo(left, horizon + 8);
    for (var x = 0.0; x <= dw; x += 14) {
      nile.quadraticBezierTo(left + x + 7, horizon + 14 - (x ~/ 14 % 2) * 12.0, left + x + 14, horizon + 8);
    }
    nile
      ..lineTo(left + dw, horizon + 30)
      ..lineTo(left, horizon + 30)
      ..close();
    canvas.drawPath(nile, Paint()..color = const Color(0xFF3FB6E8));
    canvas.drawPath(nile, _line(2.2));
    // نخلة
    _palm(canvas, Offset(left + dw * 0.82, horizon + 34));
    canvas.restore();
    canvas.drawPath(inner, _line(3));

    // إفريز أحمر متقطع على القوس
    paintDashedCircle(canvas, Offset(left + dw / 2, top + archR), archR - 3, SudaneseTheme.tabaqRed, 3.5, dashes: 18);
    // عتبة
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(left - 8, bottom - 6, left + dw + 8, bottom + 8), const Radius.circular(6)),
      Paint()..color = const Color(0xFFC9783A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(left - 8, bottom - 6, left + dw + 8, bottom + 8), const Radius.circular(6)),
      _line(3),
    );
  }

  void _palm(Canvas canvas, Offset base) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(palmSway);
    final trunk = Path()
      ..moveTo(-3, 0)
      ..quadraticBezierTo(-6, -30, -2, -56)
      ..lineTo(4, -56)
      ..quadraticBezierTo(2, -30, 5, 0)
      ..close();
    canvas.drawPath(trunk, Paint()..color = const Color(0xFF9A5B2B));
    canvas.drawPath(trunk, _line(2.2));
    for (final a in [-2.6, -2.0, -1.2, -0.55, 0.15]) {
      final tip = Offset(math.cos(a) * 30, -56 + math.sin(a) * 18);
      final leaf = Path()
        ..moveTo(0, -56)
        ..quadraticBezierTo(tip.dx * 0.5, -56 - 16, tip.dx, tip.dy + 4)
        ..quadraticBezierTo(tip.dx * 0.5, -56 - 2, 0, -56)
        ..close();
      canvas.drawPath(leaf, Paint()..color = const Color(0xFF2FA85A));
      canvas.drawPath(leaf, _line(2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WallPainter old) =>
      old.sunT != sunT || old.palmSway != palmSway || old.glow != glow || old.plates != plates ||
      old.doorTopFraction != doorTopFraction || old.doorHeightFraction != doorHeightFraction;
}
