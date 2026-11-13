// زر اللوح الخشبي (§5.3 + لوحة التصميم): لوح مسطّح بطرفين
// مدببين وخطوط خشب وظل صلب 5 بكسل؛ عنوان Reem Kufi وسطر
// توضيحي وسهم ‹. أحمر للفعل الرئيسي، خشب داكن للثانوي.
// الضغط: يغوص 4 بكسل في 70ms ثم يرتد في 140ms.
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
        ? const Color(0xFFF2584A)
        : const Color(0xFF3D4FB0);
    final grain = widget.kind == PlankKind.red
        ? const Color(0xFFA9261C)
        : const Color(0xFF232F7A);
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
            offset: Offset(0, 6 * _press.value),
            child: Transform.scale(
              alignment: Alignment.bottomCenter,
              scaleX: 1 + 0.04 * _press.value,
              scaleY: 1 - 0.07 * _press.value,
              child: child,
            ),
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

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width - 4, size.height - 10), Radius.circular(size.height / 2.4));
    // الحافة السفلية السميكة (3D)
    final lip = body.shift(const Offset(0, 7));
    canvas.drawRRect(lip, Paint()..color = grain);
    canvas.drawRRect(body, Paint()..color = color);
    // لمعة علوية
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(10, 5, size.width - 20, (size.height - 10) * 0.36), Radius.circular(size.height / 4)),
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );
    canvas.restore();
    final ink = Paint()
      ..color = SudaneseTheme.earthBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(body, ink);
    final lipPath = Path()
      ..moveTo(body.left + 6, body.bottom - 2)
      ..lineTo(lip.left + 6, lip.bottom)
      ..lineTo(lip.right - 6, lip.bottom)
      ..lineTo(body.right - 6, body.bottom - 2);
    canvas.drawPath(lipPath, ink);
  }

  @override
  bool shouldRepaint(covariant _PlankPainter old) =>
      old.color != color || old.grain != grain;
}
