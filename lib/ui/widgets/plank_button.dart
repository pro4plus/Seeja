// زر اللوح الخشبي (§5.3 + لوحة التصميم): لوح مسطّح بطرفين
// مدببين وخطوط خشب وظل صلب 5 بكسل؛ عنوان Reem Kufi وسطر
// توضيحي وسهم ‹. أحمر للفعل الرئيسي، خشب داكن للثانوي.
// الضغط: يغوص 4 بكسل في 70ms ثم يرتد في 140ms.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

enum PlankKind { red, dark }

class PlankButton extends StatefulWidget {
  final String label;
  final String? caption;
  final PlankKind kind;
  final VoidCallback? onPressed;

  const PlankButton({
    super.key,
    required this.label,
    this.caption,
    this.kind = PlankKind.red,
    this.onPressed,
  });

  @override
  State<PlankButton> createState() => _PlankButtonState();
}

class _PlankButtonState extends State<PlankButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _down() {
    _press.animateTo(1.0,
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut);
  }

  void _up() {
    _press.animateTo(0.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.kind == PlankKind.red
        ? SudaneseTheme.tabaqRed
        : SudaneseTheme.woodDark;
    final grain = widget.kind == PlankKind.red
        ? const Color(0xFF8A1B15)
        : const Color(0xFF2B1A12);
    return GestureDetector(
      onTapDown: (_) => _down(),
      onTapUp: (_) {
        _up();
        widget.onPressed?.call();
      },
      onTapCancel: _up,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 4 * _press.value),
            child: child,
          );
        },
        child: CustomPaint(
          painter: _PlankPainter(color: color, grain: grain),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.label,
                          style: SudaneseTheme.title.copyWith(
                            fontSize: 22,
                            color: SudaneseTheme.cream,
                          ),
                        ),
                      ),
                      if (widget.caption != null)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.caption!,
                            style: SudaneseTheme.caption.copyWith(
                              color: SudaneseTheme.cream
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.chevron_left,
                  color: SudaneseTheme.cream,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlankPainter extends CustomPainter {
  final Color color;
  final Color grain;

  const _PlankPainter({required this.color, required this.grain});

  Path _plankPath(Size size) {
    const tip = 18.0;
    return Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(tip, 0)
      ..lineTo(size.width - tip, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - tip, size.height)
      ..lineTo(tip, size.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _plankPath(size);
    // ظل صلب منزاح.
    canvas.drawPath(
      _plankPath(size).shift(const Offset(0, 5)),
      Paint()
        ..color = SudaneseTheme.earthBlack.withValues(alpha: 0.35),
    );
    // جسم الخشب بتدرج يوضح الحافة العلوية والسفلية.
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(color, Colors.white, 0.16)!,
            color,
            Color.lerp(color, Colors.black, 0.20)!,
          ],
          stops: const [0, 0.48, 1],
        ).createShader(Offset.zero & size),
    );

    // عروق خشب طويلة ومتفاوتة، مع عقدة صغيرة طبيعية.
    final grainPaint = Paint()
      ..color = grain.withValues(alpha: 0.42)
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke;
    final rng = math.Random(3);
    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.18 + i * 0.21);
      final wobble = 2 + rng.nextDouble() * 3;
      canvas.drawPath(
        Path()
          ..moveTo(23, y)
          ..cubicTo(
            size.width * 0.30, y - wobble,
            size.width * 0.64, y + wobble,
            size.width - 23, y,
          ),
        grainPaint,
      );
    }
    final knot = Offset(size.width * 0.23, size.height * 0.69);
    canvas.drawOval(
      Rect.fromCenter(center: knot, width: 13, height: 5),
      grainPaint..strokeWidth = 1,
    );

    // لمعة رفيعة على أعلى اللوح وحافة داخلية محفورة.
    canvas.drawLine(
      const Offset(23, 2),
      Offset(size.width - 23, 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..strokeWidth = 1,
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..color = SudaneseTheme.earthBlack.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _PlankPainter oldDelegate) =>
      oldDelegate.color != color;
}
