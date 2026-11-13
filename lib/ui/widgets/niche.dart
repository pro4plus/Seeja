// كوّة الخصم: قوس بطابع البيوت السودانية مع إطار داخلي ولمسات نحاسية.
import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import '../painters/elder.dart';

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
    final archRadius = widget.selected ? 67.0 : 64.0;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: widget.selected ? 1 : 0.82,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(archRadius),
              bottom: const Radius.circular(16),
            ),
            border: Border.all(
              color: widget.selected
                  ? SudaneseTheme.sunGold
                  : const Color(0xFF8C6540),
              width: widget.selected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: widget.selected ? 13 : 6,
                offset: const Offset(0, 5),
              ),
              if (widget.selected)
                BoxShadow(
                  color: SudaneseTheme.sunGold.withValues(alpha: 0.28),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(archRadius - 3),
              bottom: const Radius.circular(13),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: widget.selected
                            ? const [Color(0xFF704A2B), Color(0xFF321E14)]
                            : const [Color(0xFF503522), Color(0xFF281910)],
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 11),
                    AnimatedBuilder(
                      animation: _nod,
                      builder: (context, child) {
                        final nod = _nod.value < 0.5
                            ? _nod.value * 2
                            : (1 - _nod.value) * 2;
                        return RepaintBoundary(
                          child: CustomPaint(
                            size: const Size(78, 100),
                            painter: ElderPainter(
                              kind: widget.kind,
                              tilt: nod * 0.12,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            SudaneseTheme.straw,
                            SudaneseTheme.straw.withValues(alpha: 0.88),
                          ],
                        ),
                        border: const Border(
                          top: BorderSide(
                            color: Color(0xFFE9C879),
                            width: 2,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 6,
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
                                color: SudaneseTheme.ink,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.level,
                              style: SudaneseTheme.caption.copyWith(
                                color: SudaneseTheme.ink
                                    .withValues(alpha: 0.78),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // خط داخلي رفيع يمنح الكوّة عمقاً دون تغطية الشخصية.
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(archRadius - 8),
                          bottom: const Radius.circular(9),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: widget.selected ? 0.20 : 0.09,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                // مسماران نحاسيان صغيران عند قاعدة القوس.
                Positioned(
                  top: 17,
                  left: 13,
                  child: _Rivet(active: widget.selected),
                ),
                Positioned(
                  top: 17,
                  right: 13,
                  child: _Rivet(active: widget.selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Rivet extends StatelessWidget {
  final bool active;

  const _Rivet({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFFFFD879) : const Color(0xFF9B7045),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
