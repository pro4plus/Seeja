// خلفية اللعب الكرتونية: برش مبهج بمعينات ملونة وحدود سميكة وشريط علوي وأهداب سفلية.
import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';

class MatPainter extends CustomPainter {
  final bool topThread;
  final bool fringe;
  const MatPainter({this.topThread = false, this.fringe = false});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFD98A));
    const cell = 46.0;
    final fill = [
      const Color(0xFFFFC857),
      const Color(0xFFFF9F68),
      const Color(0xFF7ED6C6),
    ];
    final line = Paint()
      ..color = SudaneseTheme.woodDark.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round;
    var row = 0;
    for (var y = -cell / 2; y < size.height + cell; y += cell / 2) {
      final off = (row % 2 == 0) ? 0.0 : cell / 2;
      var col = 0;
      for (var x = -cell + off; x < size.width + cell; x += cell) {
        final d = Path()
          ..moveTo(x, y - cell / 2)
          ..lineTo(x + cell / 2 * 0.9, y)
          ..lineTo(x, y + cell / 2)
          ..lineTo(x - cell / 2 * 0.9, y)
          ..close();
        canvas.drawPath(d, Paint()..color = fill[(row + col) % 3].withValues(alpha: 0.55));
        canvas.drawPath(d, line);
        col++;
      }
      row++;
    }
    // تعتيم لطيف حتى تبرز اللوحة
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFF1CF).withValues(alpha: 0.35));
    if (topThread) {
      final y = size.height * 0.12;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 8), Paint()..color = SudaneseTheme.woodDark);
      canvas.drawRect(Rect.fromLTWH(0, y + 2, size.width, 4), Paint()..color = const Color(0xFFE4493B));
    }
    if (fringe) {
      final base = size.height - 14;
      for (var x = 4.0; x < size.width; x += 9) {
        canvas.drawLine(
          Offset(x, base),
          Offset(x + ((x ~/ 9) % 2 == 0 ? 1.5 : -1.5), base + 12),
          Paint()
            ..color = SudaneseTheme.woodDark
            ..strokeWidth = 3.2
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant MatPainter old) =>
      old.topThread != topThread || old.fringe != fringe;
}
