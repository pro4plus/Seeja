// كوّة الخصم في شاشة الإعداد: صورة الكوّة الكاملة من حزمة
// التصميم (إطار + صورة + اسم + مستوى)، مع إطار ذهبي
// وإيماءة خفيفة عند الاختيار.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/seega_ai.dart';
import '../design_kit.dart';

class OpponentNiche extends StatefulWidget {
  final Difficulty difficulty;
  final String name;
  final String level;
  final bool selected;
  final VoidCallback onTap;

  const OpponentNiche({
    super.key,
    required this.difficulty,
    required this.name,
    required this.level,
    required this.selected,
    required this.onTap,
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
      child: AnimatedBuilder(
        animation: _nod,
        builder: (context, child) {
          final angle = math.sin(_nod.value * math.pi) * 0.05;
          return Transform.rotate(angle: angle, child: child);
        },
        child: AnimatedScale(
          scale: widget.selected ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Stack(
            children: [
              Image.asset(
                DesignKit.nicheLabelFor(widget.difficulty),
                semanticLabel: '${widget.name} · ${widget.level}',
              ),
              if (widget.selected)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      // الإطار الذهبي يغطي أعلى 780 صفاً من
                      // صورة الكوّة (860 صفاً).
                      heightFactor: 780 / 860,
                      widthFactor: 1.0,
                      child: Image.asset(
                        DesignKit.nicheFrameSelected,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
