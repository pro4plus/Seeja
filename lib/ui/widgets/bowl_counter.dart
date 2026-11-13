// عدّاد الصحن (§5.3 + لوحة التصميم): صحن طيني فيه حصوات
// بلون الحجارة الموجودة فيه فعلاً، وتحته التسمية والعدد
// (أكلت N / باقي M).
import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import '../painters/bowl.dart';

class BowlCounter extends StatelessWidget {
  final PebbleDef pebble;
  final int count;
  final String label;

  const BowlCounter({
    super.key,
    required this.pebble,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      padding: const EdgeInsets.fromLTRB(4, 5, 4, 6),
      decoration: BoxDecoration(
        color: SudaneseTheme.cream.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: SudaneseTheme.wood.withValues(alpha: 0.72),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: SudaneseTheme.earthBlack.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              size: const Size(64, 50),
              painter: BowlPainter(pebble: pebble, count: count),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SudaneseTheme.bodyBold.copyWith(
              fontSize: 11,
              color: SudaneseTheme.woodDark,
            ),
          ),
          Text(
            '$count',
            style: SudaneseTheme.heading.copyWith(
              fontSize: 18,
              color: SudaneseTheme.tabaqRed,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}
