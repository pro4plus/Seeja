// صور إعادة التصميم البصري v5: خلفيات مولّدة وصور شخصيات
// بلا عيون (قاعدة v5: كل الوجوه بلا عيون — لا عيون مرسومة
// ولا نظارات). المسارات هنا هي المصدر الوحيد لأسماء الملفات.
import 'package:flutter/material.dart';

/// نوع شخصية الخصم (نُقل من elder.dart إلى هنا في v5).
enum ElderKind { young, teacher, elder }

const String bgHome = 'assets/images/bg_home.webp';
const String bgWall = 'assets/images/bg_wall.webp';
const String sandTexture = 'assets/images/sand_texture.webp';

/// نسيج البرش في الرئيسية (1600×1600).
const String reedMat = 'assets/images/reed_mat.webp';

const String portraitYoung = 'assets/images/portrait_young.png';
const String portraitTeacher = 'assets/images/portrait_teacher.png';
const String portraitElder = 'assets/images/portrait_elder.png';

String portraitAsset(ElderKind kind) {
  switch (kind) {
    case ElderKind.young:
      return portraitYoung;
    case ElderKind.teacher:
      return portraitTeacher;
    case ElderKind.elder:
      return portraitElder;
  }
}

/// خلفية غسق بصورة كاملة الشاشة + تعتيم اختياري + المحتوى فوقها.
class DuskBackdrop extends StatelessWidget {
  final String image;
  final Widget child;
  final double dim;

  const DuskBackdrop({
    super.key,
    required this.image,
    required this.child,
    this.dim = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          image,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        if (dim > 0)
          Container(color: Colors.black.withValues(alpha: dim)),
        child,
      ],
    );
  }
}

/// صورة شخصية الخصم مقصوصة بقوس علوي، بلا عيون.
class OpponentPortrait extends StatelessWidget {
  final ElderKind kind;
  final double width;
  final double height;

  const OpponentPortrait({
    super.key,
    required this.kind,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(70)),
      child: Image.asset(
        portraitAsset(kind),
        width: width,
        height: height,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
    );
  }
}
