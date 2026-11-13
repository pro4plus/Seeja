// مسارات صور حزمة التصميم + هندسة اللوحة المقاسة من PNG.
// كل الأصول تحت assets/design/png/ (المسجلة في pubspec).
// هندسة الثقوب: قِيست من board_5x5.png وboard_7x7.png
// (1040×1040) بتحليل البكسلات — مركز أول ثقب وخطوة
// الشبكة ككسر من عرض الصورة.
import 'package:flutter/material.dart';

import '../game/seega_ai.dart';

class DesignKit {
  static const String _base = 'assets/design/png';

  // ---- الخلفيات ----
  static const String bgHome =
      '$_base/backgrounds/bg_home_wall_and_floor.png';
  static const String bgStraw =
      '$_base/backgrounds/bg_straw_mat_768x1376.png';
  static const String rugStripes =
      '$_base/backgrounds/rug_stripes.png';
  static const String bandWeave =
      '$_base/backgrounds/band_weave_red_black.png';

  // ---- الشعار والباب ----
  static const String logo = '$_base/logo/logo_alseeja.png';
  static const String doorWithElder =
      '$_base/scene/door_with_elder.png';

  // ---- أطباق الجدار ----
  static const String plateRainbow = '$_base/plates/tabaq_rainbow.png';
  static const String plateRed = '$_base/plates/tabaq_red.png';
  static const String plateStar = '$_base/plates/tabaq_star.png';

  // ---- الشخصيات ----

