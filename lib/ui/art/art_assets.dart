// مكتبة الأصول المرسومة (SVG/PNG) — مركز واحد لأصول الرسومات.
// الملفات المصدرية في assets/svg، والنسخ المرسومة في assets/png
// (تُولَّد بالأداة tools/svg_to_png.py). كل الأصول مرفقة في pubspec.
import 'package:flutter/material.dart';

import '../painters/elder.dart';

/// مسارات الأصول المستخدمة داخل اللعبة.
class ArtAssets {
  ArtAssets._();

  static const String pngFolder = 'assets/png';
  static const String svgFolder = 'assets/svg';

  // ---- الشخصيات ----
  static const String charBoy = '$pngFolder/char_boy.png';
  static const String charTeacher = '$pngFolder/char_teacher.png';
  static const String charSheikh = '$pngFolder/char_sheikh.png';
  static const String charSeatedTeacher =
      '$pngFolder/char_seated_teacher.png';

  /// صورة الشخصية حسب نوعها.
  static String character(ElderKind kind) {
    switch (kind) {
      case ElderKind.young:
        return charBoy;
      case ElderKind.teacher:
        return charTeacher;
      case ElderKind.elder:
        return charSheikh;
    }
  }

  // ---- الحجارة (نفس ترتيب SudaneseTheme.pebbles) ----
  static const List<String> stones = [
    '$pngFolder/stone_indigo.png',
    '$pngFolder/stone_clay.png',
    '$pngFolder/stone_green.png',
    '$pngFolder/stone_red.png',
    '$pngFolder/stone_turquoise.png',
    '$pngFolder/stone_ochre.png',
    '$pngFolder/stone_charcoal.png',
  ];

  static String stone(int index) => stones[index.clamp(0, stones.length - 1)];

  // ---- الديكور ----
  static const String niche = '$pngFolder/niche.png';
  static const String nicheGold = '$pngFolder/niche_gold.png';
  static const String plate = '$pngFolder/plate.png';
  static const String plateStar = '$pngFolder/plate_star.png';
  static const String wallWood = '$pngFolder/wall_wood.png';
  static const String tabaqWheel = '$pngFolder/tabaq_wheel.png';
  static const String archScene = '$pngFolder/arch_scene.png';
  static const String lanternLit = '$pngFolder/lantern_lit.png';
  static const String lanternOff = '$pngFolder/lantern_off.png';
  static const String bowlEmpty = '$pngFolder/bowl_empty.png';
  static const String mat = '$pngFolder/mat.png';
  static const String wallPlanks = '$pngFolder/wall_planks.png';
  static const String pedestal = '$pngFolder/pedestal.png';

  // ---- الأيقونات ----
  static const String iconPause = '$pngFolder/icon_pause.png';
  static const String iconPlay = '$pngFolder/icon_play.png';
  static const String iconSoundOn = '$pngFolder/icon_sound_on.png';
  static const String iconSoundOff = '$pngFolder/icon_sound_off.png';
  static const String iconBack = '$pngFolder/icon_back.png';
  static const String iconBulb = '$pngFolder/icon_bulb.png';
  static const String iconUndo = '$pngFolder/icon_undo.png';
  static const String iconGear = '$pngFolder/icon_gear.png';
}

/// عرض أصل مرسوم (PNG) بجودة عالية، بلا تشويش عند التكبير.
class ArtImage extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;

  /// تكرار النمط (للجدار القصبي مثلاً).
  final ImageRepeat repeat;

  const ArtImage(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );
  }
}

/// غلاف جاهز لعرض الأصول في شبكة (معرض الرسومات).
class ArtTile extends StatelessWidget {
  final String asset;
  final String label;

  const ArtTile({super.key, required this.asset, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC79A4E), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ArtImage(asset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF5E3A20),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
