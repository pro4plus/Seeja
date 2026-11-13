// كوّة الخصم: محراب خشبي مقوّس (من الرسومات الجاهزة) يتوسّطه
// رسم الخصم، وتحته لوحة خشبية داكنة بالاسم والمستوى.
// المختارة تُطلَّل بإطار ذهبي، والأخريات معتمة، وتومئ الشخصية
// برأسها عند الاختيار.
import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import '../art/art_assets.dart';
import '../painters/elder.dart';
import 'character_art.dart';

class OpponentNiche extends StatefulWidget {
  final ElderKind kind;
  final String name;
  final String level;
  final bool selected;
  final VoidCallback? onTap;

  const OpponentNiche({
    super.key,
    required this.kind,
    required this.name,
    required this.level,
    required this.selected,
    this.onTap,
  });

  @override
  State<OpponentNiche> createState() => _OpponentNicheState();
}

class _OpponentNicheState extends State<OpponentNiche>
    with SingleTickerProviderStateMixin {
  late final AnimationController _nod;

  @override
  void initState() {
    super.initState();
    _nod = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didUpdateWidget(covariant OpponentNiche oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _nod.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _nod.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Opacity(
        opacity: widget.selected ? 1.0 : 0.74,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- المحراب ----
            AspectRatio(
              aspectRatio: 300 / 420,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: ArtImage(
                      widget.selected
                          ? ArtAssets.nicheGold
                          : ArtAssets.niche,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 74),
                    child: AnimatedBuilder(
                      animation: _nod,
                      builder: (context, child) {
                        final nod = _nod.value < 0.5
                            ? _nod.value * 2
                            : (1 - _nod.value) * 2;
                        return CharacterArt(
                          kind: widget.kind,
                          tilt: nod * 0.14,
                          height: 104,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // ---- لوحة الاسم ----
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3A2418),
                borderRadius: BorderRadius.circular(10),
                boxShadow: SudaneseTheme.hardShadow(),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.name,
                      style: SudaneseTheme.heading.copyWith(
                        fontSize: 17,
                        color: const Color(0xFFF3EAD2),
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.level,
                      style: SudaneseTheme.caption.copyWith(
                        fontSize: 13,
                        color: const Color(0xFFE3C184),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
