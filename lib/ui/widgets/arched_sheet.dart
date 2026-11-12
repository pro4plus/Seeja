import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';

class ArchedSheet extends StatelessWidget {
  final Widget child;
  final Widget? topBadge;

  const ArchedSheet({super.key, required this.child, this.topBadge});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(top: topBadge != null ? 44 : 0),
          padding: EdgeInsets.fromLTRB(22, topBadge != null ? 54 : 28, 22, 24),
          decoration: BoxDecoration(
            color: SudaneseTheme.cream,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(140)),
            border: Border.all(color: SudaneseTheme.nubianTurquoise, width: 6),
            boxShadow: const [BoxShadow(color: SudaneseTheme.earthBlack, offset: Offset(0, -4), blurRadius: 12)],
          ),
          child: child,
        ),
        if (topBadge != null) Positioned(top: 0, child: topBadge!),
      ],
    );
  }
}
