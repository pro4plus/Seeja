// معرض الرسومات: يعرض كل الأصول المرسومة (شخصيات وديكورات وأيقونات)
// داخل اللعبة، للمراجعة السريعة قبل النشر.
import 'package:flutter/material.dart';

import '../ui/art/art_assets.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  static final List<(String, String)> _items = [
    (ArtAssets.charBoy, 'ود البلد'),
    (ArtAssets.charTeacher, 'الأستاذ'),
    (ArtAssets.charSheikh, 'الشيخ'),
    (ArtAssets.charSeatedTeacher, 'الأستاذ جالساً'),
    (ArtAssets.niche, 'المحراب'),
    (ArtAssets.nicheGold, 'المحراب المختار'),
    (ArtAssets.archScene, 'مشهد الباب'),
    (ArtAssets.plate, 'الطبق'),
    (ArtAssets.plateStar, 'الطبق النجمي'),
    (ArtAssets.wallWood, 'جدار الخشب'),
    (ArtAssets.tabaqWheel, 'عجلة الطبق'),
    (ArtAssets.bowlEmpty, 'الصحن الفارغ'),
    (ArtAssets.lanternLit, 'الفانوس المضاء'),
    (ArtAssets.lanternOff, 'الفانوس المطفأ'),
    (ArtAssets.mat, 'الحصيرة'),
    (ArtAssets.wallPlanks, 'جدار القصب'),
    (ArtAssets.pedestal, 'المنصة'),
    (ArtAssets.stones[0], 'حجر نيلي'),
    (ArtAssets.stones[1], 'حجر طيني'),
    (ArtAssets.stones[2], 'حجر أخضر'),
    (ArtAssets.stones[3], 'حجر أحمر'),
    (ArtAssets.stones[4], 'حجر فيروزي'),
    (ArtAssets.stones[5], 'حجر كهرماني'),
    (ArtAssets.stones[6], 'حجر فحمي'),
    (ArtAssets.iconPause, 'إيقاف'),
    (ArtAssets.iconSoundOn, 'صوت'),
    (ArtAssets.iconBack, 'رجوع'),
    (ArtAssets.iconBulb, 'تلميح'),
    (ArtAssets.iconUndo, 'تراجع'),
    (ArtAssets.iconGear, 'إعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9AF67),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A2418),
        foregroundColor: const Color(0xFFF3EAD2),
        title: const Text('معرض الرسومات'),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemCount: _items.length,
          itemBuilder: (context, i) {
            final (asset, label) = _items[i];
            return ArtTile(asset: asset, label: label);
          },
        ),
      ),
    );
  }
}
