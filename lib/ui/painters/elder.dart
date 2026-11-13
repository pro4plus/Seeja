// شخصيات سودانية كرتونية: رأس كبير، عيون لامعة، خطوط خارجية سميكة وألوان مسطحة
// بظل خلية. ثلاث شخصيات: شاب (سهل)، أستاذ (وسط)، شيخ (صعب).
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ElderKind { young, teacher, elder }

class ElderPainter extends CustomPainter {
  final ElderKind kind;
  final double tilt;
  final double bow;

  const ElderPainter({required this.kind, this.tilt = 0, this.bow = 0});

  static const _ink = Color(0xFF2B1A12);
  static const _skin = Color(0xFFB86F3E);
  static const _skinLight = Color(0xFFD08A55);
  static const _skinShade = Color(0xFF8C5230);
  static const _robe = Color(0xFFFFF4DC);
  static const _robeShade = Color(0xFFE6D2A6);
  static const _red = Color(0xFFD1352B);
  static const _teal = Color(0xFF1AA3A8);
  static const _gold = Color(0xFFF2C14E);
  static const _white = Color(0xFFFFFFFF);

  static const double _w = 2.4; // سُمك الخط الخارجي

  Paint _line([double w = _w]) => Paint()
    ..color = _ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _shape(Canvas c, Path p, Color fill, [double w = _w]) {
    c.drawPath(p, Paint()..color = fill);
    c.drawPath(p, _line(w));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 100, size.height / 130);
    canvas.save();
    canvas.translate((size.width - 100 * scale) / 2, (size.height - 130 * scale) / 2);
    canvas.scale(scale, scale);