  /// صورة صدرية للخصم حسب المستوى.
  static String portraitFor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '$_base/characters/portrait_young.png';
      case Difficulty.medium:
        return '$_base/characters/portrait_teacher.png';
      case Difficulty.hard:
        return '$_base/characters/portrait_elder.png';
    }
  }

  /// كوّة الخصم الكاملة (إطار + صورة + اسم + مستوى) حسب المستوى.
  static String nicheLabelFor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '$_base/ui/niche_young_label.png';
      case Difficulty.medium:
        return '$_base/ui/niche_teacher_label.png';
      case Difficulty.hard:
        return '$_base/ui/niche_elder_label.png';
    }
  }

  /// إطار الكوّة المختارة (ذهبي) — نفس أبعاد إطار الصورة أعلاه.
  static const String nicheFrameSelected =
      '$_base/ui/niche_frame_selected.png';

  // ---- الحصى ----
  // الترتيب هو ترتيب SudaneseTheme.pebbles:
  // نيلي، طيني، أخضر، أحمر، فيروزي، كهرماني، فحمي.
  static const List<String> pebbleAssets = [
    '$_base/pebbles/pebble_indigo.png',
    '$_base/pebbles/pebble_clay.png',
    '$_base/pebbles/pebble_green.png',
    '$_base/pebbles/pebble_red.png',
    '$_base/pebbles/pebble_turquoise.png',
    '$_base/pebbles/pebble_ochre.png',
    '$_base/pebbles/pebble_charcoal.png',
  ];

  static String pebbleAsset(int index) => pebbleAssets[index];

  // ---- اللوحة وعلاماتها ----
  static String boardAsset(int size) {
    if (size == 7) {
      return '$_base/board/board_7x7.png';
    }
    return '$_base/board/board_5x5.png';
  }

  static const String markerDestination =
      '$_base/board/marker_destination.png';
  static const String markerSelected =
      '$_base/board/marker_selected_ring.png';
  static const String markerCentre =
      '$_base/board/marker_centre_star.png';
  static const String markerLastMove =
      '$_base/board/marker_last_move.png';

  // ---- الصحون والفانوس ----
  static const String bowlEmpty = '$_base/objects/bowl_empty.png';
  static const String bowlIndigo =
      '$_base/objects/bowl_indigo_stones.png';
  static const String bowlBrown =
      '$_base/objects/bowl_brown_stones.png';
  static const String lantern = '$_base/objects/lantern.png';
  static const String lanternLit = '$_base/objects/lantern_lit.png';

  // ---- الأزرار والرموز ----
  static const String btnPlankRed =
      '$_base/ui/btn_plank_red_label.png';
  static const String btnPlankDark =
      '$_base/ui/btn_plank_dark_label.png';
  static const String btnRectRed =
      '$_base/ui/btn_rect_red_label.png';
  static const String btnRectBrown =
      '$_base/ui/btn_rect_brown_label.png';
  static const String btnYalla =
      '$_base/ui/btn_yalla_round_label.png';
  static const String headerPlank =
      '$_base/ui/header_plank_label.png';
  static const String tokenBack = '$_base/ui/token_back.png';
  static const String tokenSettings =
      '$_base/ui/token_settings.png';
  static const String tokenPause = '$_base/ui/token_pause.png';
  static const String tokenSound = '$_base/ui/token_sound.png';
  static const String tokenSoundOff =
      '$_base/ui/token_sound_off.png';
  static const String tokenHint = '$_base/ui/token_hint.png';
  static const String tokenUndo = '$_base/ui/token_undo.png';
  static const String turnBanner = '$_base/ui/turn_banner.png';
  static const String turnBannerYou =
      '$_base/ui/turn_banner_you.png';
  static const String turnLantern =
      '$_base/ui/turn_indicator_lantern.png';
  static const String selectionRingRed =
      '$_base/ui/selection_ring_red.png';
  static const String boardSize5 = '$_base/ui/board_size_5x5.png';
  static const String boardSize7 = '$_base/ui/board_size_7x7.png';
  static const String trayEmpty = '$_base/ui/pebble_tray_empty.png';
  static const String resultSheet =
      '$_base/ui/result_sheet_arch.png';
  static const String resultTitle =
      '$_base/ui/result_title_mabrook.png';
  static const String statCard = '$_base/ui/stat_card.png';

  static const List<String> confettiFlags = [
    '$_base/ui/confetti_flag_1.png',
    '$_base/ui/confetti_flag_2.png',
    '$_base/ui/confetti_flag_3.png',
    '$_base/ui/confetti_flag_4.png',
  ];

  // ---- هندسة ثقوب اللوحة (كسر من عرض صورة اللوحة) ----
  // لوحة 5×5: مراكز الثقوب عند x=161.1 وy=148.6 بخطوة 179.15.
  static const double board5x0 = 161.1 / 1040;
  static const double board5y0 = 148.6 / 1040;
  static const double board5pitch = 179.15 / 1040;
  // لوحة 7×7: مراكز الثقوب عند x=135.5 وy=126.6 بخطوة 128.0.
  static const double board7x0 = 135.5 / 1040;
  static const double board7y0 = 126.6 / 1040;
  static const double board7pitch = 128.0 / 1040;

  static double holeX0(int size) {
    if (size == 7) {
      return board7x0;
    }
    return board5x0;
  }

  static double holeY0(int size) {
    if (size == 7) {
      return board7y0;
    }
    return board5y0;
  }

  static double holePitch(int size) {
    if (size == 7) {
      return board7pitch;
    }
    return board5pitch;
  }

  /// خطوة الشبكة بالبكسلات داخل مربع لوحة عرضه boardPx.
  static double holePitchPx(int size, double boardPx) {
    return holePitch(size) * boardPx;
  }

  /// مركز خلية (r,c) داخل مربع لوحة عرضه boardPx.
  static Offset holeCenter(int size, double boardPx, int r, int c) {
    final double pitch = holePitchPx(size, boardPx);
    return Offset(
      holeX0(size) * boardPx + c * pitch,
      holeY0(size) * boardPx + r * pitch,
    );
  }
}

/// زر من صورة (نصها مدمج فيها): يغوص قليلاً عند الضغط،
/// ومعه تسمية نصية لقارئ الشاشة والاختبارات.
class KitImageButton extends StatefulWidget {
  final String asset;
  final String semanticLabel;
  final double width;
  final VoidCallback? onPressed;

  const KitImageButton({
    super.key,
    required this.asset,
    required this.semanticLabel,
    required this.width,
    this.onPressed,
  });

  @override
  State<KitImageButton> createState() => _KitImageButtonState();
}

class _KitImageButtonState extends State<KitImageButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _down = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _down = false;
        });
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() {
          _down = false;
        });
      },
      child: AnimatedScale(
        scale: _down ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: Image.asset(
          widget.asset,
          width: widget.width,
          semanticLabel: widget.semanticLabel,
        ),
      ),
    );
  }
}
