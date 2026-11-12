import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';
import '../../game/sound_manager.dart';

class PlankButton extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const PlankButton({super.key, required this.title, this.subtitle, this.color = SudaneseTheme.tabaqRed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundManager.tap();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SudaneseTheme.earthBlack, width: 2),
          boxShadow: const [BoxShadow(color: SudaneseTheme.earthBlack, offset: Offset(0, 5), blurRadius: 0)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(title, style: const TextStyle(fontFamily: 'ReemKufi', fontSize: 21, color: SudaneseTheme.cream, fontWeight: FontWeight.bold)),
                  ),
                  if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 13, color: SudaneseTheme.cream.withOpacity(0.9))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: SudaneseTheme.cream, size: 28),
          ],
        ),
      ),
    );
  }
}
