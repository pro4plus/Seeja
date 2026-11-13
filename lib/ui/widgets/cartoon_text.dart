// نص كرتوني: حشوة ملونة + خط خارجي سميك + ظل مزاح، فوق خط Reem Kufi.
import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class CartoonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fill;
  final Color outline;
  final double strokeWidth;
  final Color shadow;
  final TextAlign align;

  const CartoonText(
    this.text, {
    super.key,
    this.fontSize = 48,
    this.fill = SudaneseTheme.sunGold,
    this.outline = SudaneseTheme.outline,
    this.strokeWidth = 8,
    this.shadow = const Color(0x66000000),
    this.align = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final base = SudaneseTheme.display.copyWith(fontSize: fontSize, height: 1.15);
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, fontSize * 0.09),
          child: Text(text,
              textAlign: align,
              style: base.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..strokeJoin = StrokeJoin.round
                  ..color = shadow,
              )),
        ),
        Text(text,
            textAlign: align,
            style: base.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..strokeJoin = StrokeJoin.round
                ..color = outline,
            )),
        Text(text, textAlign: align, style: base.copyWith(color: fill)),
      ],
    );
  }
}
