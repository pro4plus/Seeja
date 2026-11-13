// الشخصية داخل اللعبة: تُعرض من الرسومات الجاهزة (PNG) بدل الرسم
// بالكود، مع إبقاء الحركة (التمايل والانحناء) بـ Transform.
import 'package:flutter/material.dart';

import '../art/art_assets.dart';
import '../painters/elder.dart';

/// شخصية الخصم: تميل أثناء التفكير وتنحني عند الخسارة.
class CharacterArt extends StatelessWidget {
  final ElderKind kind;

  /// زاوية التمايل بالراديان.
  final double tilt;

  /// درجة الانحناء 0..1 (تُترجم إلى إزاحة وتصغير).
  final double bow;

  /// ارتفاع الشخصية بالبكسل.
  final double height;

  /// الشخصية الجالسة (تُستخدم في الشاشة الرئيسية).
  final bool seated;

  /// تلاشٍ سفلي خفيف حتى لا تُقطع الشخصية عند حافتها السفلية.
  final bool fadeBottom;

  const CharacterArt({
    super.key,
    required this.kind,
    this.tilt = 0,
    this.bow = 0,
    this.height = 110,
    this.seated = false,
    this.fadeBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    final asset = seated
        ? ArtAssets.charSeatedTeacher
        : ArtAssets.character(kind);
    final image = ArtImage(asset, height: height, fit: BoxFit.contain);
    return Transform.rotate(
      angle: tilt,
      child: Transform.translate(
        offset: Offset(0, bow * 6),
        child: Transform.scale(
          scale: 1 - bow * 0.06,
          child: fadeBottom
              ? ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
                    stops: [0.0, 0.82, 1.0],
                  ).createShader(rect),
                  child: image,
                )
              : image,
        ),
      ),
    );
  }
}
