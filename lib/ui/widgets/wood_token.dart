// زر خشبي دائري (§5.3): قرص خشب بحافة قش وأيقونة كريمية
// منقوشة. للقائمة والصوت والإعدادات والرجوع والتلميح والتراجع.
import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class WoodToken extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  const WoodToken({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 52,
    this.tooltip,
  });

  @override
  State<WoodToken> createState() => _WoodTokenState();
}

class _WoodTokenState extends State<WoodToken> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) {
          setState(() => _down = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _down = false),
        child: AnimatedScale(
          scale: _down ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.35, -0.42),
                radius: 0.95,
                colors: [
                  Color(0xFFB77B43),
                  Color(0xFF80502C),
                  Color(0xFF3E2416),
                ],
                stops: [0, 0.62, 1],
              ),
              border: Border.all(
                color: SudaneseTheme.sunGold,
                width: 2.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.36),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: SudaneseTheme.straw.withValues(alpha: 0.34),
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SudaneseTheme.straw.withValues(alpha: 0.58),
                      width: 1,
                    ),
                  ),
                ),
                Icon(
                  widget.icon,
                  color: SudaneseTheme.cream,
                  size: widget.size * 0.46,
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 3, offset: Offset(1, 2)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
