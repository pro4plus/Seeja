// عدّاد الصحن (§5.3 + حزمة التصميم): صحن طيني فيه حصوات
// بلون الحجارة الموجودة فيه فعلاً، وتحته التسمية والعدد
// (أكلت N / باقي M).
import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import '../design_kit.dart';

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

  // مراكز عنقود الحصوات داخل فتحة الصحن (كسر من
  // أبعاد صورة الصحن) للألوان التي لا صحن جاهز لها.
  static const List<(double, double)> _cluster = [
    (0.30, 0.16),
    (0.50, 0.10),
    (0.68, 0.16),
    (0.40, 0.30),
    (0.60, 0.30),
  ];

  @override
  Widget build(BuildContext context) {
    final index = SudaneseTheme.pebbles.indexOf(pebble);
    final String bowlAsset;
    if (count == 0) {
      bowlAsset = DesignKit.bowlEmpty;
    } else if (index == 0) {
      bowlAsset = DesignKit.bowlIndigo;
    } else if (index == 1) {
      bowlAsset = DesignKit.bowlBrown;
    } else {
      bowlAsset = DesignKit.bowlEmpty;
    }
    final bool cluster = count > 0 && index > 1;
    const double bowlW = 64;
    const double bowlH = bowlW * 280 / 440;
    const double pebblePx = bowlW * 0.20;
    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: bowlW,
            height: bowlH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  bowlAsset,
                  fit: BoxFit.fill,
                ),
                if (cluster)
                  for (final pos in _cluster)
                    Positioned(
                      left: pos.$1 * bowlW - pebblePx / 2,
                      top: pos.$2 * bowlH - pebblePx / 2,
                      width: pebblePx,
                      height: pebblePx,
                      child: Image.asset(
                        DesignKit.pebbleAsset(index),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$label $count',
              style: SudaneseTheme.bodyBold.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
