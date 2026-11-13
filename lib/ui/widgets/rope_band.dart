// حبل مضفّر (أحمر وأسود و كريمي) يُستخدم كشريط زخرفي في شاشات
// الإعداد — كما في اللوحات المرجعية.
import 'package:flutter/material.dart';

class RopeBand extends StatelessWidget {
  final double height;

  const RopeBand({super.key, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(painter: _RopePainter()),
    );
  }
}

class _RopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final seg = h * 0.55;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF241607),
    );
    var x = 0.0;
    var i = 0;
    while (x < size.width) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, seg * 0.55, h),
        Paint()..color = i.isEven
            ? const Color(0xFFC1272D)
            : const Color(0xFFF3EAD2),
      );
      x += seg * 0.55;
      i++;
    }
    // ظلال أعلى وأسفل لإبراز الضفر.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, h * 0.18),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.82, size.width, h * 0.18),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
