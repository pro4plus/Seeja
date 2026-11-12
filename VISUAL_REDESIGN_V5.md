# إعادة التصميم البصري v5 — نوفمبر 2026

استبدال الرسومات المتجهة بالكود بصور مولّدة (WebP) للخلفيات
والشخصيات والرمل، مع بقاء كل شيء آخر كما هو: القواعد، المحرك،
الذكاء، الأصوات، التخطيط، النصوص، الأزرار، تدفق الشاشات،
والنسخة 4.0.0+1.

## قاعدة بلا عيون

كل الوجوه بلا عيون — في الصور المولّدة وفي الرسم القديم.
صُحّح `lib/ui/painters/elder.dart` رغم تقاعده: حُذفت العينان
واللمعتان البيضاوان من `_paintFace` وحُذفت `_paintGlasses`
واستدعاؤها (للأستاذ). لا تُضف عيوناً إلى أي صورة أو رسم جديد.

## الصور (assets/images/، كلها WebP)

| الملف | الحجم | الاستخدام |
| --- | --- | --- |
| bg_home.webp | 1184×2096 (9:16) | الرئيسية (الجزء العلوي فقط) + شاشة البداية |
| bg_wall.webp | 1152×2048 (9:16) | خلفية الإعداد واللعب |
| portrait_young.webp | 1600×1600 | ود البلد (سهل) |
| portrait_teacher.webp | 1600×1600 | الأستاذ (وسط) |
| portrait_elder.webp | 1600×1600 | الشيخ (صعب) + باب الرئيسية |
| sand_texture.webp | 1600×1600 | تحت لوحة الرمل |
| reed_mat.webp | 1600×1600 | نسيج البرش في الرئيسية |

## ما تغيّر في كل ملف

- `lib/ui/widgets/game_images.dart` (جديد): ثوابت مسارات الصور،
  `enum ElderKind` (نُقل من elder.dart)، `portraitAsset(kind)`،
  `DuskBackdrop` (صورة كاملة الشاشة + تعتيم + محتوى)،
  `OpponentPortrait` (قصّ بقوس علوي).
- `lib/screens/splash_screen.dart`: خلفية `DuskBackdrop(bgHome)` تتلاشى
  مع قيمة المتحكم؛ العنوان المسحي والتلاشي الفرعي والتوقيت 2.2 ث
  والانتقال كما هي. حُذفت متغيرات الشمس والتوهج والأطباق.
- `lib/screens/home_screen.dart`: التخطيط كما في v4 (جدار 42% فوق،
  برش ممتد تحت). الجدار يعرض الجزء العلوي فقط من bg_home
  (`ClipRect` + `Align` بعامل ارتفاع 0.51 + `BoxFit.fitWidth`)،
  والشيخ صورة `portrait_elder` (110×140، قصّ بقوس علوي) في الباب.
  البرش صورة `reed_mat.webp`. حُذفت حركة تمايل النخلة والمتحكم `_sway`.
- `lib/screens/setup_screen.dart`: خلفية `DuskBackdrop(bgWall, dim 0.28)`؛
  حُذف `_SetupMatPainter`. الكوات واللوحتان والصينية وزر «يلا» كما هي.
- `lib/ui/widgets/niche.dart`: `OpponentPortrait` (78×100) بدل
  `ElderPainter`، مع بقاء إيماءة الرأس عبر `Transform.rotate`.
- `lib/screens/game_screen.dart`: خلفية `DuskBackdrop(bgWall, dim 0.30)`؛
  `_OpponentFigure` تستخدم `OpponentPortrait` (92×118) مع الميل
  عبر `Transform.rotate` والانحناء عبر `Transform.translate`.
- `lib/ui/sand_board.dart`: طبقة `ClipRRect` بصورة `sand_texture.webp`
  تحت `BoardPainter`، مع `drawSlab: false`.
- `lib/ui/painters/board.dart`: معامل `drawSlab` (افتراضي true)؛
  اللوح والحبيبات والحواف داخل `if (drawSlab)`، والحُفر ونجمة
  الوسطى تُرسمان دائماً. `shouldRepaint` يشمل `drawSlab`.
- `lib/ui/painters/pebble.dart`: تلميع فقط — هلال سفلي أعمق
  (شفافية 0.72) ولمعة علوية أقوى (0.95).
- `lib/ui/painters/elder.dart`: مصحَّح بلا عيون وبلا نظارات (أعلاه)،
  و`ElderKind` نُقل إلى game_images.dart. الملف متقاعد وغير مستخدم.
- `lib/ui/painters/wall.dart` و`mat.dart`: متقاعدان، غير مستوردَين
  من أي مكان، وبقي الملفان في الشجرة (لا تُحذف الملفات).
- `pubspec.yaml`: الصور السبع أعلاه في `flutter/assets`؛
  الأصوات (21) والخطوط بلا تغيير.
- `integration_test/screenshot_test.dart` (جديد): لقطات ذهبية
  `home.png` و`setup.png` و`game.png` و`result.png` على سطح 390×844،
  بضخّات يدوية (لا `pumpAndSettle`) وتحميل مسبق للصور.
- `.github/workflows/screenshots.yml` (جديد): عند push على
  `visual-redesign-v5` فقط — `flutter analyze` + `flutter test` +
  تحديث اللقطات، ورفع `integration_test/goldens/` كأرتيفاكت
  (حتى عند الفشل، `if: always()`).

## التحقق

- لا يوجد Flutter SDK في بيئة العمل هذه، فلم يُنفَّذ `flutter analyze`
  ولا `flutter test` ولا بناء اللقطات محلياً — التحقق يدوي:
  إعادة قراءة كل ملف معدَّل كاملاً، توازن الأقواس، كل استيراد
  مستخدم، كل مسار أصل يطابق ملفاً موجوداً في `assets/images/`.
- اللقطات الذهبية غير مولَّدة بعد: تُولَّد أول مرة عبر
  `flutter test --update-goldens integration_test/screenshot_test.dart`
  في CI (سير عمل Screenshots v5).
