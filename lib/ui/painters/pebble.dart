// رسّام الحجر: بيضة لامعة بلمعة علوية وظل سفلي (نمط المرجع).
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';

class PebblePainter extends CustomPainter {
  final PebbleDef def;
  const PebblePainter({required this.def});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = math.min(size.width, size.height) / 2;
    final center = Offset(cx, cy);

    // ظل أرضي.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + r * .78), width: r * 1.3, height: r * .3),
      Paint()..color = Colors.black.withValues(alpha: .26),
    );

    // شكل البيضة: قاعدة عريضة تتجه إلى قمة مدببة.
    final egg = Path();
    const steps = 28;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final a = -math.pi / 2 + t * 2 * math.pi;
      // تضييق عند الأعلى ليصير طرف مدبب.
      final narrow = 1 - 0.22 * math.max(0, -math.sin(a));
      final rr = r * 0.96 * narrow * (1 + 0.03 * math.cos(a * 6));
      final pt = center + Offset(math.cos(a) * rr * 0.92, math.sin(a) * rr);
      if (i == 0) {
        egg.moveTo(pt.dx, pt.dy);
      } else {
        egg.lineTo(pt.dx, pt.dy);
      }
    }
    egg.close();

    canvas.drawPath(
      egg,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.34, -0.42),
          radius: 0.95,
          colors: [def.light, def.base, def.dark],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    // ظل سفلي.
    canvas.save();
    canvas.clipPath(egg);
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(r * .12, r * .48), width: r * 1.3, height: r * .6),
      Paint()..color = def.dark.withValues(alpha: .45),
    );
    // لمعة علوية.
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(-r * .3, -r * .42), width: r * .5, height: r * .26),
      Paint()..color = Colors.white.withValues(alpha: .55),
    );
    canvas.restore();
    canvas.drawCircle(
      center + Offset(-r * .12, -r * .18),
      r * .12,
      Paint()..color = Colors.white.withValues(alpha: .3),
    );
  }

  @override
  bool shouldRepaint(covariant PebblePainter oldDelegate) => oldDelegate.def != def;
}
