// رسّام الحجر: قرص مزيّن بلون الحجر — شكل حجر الحزمة الجديدة
// (AlsijaGame._stone): ظل، وقاعدة داكنة، وقرص باللون نفسه،
// ولمعة بيضاء أعلى اليسار. الواجهة كما في الأصل (PebbleDef).
import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

/// تفتيح/تغميم لون — نفس صيغة _shade في شاشة الحزمة.
Color _shade(Color c, double factor) => Color.fromARGB(
  255,
  (c.r * 255.0 * factor).round().clamp(0, 255).toInt(),
  (c.g * 255.0 * factor).round().clamp(0, 255).toInt(),
  (c.b * 255.0 * factor).round().clamp(0, 255).toInt(),
);

class PebblePainter extends CustomPainter {
  final PebbleDef def;

  const PebblePainter({required this.def});

  @override
  void paint(Canvas canvas, Size size) {
    final color = def.base;
    final r = Rect.fromLTWH(
      size.width * .14,
      size.height * .08,
      size.width * .72,
      size.height * .79,
    );
    // ظل القرص.
    canvas.drawOval(
      r.shift(Offset(size.width * .05, size.height * .06)),
      Paint()..color = const Color(0x66321e13),
    );
    // قاعدة داكنة ثم القرص باللون نفسه.
    canvas.drawOval(r, Paint()..color = _shade(color, .68));
    canvas.drawOval(
      Rect.fromLTWH(r.left, r.top, r.width * .94, r.height * .86),
      Paint()..color = color,
    );
    // لمعة بيضاء أعلى اليسار.
    canvas.drawOval(
      Rect.fromLTWH(
        r.left + r.width * .18,
        r.top + r.height * .13,
        r.width * .24,
        r.height * .19,
      ),
      Paint()..color = const Color(0x70ffffff),
    );
  }

  @override
  bool shouldRepaint(covariant PebblePainter oldDelegate) =>
      oldDelegate.def != def;
}