    // ظل الأرض
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 126), width: 84, height: 9),
        Paint()..color = _ink.withValues(alpha: 0.22));

    _body(canvas);

    canvas.save();
    canvas.translate(50, 62);
    canvas.rotate(tilt + bow * 0.30);
    canvas.translate(-50, -62);
    _head(canvas);
    canvas.restore();

    canvas.restore();
  }

  void _body(Canvas canvas) {
    // الجلابية
    final robe = Path()
      ..moveTo(50, 60)
      ..quadraticBezierTo(22, 62, 13, 90)
      ..quadraticBezierTo(8, 110, 10, 124)
      ..quadraticBezierTo(50, 130, 90, 124)
      ..quadraticBezierTo(92, 110, 87, 90)
      ..quadraticBezierTo(78, 62, 50, 60)
      ..close();
    _shape(canvas, robe, _robe);
    // ظل خلية على الجنب الأيمن
    canvas.save();
    canvas.clipPath(robe);
    canvas.drawRect(const Rect.fromLTWH(72, 60, 30, 70), Paint()..color = _robeShade);
    canvas.restore();
    canvas.drawPath(robe, _line());
    // فتحة الرقبة المطرزة
    final collar = Path()
      ..moveTo(40, 61)
      ..lineTo(50, 78)
      ..lineTo(60, 61);
    canvas.drawPath(collar, _line(5.5)..color = _red);
    canvas.drawPath(collar, _line(1.6)..color = _gold);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(50, 86.0 + i * 8), 2.1, Paint()..color = _teal);
      canvas.drawCircle(Offset(50, 86.0 + i * 8), 2.1, _line(1.2));
    }
    // اليدان
    for (final x in [20.0, 80.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 112), width: 13, height: 11), Paint()..color = _skin);
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 112), width: 13, height: 11), _line(2));
    }
  }

  void _head(Canvas canvas) {
    // الرقبة
    final neck = RRect.fromRectAndRadius(const Rect.fromLTWH(42, 52, 16, 14), const Radius.circular(5));
    canvas.drawRRect(neck, Paint()..color = _skinShade);
    canvas.drawRRect(neck, _line());

    // الأذنان
    for (final x in [24.5, 75.5]) {
      canvas.drawCircle(Offset(x, 40), 6, Paint()..color = _skin);
      canvas.drawCircle(Offset(x, 40), 6, _line(2));
      canvas.drawCircle(Offset(x, 40), 2.4, Paint()..color = _skinShade);
    }

    // الوجه
    final face = Rect.fromCenter(center: const Offset(50, 38), width: 52, height: 50);
    canvas.drawOval(face, Paint()..color = _skin);
    canvas.save();
    canvas.clipPath(Path()..addOval(face));
    canvas.drawOval(Rect.fromCenter(center: const Offset(64, 52), width: 40, height: 40),
        Paint()..color = _skinShade.withValues(alpha: 0.55));
    canvas.drawOval(Rect.fromCenter(center: const Offset(40, 24), width: 26, height: 14),
        Paint()..color = _skinLight.withValues(alpha: 0.7));
    canvas.restore();
    canvas.drawOval(face, _line());

    // خدود
    for (final x in [34.0, 66.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 48), width: 9, height: 5.5),
          Paint()..color = const Color(0xFFE5675A).withValues(alpha: 0.45));
    }

    _eyes(canvas);
    // الأنف
    final nose = Path()
      ..moveTo(47, 44)
      ..quadraticBezierTo(50, 50, 53, 44);
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 46), width: 9, height: 6.5), Paint()..color = _skinShade);
    canvas.drawPath(nose, _line(1.6));

    switch (kind) {
      case ElderKind.young:
        _youngFace(canvas);
        break;
      case ElderKind.teacher:
        _teacherFace(canvas);
        break;
      case ElderKind.elder:
        _elderFace(canvas);
        break;
    }
  }

  void _eyes(Canvas canvas) {
    for (final x in [41.0, 59.0]) {
      final white = Rect.fromCenter(center: Offset(x, 37), width: 11.5, height: 13);
      canvas.drawOval(white, Paint()..color = _white);
      canvas.drawOval(white, _line(1.8));
      canvas.drawCircle(Offset(x + 0.6, 38), 3.9, Paint()..color = _ink);
      canvas.drawCircle(Offset(x - 0.9, 35.6), 1.4, Paint()..color = _white);
      canvas.drawCircle(Offset(x + 1.8, 39.6), 0.7, Paint()..color = _white);
    }
  }

  void _brows(Canvas canvas, {double raise = 0, Color color = _ink, double w = 3}) {
    canvas.drawPath(
        Path()
          ..moveTo(35, 29.5 - raise)
          ..quadraticBezierTo(41, 26 - raise, 46.5, 29.5 - raise),
        _line(w)..color = color);
    canvas.drawPath(
        Path()
          ..moveTo(53.5, 29.5 - raise)
          ..quadraticBezierTo(59, 26 - raise, 65, 29.5 - raise),
        _line(w)..color = color);
  }

  // ---- شاب: طاقية مطرزة وابتسامة واسعة ----
  void _youngFace(Canvas canvas) {
    _brows(canvas, raise: 2);
    final mouth = Path()
      ..moveTo(40, 54)
      ..quadraticBezierTo(50, 66, 60, 54)
      ..close();
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF6B1F1A));
    canvas.save();
    canvas.clipPath(mouth);
    canvas.drawRect(const Rect.fromLTWH(40, 53, 20, 4.4), Paint()..color = _white);
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 62), width: 10, height: 6), Paint()..color = const Color(0xFFE5675A));
    canvas.restore();
    canvas.drawPath(mouth, _line(2));
    // الطاقية
    final cap = Path()
      ..moveTo(26, 25)
      ..quadraticBezierTo(28, 4, 50, 4)
      ..quadraticBezierTo(72, 4, 74, 25)
      ..quadraticBezierTo(50, 19, 26, 25)
      ..close();
    _shape(canvas, cap, _white);
    final band = Path()
      ..moveTo(26.5, 22)
      ..quadraticBezierTo(50, 16, 73.5, 22)
      ..lineTo(74, 26)
      ..quadraticBezierTo(50, 20, 26, 26)
      ..close();
    canvas.drawPath(band, Paint()..color = _red);
    for (var i = 0; i < 5; i++) {
      final x = 34.0 + i * 8;
      canvas.drawCircle(Offset(x, 21.5 - (i == 2 ? 0.2 : (i % 2 == 0 ? 0.6 : 0))), 1.3, Paint()..color = _gold);
    }
    canvas.drawPath(cap, _line());
    canvas.drawCircle(const Offset(50, 3.5), 2.6, Paint()..color = _teal);
    canvas.drawCircle(const Offset(50, 3.5), 2.6, _line(1.6));
  }

  // ---- أستاذ: عمامة صغيرة، نظارة دائرية، شارب ولحية خفيفة ----
  void _teacherFace(Canvas canvas) {
    _brows(canvas);
    for (final x in [41.0, 59.0]) {
      canvas.drawCircle(Offset(x, 37.5), 9.2, _line(2.2)..color = const Color(0xFF3A2A8A));
      canvas.drawArc(Rect.fromCircle(center: Offset(x, 37.5), radius: 7), math.pi * 1.1, 0.9, false,
          _line(1.4)..color = _white.withValues(alpha: 0.85));
    }
    canvas.drawLine(const Offset(50.2, 36), const Offset(49.8, 36), _line(2.2)..color = const Color(0xFF3A2A8A));
    // الشارب
    final mus = Path()
      ..moveTo(50, 50.5)
      ..quadraticBezierTo(43, 47, 38, 52)
      ..quadraticBezierTo(44, 56, 50, 52.5)
      ..quadraticBezierTo(56, 56, 62, 52)
      ..quadraticBezierTo(57, 47, 50, 50.5)
      ..close();
    _shape(canvas, mus, const Color(0xFF3B2A25), 1.8);
    // ابتسامة هادئة + لحية صغيرة
    canvas.drawPath(Path()..moveTo(44.5, 58)..quadraticBezierTo(50, 62, 55.5, 58), _line(2));
    final goatee = Path()
      ..moveTo(44, 62)
      ..quadraticBezierTo(50, 72, 56, 62)
      ..quadraticBezierTo(50, 65, 44, 62)
      ..close();
    _shape(canvas, goatee, const Color(0xFF3B2A25), 1.6);
    // العمامة
    final turban = Path()
      ..moveTo(24, 26)
      ..quadraticBezierTo(24, 3, 50, 3)
      ..quadraticBezierTo(76, 3, 76, 26)
      ..quadraticBezierTo(50, 18, 24, 26)
      ..close();
    _shape(canvas, turban, _white);
    for (final y in [11.0, 17.0]) {
      canvas.drawPath(Path()..moveTo(28, y + 4)..quadraticBezierTo(50, y - 4, 72, y + 4), _line(1.4)..color = _robeShade);
    }
    canvas.drawPath(turban, _line());
    canvas.drawCircle(const Offset(50, 22), 2.6, Paint()..color = _red);
    canvas.drawCircle(const Offset(50, 22), 2.6, _line(1.4));
  }

  // ---- شيخ: عمامة كبيرة، لحية بيضاء كثة، حواجب كثيفة ----
  void _elderFace(Canvas canvas) {
    // التجاعيد
    for (final x in [33.0, 67.0]) {
      canvas.drawLine(Offset(x - 3, 34), Offset(x - 1.5, 33), _line(1.1)..color = _skinShade);
    }
    final beard = Path()
      ..moveTo(26, 42)
      ..quadraticBezierTo(24, 66, 36, 74)
      ..quadraticBezierTo(50, 84, 64, 74)
      ..quadraticBezierTo(76, 66, 74, 42)
      ..quadraticBezierTo(66, 54, 50, 52)
      ..quadraticBezierTo(34, 54, 26, 42)
      ..close();
    _shape(canvas, beard, _white);
    canvas.save();
    canvas.clipPath(beard);
    canvas.drawOval(Rect.fromCenter(center: const Offset(66, 66), width: 30, height: 36), Paint()..color = const Color(0xFFDCDCE6));
    canvas.restore();
    for (final l in [
      [Offset(36, 62), Offset(35, 71)],
      [Offset(50, 66), Offset(50, 78)],
      [Offset(64, 62), Offset(65, 71)],
    ]) {
      canvas.drawLine(l[0], l[1], _line(1.1)..color = const Color(0xFFB9B9C6));
    }
    canvas.drawPath(beard, _line());
    // الشارب الأبيض
    final mus = Path()
      ..moveTo(50, 49)
      ..quadraticBezierTo(40, 45, 34, 53)
      ..quadraticBezierTo(42, 56, 50, 52)
      ..quadraticBezierTo(58, 56, 66, 53)
      ..quadraticBezierTo(60, 45, 50, 49)
      ..close();
    _shape(canvas, mus, _white, 1.8);
    canvas.drawPath(Path()..moveTo(45, 58)..quadraticBezierTo(50, 62, 55, 58), _line(2));
    // حواجب بيضاء كثيفة
    _brows(canvas, color: _white, w: 5);
    canvas.drawPath(Path()..moveTo(35, 29.5)..quadraticBezierTo(41, 26, 46.5, 29.5), _line(1.4)..color = _ink..strokeWidth = 1);
    // العمامة الكبيرة
    final turban = Path()
      ..moveTo(20, 28)
      ..quadraticBezierTo(18, 0, 50, 0)
      ..quadraticBezierTo(82, 0, 80, 28)
      ..quadraticBezierTo(50, 17, 20, 28)
      ..close();
    _shape(canvas, turban, _white);
    for (final y in [8.0, 14.0, 20.0]) {
      canvas.drawPath(Path()..moveTo(24, y + 6)..quadraticBezierTo(50, y - 6, 76, y + 6), _line(1.4)..color = _robeShade);
    }
    canvas.drawPath(turban, _line());
    // طرف العمامة المتدلي
    final tail = Path()
      ..moveTo(72, 20)
      ..quadraticBezierTo(84, 34, 78, 50)
      ..quadraticBezierTo(70, 40, 68, 24)
      ..close();
    _shape(canvas, tail, _white, 2);
  }

  @override
  bool shouldRepaint(covariant ElderPainter old) =>
      old.kind != kind || old.tilt != tilt || old.bow != bow;
}
