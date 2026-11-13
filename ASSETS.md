# مكتبة الرسومات (SVG + PNG)

كل الرسومات في اللعبة **مرسومة بالأكواد**: كل أصل له ملف SVG مكتوب يدوياً
أو مولَّد رياضياً، ثم يُصدَّر إلى PNG بدقة عالية (`3x`) لاستخدامه داخل Flutter
عبر `Image.asset` (بلا أي حزمة خارجية).

```
assets/
  svg/     # المصادر (قابلة للتعديل) — 33 ملفاً
  png/     # النسخة الجاهزة للاستخدام داخل اللعبة (3x)
tools/
  gen_art.py       # توليد الأصول الهندسية: الحجارة، عجلة الطبق، الطبق، الأيقونات
  gen_decor.py     # الديكور: المحاريب، الأطباق، الفانوس، الحصيرة، الجدار، مشهد الباب
  svg_to_png.py    # تصدير كل SVG إلى PNG عبر كروميوم (Playwright)
  preview_sheet.py # ورقة معاينة لميع الأصول في صفحة واحدة
```

## إعادة التوليد

```bash
python3 tools/gen_art.py       # الحجارة + الطبق + الأيقونات
python3 tools/gen_decor.py     # الديكور
python3 tools/svg_to_png.py 3  # تصدير PNG بدقة 3x
python3 tools/preview_sheet.py # ورقة المعاينة assets/preview_sheet.png
```

## الشخصيات

| الملف | الوصف | الاستخدام |
|---|---|---|
| `char_boy.svg` | ود البلد — كحية صغيرة مطرزة، بشرة بنية، ابتسامة خفيفة | كوّة الخصم (سهل) |
| `char_teacher.svg` | الأستاذ — عمامة بيضاء، نظارة دائرية، لحية قصيرة | كوّة الخصم (وسط) |
| `char_sheikh.svg` | الشيخ — عمامة كبيرة، لحية بيضاء طويلة، ستر جلدي | كوّة الخصم (صعب) |
| `char_seated_teacher.svg` | الأستاذ جالساً (رجلان متقاطعتان) | الشاشة الرئيسية |

## الديكور والأيقونات

`niche` / `niche_gold` (المحراب الذهبي على شكل كبسولة) — `plate` (طبق
بحلقات مربعات) و`plate_star` (طبق بنجمة ثمانية) — `wall_wood` (جدار
الألواح الخشبية) — `arch_scene`
(مشهد الباب: غروب، شمس، أهرامات، نيل، نخلة) — `plate` و`tabaq_wheel`
(الطبق وعجلته) — `bowl_empty` و`bowl_stones_blue` و`bowl_stones_brown`
(الصحن الطيني) — `lantern_lit` و`lantern_off` (الفانوس) — `mat` (الحصيرة)
— `wall_planks` (جدار القصب، قابل للتكرار) — `pedestal` (منصة النصر).

الأيقونات: `icon_pause` · `icon_play` · `icon_sound_on` · `icon_sound_off` ·
`icon_back` · `icon_bulb` · `icon_undo` · `icon_gear`.

الحجارة السبعة (نفس ترتيب `SudaneseTheme.pebbles`):
`stone_indigo` · `stone_clay` · `stone_green` · `stone_red` ·
`stone_turquoise` · `stone_ochre` · `stone_charcoal`.

## الاستخدام داخل Flutter

```dart
import 'ui/art/art_assets.dart';

// صورة أصل جاهزة
ArtImage(ArtAssets.charTeacher, height: 110);

// شخصية تتحرك (تمايل وانحناء)
CharacterArt(kind: ElderKind.teacher, tilt: 0.08, bow: 0.5, height: 112);

// محراب الخصم
OpponentNiche(kind: ElderKind.elder, name: 'الشيخ', level: 'صعب', selected: true, onTap: () {});
```

`ArtAssets` في `lib/ui/art/art_assets.dart` — كل المسارات في مكان واحد،
و`ArtImage` يرسم بـ `FilterQuality.high` مع دعم تكرار النمط (للجدار القصبي).

## لوحة الألوان

| اللون | الرمز | الاستخدام |
|---|---|---|
| أحمر الطبق | `#B3261E` | الأشرطة، الأزرار الحمراء، الصحون |
| تركوازي النيل | `#1AA3A8` | إطارات الأبواب، الحجر الفيروزي |
| ذهبي الشمس | `#F2C14E` | الإطار الذهبي، التلميحات، التوهج |
| خشب غامق | `#3A2418` | لوحات الأسماء، interiors الكوات |
| خشب | `#7A4A22` | المحراب، الأعمدة |
| قش | `#D9B36A` | الجدار القصبي، الحصيرة |
| جلباب كريمي | `#F5E6C4` | القماش والشعارات |

## ملاحظات

- الأصول تُستخدم عبر `Image.asset` فلا حاجة لأي حزمة إضافية (لا `flutter_svg`).
- الرسومات المتحركة (الشخصيات في اللعب، الفانوس، الصحون، اللوح) تبقى
  بـ `CustomPainter` في `lib/ui/painters/` لأنها تعتمد على الحالة، والرسومات
  الجاهزة تُستخدم للأجزاء الساكنة (المحاريب، الطبق، الحجارة، الخلفية).
- لمعرض داخل اللعبة: **معرض الرسومات** في أسفل الشاشة الرئيسية.

## عناصر مرسومة بالكود داخل اللعبة

| الملف | العنصر |
|---|---|
| `lib/ui/painters/wall.dart` | الجدار المبيّض + الباب المقوّس + المشهد + الأطباق (حلقات مربعات ونجمة) |
| `lib/ui/painters/plank_wall.dart` | جدار الألواح الخشبية (خلفية الإعداد) |
| `lib/ui/painters/board.dart` | لوح الرمل وحفره المجوّفة |
| `lib/ui/painters/pebble.dart` | الحجر البيضوي اللامع |
| `lib/ui/painters/bowl.dart` | الصحن الطيني بشريط الغرزة |
| `lib/ui/painters/lantern.dart` | الفانوس المضيء |
| `lib/ui/painters/mat.dart` | جدار القصب والحبال المضفّرة |
| `lib/ui/widgets/rope_band.dart` | الحبل المضفّر (أحمر/أسود/كريمي) |
| `lib/ui/painters/tabaq.dart` | الطبقان وعجلة المربعات |

## مقارنة بالأصل

`docs/compare_reference_vs_ours.png` — المقارنة جنباً إلى جنب بين اللقطات
المرجعيةالمرفوعة ونتيجة هذا المشروع.
