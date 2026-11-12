import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';
import '../../game/sound_manager.dart';

class WoodToken extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final double size;

  const WoodToken({super.key, required this.icon, this.label, required this.onTap, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundManager.tap();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: SudaneseTheme.mudBrickDark,
              shape: BoxShape.circle,
              border: Border.all(color: SudaneseTheme.straw, width: 3),
              boxShadow: const [BoxShadow(color: SudaneseTheme.earthBlack, offset: Offset(0, 3), blurRadius: 0)],
            ),
            child: Icon(icon, color: SudaneseTheme.cream, size: size * 0.52),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(label!, style: const TextStyle(color: SudaneseTheme.earthBlack, fontSize: 13, fontWeight: FontWeight.bold)),
          ]
        ],
      ),
    );
  }
}
