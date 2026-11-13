// حجر كرتوني: جسم ممتلئ بخط خارجي سميك، ظل خلية (cel-shade) ولمعة زجاجية.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';

class PebblePainter extends CustomPainter {
  final PebbleDef def;
  const PebblePainter({required this.def});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final body = r * 0.88;
    final line = (r * 0.13).clamp(1.6, 4.0);

    // ظل التماس
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, r * 0.80), width: r * 1.5, height: r * 0.36),
      Paint()..color = SudaneseTheme.earthBlack.withValues(alpha: 0.28),
    );
    // الجسم
    final bodyRect = Rect.fromCenter(center: c, width: body * 2, height: body * 1.92);
    canvas.drawOval(bodyRect, Paint()..color = def.base);
    canvas.save();
    canvas.clipPath(Path()..addOval(bodyRect));
    // ظل سفلي (هلال)
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(r * 0.14, r * 0.46), width: body * 2.0, height: body * 1.3),
      Paint()..color = def.dark.withValues(alpha: 0.85),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-r * 0.05, r * 0.30), width: body * 1.9, height: body * 1.3),
      Paint()..color = def.base,
    );
    // وجه مضيء علوي
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-r * 0.22, -r * 0.34), width: body * 1.15, height: body * 0.8),
      Paint()..color = def.light.withValues(alpha: 0.9),
    );
    canvas.restore();
    // خط خارجي
    canvas.drawOval(
      bodyRect,
      Paint()
        ..color = SudaneseTheme.earthBlack
        ..style = PaintingStyle.stroke
        ..strokeWidth = line,
    );
    // لمعتان
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-r * 0.36, -r * 0.46), width: r * 0.46, height: r * 0.24),
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    canvas.drawCircle(c + Offset(-r * 0.08, -r * 0.30), r * 0.07, Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(covariant PebblePainter old) => old.def != def;
}
