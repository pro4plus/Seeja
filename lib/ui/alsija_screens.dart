import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/strings.dart';

/// Play-square size in stage design units (768x1376 canvas).
/// The board container and the tests derive from this.
const double alsijaBoardSize = 600;

const ink = Color(0xff391b10);
const cream = Color(0xfff3e6c6);
const red = Color(0xffa82119);
const teal = Color(0xff229f9f);
const gold = Color(0xffdcb66a);
const blue = Color(0xff343c80);
const copper = Color(0xffbd6a40);

enum AlsijaOpponent { easy, medium, hard }

enum AlsijaColor {
  charcoal(Color(0xff484f52)),
  gold(Color(0xffcc8e29)),
  turquoise(Color(0xff29a5a9)),
  red(Color(0xffb8322c)),
  green(Color(0xff4b895d)),
  copper(Color(0xffbd6a40)),
  blue(Color(0xff343c80));

  const AlsijaColor(this.value);
  final Color value;
}

typedef AlsijaSettings = ({
  AlsijaOpponent opponent,
  int boardSize,
  AlsijaColor color,
});

Widget _at(double x, double y, double w, double h, Widget child) =>
    Positioned(left: x, top: y, width: w, height: h, child: child);

Widget _text(
  String value,
  double size, {
  Color color = ink,
  FontWeight weight = FontWeight.w800,
  int? maxLines,
}) => Text(
  value,
  maxLines: maxLines,
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: 1.08,
  ),
);

Widget _label(
  double x,
  double y,
  double w,
  double h,
  String value,
  double size, {
  Color color = ink,
  bool rotate = false,
}) => _at(
  x,
  y,
  w,
  h,
  Center(
    // The text always shrinks to its box (single line) instead of
    // wrapping into a second line that the fixed box would clip.
    // The FittedBox stays outside the RotatedBox so the fit is
    // measured against the label box, not the swapped dimensions.
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: rotate
          ? RotatedBox(
              quarterTurns: 2,
              child: _text(value, size, color: color, maxLines: 1),
            )
          : _text(value, size, color: color, maxLines: 1),
    ),
  ),
);

class _Art extends StatelessWidget {
  const _Art(this.paint);
  final void Function(Canvas, Size) paint;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _Painter(paint), child: const SizedBox.expand());
}

class _Painter extends CustomPainter {
  _Painter(this.draw);
  final void Function(Canvas, Size) draw;
  @override
  void paint(Canvas canvas, Size size) => draw(canvas, size);
  @override
  bool shouldRepaint(_Painter oldDelegate) => oldDelegate.draw != draw;
}

class _Stage extends StatelessWidget {
  const _Stage(this.children, {this.home = false});
  final List<Widget> children;
  final bool home;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: gold,
    body: SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 768,
          height: 1376,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (home)
                const ColoredBox(color: Color(0xfffffdf9))
              else
                _Art((canvas, size) => _bamboo(canvas, Offset.zero & size)),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}

Color _shade(Color c, double factor) => Color.fromARGB(
  255,
  (c.r * 255.0 * factor).round().clamp(0, 255).toInt(),
  (c.g * 255.0 * factor).round().clamp(0, 255).toInt(),
  (c.b * 255.0 * factor).round().clamp(0, 255).toInt(),
);

void _rect(Canvas c, Rect r, Color color) =>
    c.drawRect(r, Paint()..color = color);
void _oval(Canvas c, Rect r, Color color) =>
    c.drawOval(r, Paint()..color = color);
void _round(Canvas c, Rect r, double radius, Color color) => c.drawRRect(
  RRect.fromRectAndRadius(r, Radius.circular(radius)),
  Paint()..color = color,
);
void _line(Canvas c, Offset a, Offset b, Color color, double width) =>
    c.drawLine(
      a,
      b,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
void _poly(Canvas c, List<Offset> points, Color color) {
  final p = Path()..addPolygon(points, true);
  c.drawPath(p, Paint()..color = color);
}

void _dot(Canvas c, double x, double y, double r, Color color) =>
    c.drawCircle(Offset(x, y), r, Paint()..color = color);

void _bamboo(Canvas c, Rect r) {
  _rect(c, r, const Color(0xffe4bd75));
  for (var i = 0; i < r.width; i += 22) {
    final x = r.left + i;
    _rect(c, Rect.fromLTWH(x, r.top, 2, r.height), const Color(0xffa57639));
    _rect(c, Rect.fromLTWH(x + 3, r.top, 4, r.height), const Color(0xfff7d995));
    _rect(
      c,
      Rect.fromLTWH(x + 14, r.top, 2, r.height),
      const Color(0xffd1a15b),
    );
  }
}

Widget _stripe(double y) => _at(
  0,
  y,
  768,
  40,
  _Art((c, s) {
    _rect(c, Offset.zero & s, ink);
    for (var row = 0; row < 6; row++) {
      final color = const [ink, red, cream, ink, red, gold][row];
      _rect(c, Rect.fromLTWH(0, row * 6.5, s.width, 5), color);
    }
    for (var i = 0; i < 25; i++) {
      _rect(
        c,
        Rect.fromLTWH(i * 32.0, 0, 3, s.height),
        const Color(0x55301a10),
      );
    }
  }),
);

Widget _press(
  String label,
  VoidCallback? tap,
  Widget child, {
  bool? selected,
}) => Semantics(
  button: true,
  selected: selected,
  label: label,
  child: Material(
    type: MaterialType.transparency,
    child: InkWell(
      onTap: tap,
      child: ExcludeSemantics(child: child),
    ),
  ),
);

Widget _coin(IconData icon, String label, VoidCallback? tap) => _press(
  label,
  tap,
  Stack(
    fit: StackFit.expand,
    children: [
      _Art((c, s) {
        final r = Rect.fromLTWH(3, 4, s.width - 6, s.height - 15);
        _oval(c, r.shift(const Offset(0, 9)), const Color(0xff866330));
        _oval(c, r, gold);
        _oval(c, r.deflate(5), const Color(0xff744721));
        for (var i = 1; i < 5; i++) {
          final x = r.left + r.width * i / 5;
          _line(
            c,
            Offset(x, r.top + 23),
            Offset(x, r.bottom - 23),
            const Color(0x22532b14),
            2,
          );
        }
      }),
      Center(child: Icon(icon, size: 57, color: cream)),
    ],
  ),
);

Widget _plank(
  String title,
  String? subtitle,
  VoidCallback? tap, {
  bool crimson = false,
  bool angled = false,
}) {
  final color = crimson ? red : const Color(0xff56301b);
  return _press(
    title,
    tap,
    Stack(
      fit: StackFit.expand,
      children: [
        _Art((c, s) {
          final w = s.width, h = s.height;
          final path = Path();
          if (angled) {
            path.addPolygon([
              const Offset(33, 0),
              Offset(w - 33, 0),
              Offset(w, h / 2),
              Offset(w - 33, h - 8),
              Offset(33, h - 8),
              Offset(0, h / 2),
            ], true);
          } else {
            path.addRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(0, 0, w - 8, h - 8),
                const Radius.circular(9),
              ),
            );
          }
          c.drawPath(
            path.shift(const Offset(4, 8)),
            Paint()..color = const Color(0x990f0703),
          );
          c.save();
          c.clipPath(path);
          _rect(c, Offset.zero & s, color);
          for (var y = 10.0; y < h; y += 14) {
            _rect(c, Rect.fromLTWH(0, y, w, 4), _shade(color, .78));
            _rect(c, Rect.fromLTWH(0, y + 5, w, 2), _shade(color, 1.17));
          }
          c.restore();
        }),
        Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Each line fits the plank's own inner width on its
              // own: the angled plank narrows toward its top and
              // bottom edges (33px slants), so its lines must fit
              // the narrower width or the caption runs past the
              // slanted edges; the plain plank's art is inset 8px.
              final fitWidth = constraints.maxWidth - (angled ? 72 : 16);
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: fitWidth,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _text(title, 47, color: cream, maxLines: 1),
                      ),
                    ),
                    if (subtitle != null)
                      SizedBox(
                        width: fitWidth,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _text(
                            subtitle,
                            29,
                            color: cream,
                            weight: FontWeight.w600,
                            maxLines: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _disk(bool ornate) => _Art((c, s) {
  final x = s.width / 2, y = s.height / 2 - 3, r = math.min(x, y) - 2;
  _dot(c, x + 3, y + 7, r, const Color(0x66432814));
  _dot(c, x, y, r, ornate ? const Color(0xff271812) : const Color(0xff865529));
  _dot(c, x, y, r * .92, gold);
  if (!ornate) {
    _poly(c, [
      for (var i = 0; i < 16; i++)
        Offset(
          x + math.cos(i * math.pi / 8) * r * (i.isEven ? .82 : .64),
          y + math.sin(i * math.pi / 8) * r * (i.isEven ? .82 : .64),
        ),
    ], const Color(0xffa8743b));
    _dot(c, x, y, r * .42, const Color(0xff8b572a));
    return;
  }
  const colors = [
    red,
    Color(0xff25794e),
    ink,
    Color(0xffe89830),
    Color(0xffa14166),
  ];
  c.save();
  c.translate(x, y);
  for (var ring = 0; ring < colors.length; ring++) {
    final count = 44 - ring * 5;
    final distance = r * (.86 - ring * .115);
    for (var i = 0; i < count; i++) {
      c.save();
      c.rotate(i * math.pi * 2 / count);
      _rect(
        c,
        Rect.fromCenter(
          center: Offset(0, -distance),
          width: r * .073,
          height: r * .086,
        ),
        colors[ring],
      );
      c.restore();
    }
  }
  for (var i = 0; i < 12; i++) {
    c.save();
    c.rotate(i * math.pi / 6);
    _poly(c, [
      Offset(-r * .045, -r * .1),
      Offset(0, -r * .32),
      Offset(r * .045, -r * .1),
    ], const [red, teal, ink, Color(0xffe99c35)][i % 4]);
    c.restore();
  }
  _dot(c, 0, 0, r * .115, red);
  c.restore();
});

Widget _stone(Color color) => _Art((c, s) {
  final r = Rect.fromLTWH(
    s.width * .14,
    s.height * .08,
    s.width * .72,
    s.height * .79,
  );
  _oval(c, r.shift(const Offset(4, 6)), const Color(0x66321e13));
  _oval(c, r, _shade(color, .68));
  _oval(c, Rect.fromLTWH(r.left, r.top, r.width * .94, r.height * .86), color);
  _oval(
    c,
    Rect.fromLTWH(
      r.left + r.width * .18,
      r.top + r.height * .13,
      r.width * .24,
      r.height * .19,
    ),
    const Color(0x70ffffff),
  );
});

Widget _person({int variant = 1, bool seated = false}) => _Art((c, s) {
  c.save();
  c.scale(s.width / 300, s.height / 320);
  const white = Color(0xfff5efdd), fold = Color(0xffcfc6b3);
  final skin = [
    const Color(0xffa8663a),
    const Color(0xff936039),
    const Color(0xffad7545),
  ][variant];
  final robe = Path()
    ..moveTo(72, 292)
    ..quadraticBezierTo(74, 163, 134, 151)
    ..lineTo(166, 151)
    ..quadraticBezierTo(226, 163, 229, 292)
    ..close();
  if (seated) {
    _oval(c, const Rect.fromLTWH(8, 277, 284, 36), const Color(0x55482b13));
    c.scale(1, 1.02);
  }
  c.drawPath(robe, Paint()..color = white);
  if (variant == 2 && !seated) {
    _poly(c, const [
      Offset(103, 175),
      Offset(126, 156),
      Offset(130, 292),
      Offset(95, 292),
    ], const Color(0xff9c642b));
    _poly(c, const [
      Offset(174, 156),
      Offset(197, 175),
      Offset(205, 292),
      Offset(170, 292),
    ], const Color(0xff9c642b));
  }
  if (seated) {
    _oval(c, const Rect.fromLTWH(19, 236, 146, 66), white);
    _oval(c, const Rect.fromLTWH(133, 236, 148, 66), white);
    _line(c, const Offset(73, 250), const Offset(174, 284), fold, 4);
    _oval(c, const Rect.fromLTWH(103, 235, 30, 23), skin);
    _oval(c, const Rect.fromLTWH(171, 235, 30, 23), skin);
  }
  _line(c, const Offset(150, 157), const Offset(150, 231), fold, 4);
  _oval(c, const Rect.fromLTWH(137, 130, 26, 30), skin);
  _oval(c, const Rect.fromLTWH(105, 77, 90, 73), skin);
  _oval(c, const Rect.fromLTWH(99, 98, 18, 23), skin);
  _oval(c, const Rect.fromLTWH(183, 98, 18, 23), skin);
  if (variant == 0) {
    _round(c, const Rect.fromLTWH(106, 64, 88, 30), 10, gold);
    for (var i = 0; i < 7; i++) {
      _dot(c, 114 + 12.0 * i, 82, 3, const Color(0xff926135));
    }
  } else {
    _oval(c, const Rect.fromLTWH(91, 39, 118, 57), white);
    c.drawArc(
      const Rect.fromLTWH(96, 46, 108, 39),
      0,
      math.pi,
      false,
      Paint()
        ..color = fold
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }
  for (final x in const [133.0, 167.0]) {
    _dot(c, x, 107, 4, ink);
    if (variant == 1) {
      c.drawCircle(
        Offset(x, 107),
        13,
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }
  if (variant == 1) {
    _line(c, const Offset(146, 107), const Offset(154, 107), ink, 3);
  }
  if (variant == 2 || seated) {
    _poly(c, const [
      Offset(115, 120),
      Offset(133, 130),
      Offset(150, 124),
      Offset(167, 130),
      Offset(185, 120),
      Offset(173, 147),
      Offset(150, 156),
      Offset(127, 147),
    ], white);
  }
  _oval(c, const Rect.fromLTWH(140, 132, 20, 5), ink);
  c.restore();
});

/// Lantern: bright yellow glass + glow when [lit] (current player's
/// turn), dim grey-brown glass with no glow otherwise.
Widget _lantern({bool lit = true}) => _Art((c, s) {
  c.save();
  c.scale(s.width / 100, s.height / 140);
  if (lit) {
    c.drawCircle(
      const Offset(50, 74),
      45,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xffffd449), Color(0x00ffcb43)],
        ).createShader(const Rect.fromLTWH(5, 29, 90, 90)),
    );
  }
  _round(
    c,
    const Rect.fromLTWH(31, 47, 38, 63),
    13,
    lit ? const Color(0xffffd65d) : const Color(0xff8a7a5e),
  );
  c.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(20, 34, 60, 84),
      const Radius.circular(15),
    ),
    Paint()
      ..color = ink
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke,
  );
  _round(c, const Rect.fromLTWH(34, 25, 32, 27), 5, ink);
  _round(c, const Rect.fromLTWH(23, 111, 54, 13), 5, ink);
  _line(c, const Offset(30, 64), const Offset(70, 100), ink, 2);
  _line(c, const Offset(70, 64), const Offset(30, 100), ink, 2);
  c.drawCircle(
    const Offset(50, 20),
    8,
    Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );
  c.restore();
});

Widget _bowl(Color color, int count) => _Art((c, s) {
  c.save();
  c.scale(s.width / 160, s.height / 110);
  _oval(c, const Rect.fromLTWH(25, 88, 110, 18), const Color(0x55522d13));
  final bowl = Path()
    ..moveTo(2, 28)
    ..quadraticBezierTo(10, 99, 80, 98)
    ..quadraticBezierTo(150, 99, 158, 28)
    ..close();
  c.drawPath(bowl, Paint()..color = const Color(0xff9a4b26));
  _oval(c, const Rect.fromLTWH(2, 9, 156, 38), const Color(0xff6c351d));
  _oval(c, const Rect.fromLTWH(9, 12, 142, 29), const Color(0xff3a1d15));
  for (var i = 0; i < math.min(count, 8); i++) {
    final x = 29.0 + (i % 4) * 31 + (i ~/ 4) * 6;
    final y = 32.0 - (i ~/ 4) * 13 - ((i % 4).isOdd ? 1 : 0) * 4;
    _dot(c, x, y, 13, _shade(color, .8));
    _dot(c, x - 2, y - 3, 10, color);
  }
  for (var i = 0; i < 6; i++) {
    final x = 20.0 + i * 23;
    final y = 61.0 - (i - 2.5).abs() * 3;
    _line(c, Offset(x, y), Offset(x + 8, y + 1), cream, 4);
  }
  c.restore();
});

Path _arch(Rect r) => Path()
  ..moveTo(r.left, r.bottom)
  ..lineTo(r.left, r.top + r.width / 2)
  ..arcTo(
    Rect.fromLTWH(r.left, r.top, r.width, r.width),
    math.pi,
    math.pi,
    false,
  )
  ..lineTo(r.right, r.bottom)
  ..close();

Widget _landscape() => _Art((c, s) {
  final r = Offset.zero & s;
  c.drawPath(_arch(r), Paint()..color = teal);
  c.save();
  c.clipPath(_arch(Rect.fromLTWH(28, 36, s.width - 56, s.height - 36)));
  for (var i = 0; i < 7; i++) {
    _rect(
      c,
      Rect.fromLTWH(0, 35 + i * 41.0, s.width, 42),
      const [
        Color(0xff453b62),
        Color(0xff574666),
        Color(0xff714d63),
        Color(0xff86535b),
        Color(0xff985c52),
        Color(0xffa56646),
        Color(0xffbc7948),
      ][i],
    );
  }
  _dot(c, 143, 139, 36, const Color(0xffd35924));
  _rect(
    c,
    Rect.fromLTWH(0, 298, s.width, s.height - 298),
    const Color(0xffab6b32),
  );
  for (final (x, y, w) in const [(96.0, 203.0, 65.0), (170.0, 216.0, 47.0)]) {
    _poly(c, [
      Offset(x - w, 298),
      Offset(x, y),
      Offset(x + w, 298),
    ], const Color(0xff81421e));
    _poly(c, [
      Offset(x - w, 298),
      Offset(x, y),
      Offset(x - 10, 298),
    ], const Color(0xff683219));
  }
  final river = Path()
    ..moveTo(223, 280)
    ..cubicTo(421, 300, 137, 329, 88, 345)
    ..cubicTo(18, 367, 195, 390, 53, 432)
    ..lineTo(27, 564)
    ..lineTo(155, 564)
    ..cubicTo(269, 407, 164, 390, 119, 363)
    ..cubicTo(78, 342, 429, 302, 223, 280);
  c.drawPath(river, Paint()..color = const Color(0xff13768a));
  for (var i = 0; i < 8; i++) {
    _oval(
      c,
      Rect.fromLTWH(50 + (i * 37 % 75).toDouble(), 355 + i * 22.0, 24, 4),
      const Color(0xff2d9c9e),
    );
  }
  _line(
    c,
    const Offset(359, 423),
    const Offset(316, 203),
    const Color(0xff5c371e),
    19,
  );
  for (var i = 0; i < 9; i++) {
    final angle = math.pi * (1.05 + i * .24);
    final tip = Offset(316 + math.cos(angle) * 98, 203 + math.sin(angle) * 66);
    final leaf = Path()
      ..moveTo(316, 203)
      ..quadraticBezierTo((tip.dx + 316) / 2, tip.dy - 29, tip.dx, tip.dy)
      ..quadraticBezierTo((tip.dx + 316) / 2, tip.dy + 1, 316, 203);
    c.drawPath(
      leaf,
      Paint()
        ..color = i.isEven ? const Color(0xff265036) : const Color(0xff315d3b),
    );
  }
  c.restore();
  _archStitch(c, 22, 22, s.width - 44, s.height);
});

void _archStitch(Canvas c, double x, double y, double width, double bottom) {
  final center = Offset(x + width / 2, y + width / 2);
  for (var i = 0; i < 40; i++) {
    final a = math.pi + i * math.pi / 40;
    final b = a + .045;
    _line(
      c,
      center + Offset(math.cos(a), math.sin(a)) * (width / 2),
      center + Offset(math.cos(b), math.sin(b)) * (width / 2),
      red,
      5,
    );
  }
  for (var dy = center.dy; dy < bottom - 6; dy += 22) {
    _line(c, Offset(x, dy), Offset(x, dy + 10), red, 5);
    _line(c, Offset(x + width, dy), Offset(x + width, dy + 10), red, 5);
  }
}

class AlsijaHome extends StatelessWidget {
  const AlsijaHome({
    super.key,
    required this.onComputer,
    required this.onLocal,
    this.onSettings,
    this.onHowTo,
    this.onAbout,
    this.onTikTok,
    this.isArabic = true,
  });
  final VoidCallback onComputer, onLocal;
  final VoidCallback? onSettings, onHowTo, onAbout, onTikTok;
  final bool isArabic;

  Strings get _s => Strings(isArabic);

  @override
  Widget build(BuildContext context) => _Stage([
    _at(25, 28, 96, 105, _coin(Icons.settings, _s.settings, onSettings)),
    _label(145, 57, 482, 150, _s.homeTitle, 132, color: red),
    _label(
      139,
      50,
      482,
      150,
      _s.homeTitle,
      132,
      color: const Color(0xff28234c),
    ),
    _label(
      119,
      203,
      530,
      56,
      _s.homeSubtitle,
      36,
      color: const Color(0xff28234c),
    ),
    _at(177, 279, 414, 566, _landscape()),
    for (final x in const [29.0, 620.0])
      for (var i = 0; i < 3; i++)
        _at(x, 294 + i * 156.0, 120, 126, _disk(i != 1)),
    _at(0, 829, 768, 547, const ColoredBox(color: gold)),
    _at(
      30,
      850,
      708,
      154,
      _Art((c, s) {
        final rug = Path()
          ..addPolygon([
            const Offset(108, 0),
            Offset(s.width - 108, 0),
            Offset(s.width, s.height),
            Offset(0, s.height),
          ], true);
        c.save();
        c.clipPath(rug);
        _bamboo(c, Offset.zero & s);
        for (final x in [0.0, s.width - 165]) {
          _rect(c, Rect.fromLTWH(x, 0, 165, s.height), red);
          _rect(c, Rect.fromLTWH(x + 14, 0, 130, s.height), ink);
        }
        c.restore();
      }),
    ),
    _at(222, 541, 324, 351, _person(variant: 2, seated: true)),
    _at(
      232,
      860,
      304,
      118,
      _Art((c, s) {
        _round(c, Offset.zero & s, 18, const Color(0xffb48545));
        _round(c, Rect.fromLTWH(3, 1, s.width - 6, s.height - 13), 14, gold);
        for (var r = 0; r < 5; r++) {
          for (var col = 0; col < 7; col++) {
            final x = 27 + col * 41.0, y = 14 + r * 19.0;
            _oval(
              c,
              Rect.fromCenter(center: Offset(x, y), width: 28, height: 13),
              const Color(0xff986833),
            );
            if ((r + col) % 3 == 0) {
              _oval(
                c,
                Rect.fromCenter(
                  center: Offset(x, y - 2),
                  width: 22,
                  height: 12,
                ),
                col < 3 ? blue : copper,
              );
            }
          }
        }
      }),
    ),
    _at(
      103,
      1024,
      562,
      130,
      _plank(
        _s.playVsComputer,
        _s.playVsComputerCaption,
        onComputer,
        crimson: true,
        angled: true,
      ),
    ),
    _at(
      103,
      1165,
      562,
      130,
      _plank(
        _s.playVsFriend,
        _s.playVsFriendCaption,
        onLocal,
        angled: true,
      ),
    ),
    for (final (x, w, text, tap) in [
      (502.0, 200.0, _s.howToPlay, onHowTo),
      (350.0, 153.0, _s.aboutGame, onAbout),
      (67.0, 282.0, _s.tiktokLink, onTikTok),
    ])
      _at(
        x,
        1310,
        w,
        59,
        _press(
          text,
          tap,
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _text(text, 30, maxLines: 1),
            ),
          ),
        ),
      ),
  ], home: true);
}

class AlsijaSetup extends StatefulWidget {
  const AlsijaSetup({
    super.key,
    required this.onBack,
    required this.onStart,
    this.lockedColor,
    this.initialColor = AlsijaColor.blue,
    this.initialBoardSize = 5,
    this.title,
    this.isArabic = true,
    this.showOpponents = true,
  });

  final VoidCallback onBack;
  final ValueChanged<AlsijaSettings> onStart;
  final bool isArabic;

  /// Opponent niches (Sheikh / Wad El-Balad / Teacher) are
  /// computer-opponent choices: shown vs computer, hidden in
  /// two-player setup (the original showed them vs computer only).
  final bool showOpponents;

  /// لون مقفل لا يُختار (حجر اللاعب 1 في خطوة اللاعب 2).
  final AlsijaColor? lockedColor;

  /// اللون وحجم اللوحة الافتتاحيان — يُستعاد بهما اختيار
  /// الخطوة الأولى عند الرجوع إليها.
  final AlsijaColor initialColor;
  final int initialBoardSize;

  /// عنوان اللوحة الخشبية أعلى الشاشة (افتراضياً «اجلس للعب»).
  final String? title;

  Strings get strings => Strings(isArabic);

  @override
  State<AlsijaSetup> createState() => _SetupState();
}

class _SetupState extends State<AlsijaSetup> {
  AlsijaOpponent opponent = AlsijaOpponent.medium;
  late int boardSize;
  late AlsijaColor color;

  @override
  void initState() {
    super.initState();
    boardSize = widget.initialBoardSize;
    color = widget.initialColor;
  }

  Widget _opponent(AlsijaOpponent option) {
    final i = option.index, active = option == opponent;
    final strings = widget.strings;
    final name = [
      strings.elderYoung,
      strings.elderTeacher,
      strings.elderElder,
    ][i];
    final level = [strings.easy, strings.medium, strings.hard][i];
    return _press(
      '$name${widget.isArabic ? '، ' : ', '}$level',
      () => setState(() => opponent = option),
      Stack(
        fit: StackFit.expand,
        children: [
          _Art((c, s) {
            final r = Rect.fromLTWH(0, 0, s.width, s.height - 49);
            c.drawPath(
              _arch(r.shift(const Offset(16, 17))),
              Paint()..color = const Color(0x55422916),
            );
            c.drawPath(
              _arch(r),
              Paint()
                ..color = active
                    ? const Color(0xffeec05e)
                    : const Color(0xff633a27),
            );
            c.drawPath(
              _arch(r.deflate(7)),
              Paint()..color = const Color(0xff321a14),
            );
            _round(
              c,
              Rect.fromLTWH(5, s.height - 107, s.width - 10, 52),
              5,
              ink,
            );
          }),
          _at(-39, 1, 283, 293, _person(variant: i)),
          _label(0, 250, 204, 59, name, 35, color: cream),
          _label(0, 310, 204, 46, level, 31, color: cream),
        ],
      ),
      selected: active,
    );
  }

  Widget _board(int n) {
    final active = boardSize == n;
    return _press(
      '$n × $n',
      () => setState(() => boardSize = n),
      Stack(
        fit: StackFit.expand,
        children: [
          _Art((c, s) {
            if (active) {
              c.drawCircle(
                const Offset(112, 112),
                106,
                Paint()
                  ..color = red
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 9,
              );
            }
            final r = Rect.fromLTWH(
              n == 5 ? 29 : 17,
              n == 5 ? 28 : 16,
              n == 5 ? 168 : 192,
              n == 5 ? 168 : 192,
            );
            _round(c, r.shift(const Offset(8, 9)), 12, const Color(0x7850321b));
            _round(c, r, 10, ink);
            final grid = r.deflate(12);
            _round(c, grid, 4, gold);
            for (var i = 1; i < n; i++) {
              final x = grid.left + grid.width * i / n,
                  y = grid.top + grid.height * i / n;
              _line(c, Offset(x, grid.top), Offset(x, grid.bottom), ink, 2);
              _line(c, Offset(grid.left, y), Offset(grid.right, y), ink, 2);
            }
          }),
          _label(
            0,
            218,
            225,
            48,
            n == 5 ? widget.strings.board5Short : widget.strings.board7Short,
            34,
          ),
        ],
      ),
      selected: active,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Without the opponent niches (two-player setup) the board,
    // colour and start sections move up so no empty band is left
    // where the niches were.
    final compact = !widget.showOpponents;
    final boardLabelY = compact ? 180.0 : 592.0;
    final boardY = compact ? 245.0 : 646.0;
    final trayY = compact ? 600.0 : 945.0;
    final diskY = compact ? 860.0 : 1144.0;
    final goY = compact ? 907.0 : 1191.0;
    final strings = widget.strings;
    return _Stage([
      _stripe(81),
      _at(
        24,
        24,
        95,
        106,
        _coin(Icons.arrow_back, strings.back, widget.onBack),
      ),
      _at(
        209,
        36,
        350,
        84,
        _plank(widget.title ?? strings.sitToPlay, null, null),
      ),
      if (widget.showOpponents) ...[
        _label(200, 145, 368, 60, strings.againstWho, 45),
        for (final option in AlsijaOpponent.values)
          _at(42 + option.index * 239.0, 215, 204, 355, _opponent(option)),
      ],
      _label(250, boardLabelY, 268, 56, strings.boardSection, 48),
      _at(127, boardY, 225, 266, _board(5)),
      _at(418, boardY + 4, 225, 266, _board(7)),
      _at(
        60,
        trayY,
        648,
        171,
        _Art((c, s) {
          _round(c, Offset.zero & s, 23, const Color(0xff49251b));
          _round(
            c,
            Rect.fromLTWH(15, 17, s.width - 30, s.height - 42),
            17,
            const Color(0xff2b1510),
          );
        }),
      ),
      for (final choice in AlsijaColor.values)
        _at(
          88 + choice.index * 85.0,
          choice == color ? trayY - 30 : trayY + 26,
          80,
          103,
          _press(
            strings.pebbleColorNames[choice.index],
          choice == widget.lockedColor
              ? null
              : () => setState(() => color = choice),
          Opacity(
            opacity: choice == widget.lockedColor ? 0.35 : 1.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: choice != color
                      ? null
                      : BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: gold, width: 6),
                        ),
                  child: _stone(choice.value),
                ),
                if (choice == widget.lockedColor)
                  const Icon(Icons.lock, size: 30, color: cream),
              ],
            ),
          ),
          selected: choice == color,
        ),
      ),
    _stripe(1227),
    _at(283, diskY, 202, 208, _disk(false)),
    _at(
      327,
      goY,
      114,
      116,
      _press(
        strings.letsGo,
        () {
          widget.onStart((
            opponent: opponent,
            boardSize: boardSize,
            color: color,
          ));
        },
        DecoratedBox(
          decoration: BoxDecoration(
            color: red,
            shape: BoxShape.circle,
            border: Border.all(color: ink, width: 6),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _text(strings.letsGo, 49, color: cream, maxLines: 1),
              ),
            ),
          ),
        ),
      ),
    ),
    ]);
  }
}

enum AlsijaPiece { player, opponent }

typedef AlsijaCell = ({int row, int column});

const _referencePieces = <List<AlsijaPiece?>>[
  [
    AlsijaPiece.player,
    null,
    AlsijaPiece.player,
    AlsijaPiece.opponent,
    AlsijaPiece.opponent,
  ],
  [
    AlsijaPiece.opponent,
    AlsijaPiece.player,
    AlsijaPiece.opponent,
    null,
    AlsijaPiece.opponent,
  ],
  [
    AlsijaPiece.player,
    AlsijaPiece.opponent,
    AlsijaPiece.player,
    null,
    AlsijaPiece.player,
  ],
  [
    AlsijaPiece.player,
    AlsijaPiece.opponent,
    AlsijaPiece.player,
    AlsijaPiece.player,
    AlsijaPiece.opponent,
  ],
  [
    AlsijaPiece.player,
    AlsijaPiece.player,
    AlsijaPiece.opponent,
    AlsijaPiece.player,
    AlsijaPiece.opponent,
  ],
];

class AlsijaGame extends StatefulWidget {
  const AlsijaGame({
    super.key,
    this.cells = _referencePieces,
    this.selected,
    this.targets = const {},
    this.playerColor = blue,
    this.opponentColor = copper,
    this.playerRemaining = 12,
    this.opponentRemaining = 12,
    this.playerCaptured = 0,
    this.opponentCaptured = 0,
    this.playerTurn = true,
    this.soundEnabled = true,
    this.opponent = AlsijaOpponent.medium,
    this.onCell,
    this.onPause,
    this.onSound,
    this.onHint,
    this.onUndo,
    this.board,
    this.hud,
    this.vsComputer = true,
    this.player1Name,
    this.player2Name,
    this.turnLabel,
    this.isPlacing = false,
    this.placedThisTurn = 0,
    this.isAiThinking = false,
    this.isArabic = true,
  });

  final List<List<AlsijaPiece?>> cells;
  final AlsijaCell? selected;
  final Set<AlsijaCell> targets;
  final Color playerColor, opponentColor;
  final int playerRemaining,
      opponentRemaining,
      playerCaptured,
      opponentCaptured;
  final bool playerTurn, soundEnabled;
  final AlsijaOpponent opponent;
  final void Function(int row, int column)? onCell;
  final VoidCallback? onPause, onSound, onHint, onUndo;
  final Widget? board;
  final List<Widget>? hud;

  /// Two-player mode: the top shows the second player's plaque
  /// instead of the computer figure.
  final bool vsComputer;

  /// Null resolves to the localized defaults (You / Opponent).
  final String? player1Name, player2Name;
  final bool isArabic;

  /// Full turn-line text (computed by the screen from the real
  /// phase/player, e.g. «الدور: اللاعب 1 — ضع 3 أحجار»).
  /// Null keeps the old «دورك…» / «دور الخصم» fallback.
  final String? turnLabel;
  final bool isPlacing;
  final int placedThisTurn;
  final bool isAiThinking;

  @override
  State<AlsijaGame> createState() => _AlsijaGameState();
}

class _AlsijaGameState extends State<AlsijaGame>
    with TickerProviderStateMixin {
  // نبض نقاط التفكير في سطر الدور فقط — اللوحة الحقيقية
  // (SandBoard) تملك حركاتها هي، وهذه الشاشة بلا حركات.
  late final AnimationController _pulseController;

  Strings get _s => Strings(widget.isArabic);
  String get _p1Name => widget.player1Name ?? _s.you;
  String get _p2Name => widget.player2Name ?? _s.computer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------- اللوحة

  /// لوحة ثابتة للمعاينة فقط (خلفية النتيجة الافتراضية):
  /// الإطار الخشبي والخلايا والحجارة من widget.cells، بلا أي
  /// حركة — في اللعبة تُستبدل بلوحة الرمل الأصلية (SandBoard)
  /// عبر معامل board، فهذه اللوحة لا تُبنى هناك أبداً.
  Widget _board() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _Art((c, s) {
          final r = (Offset.zero & s).deflate(9);
          _round(c, r.shift(const Offset(8, 10)), 70, const Color(0x66724820));
          _round(c, r, 70, const Color(0xffa4773b));
          final face = r.deflate(8);
          c.drawRRect(
            RRect.fromRectAndRadius(face, const Radius.circular(64)),
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xffefd198), Color(0xffd5a85e)],
              ).createShader(face),
          );
        }),
        if (widget.cells.isNotEmpty && widget.cells.first.isNotEmpty)
          _at(
            70,
            80,
            460,
            440,
            Column(
              children: [
                for (final (row, line) in widget.cells.indexed)
                  Expanded(
                    child: Row(
                      children: [
                        for (final (column, piece) in line.indexed)
                          Expanded(child: _cell(row, column, piece)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------- الخلية

  /// خلية ثابتة للوحة المعاينة: تجويف + حجر، وحلقة ذهبية
  /// ثابتة حول الحجر المحدد وحلقة خضراء ثابتة على الوجهة —
  /// بلا حركة (الحركات كلها في SandBoard).
  Widget _cell(int row, int column, AlsijaPiece? piece) {
    final cell = (row: row, column: column);
    final active = widget.selected == cell;
    final target = widget.targets.contains(cell);
    return _press(
      _s.tileLabel(row, column),
      widget.onCell == null ? null : () => widget.onCell!(row, column),
      Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          _Art((c, s) {
            final center = s.center(Offset.zero);
            final radius = math.min(s.width, s.height) * .39;
            final hole = Rect.fromCircle(center: center, radius: radius);
            c.drawCircle(
              center,
              radius + 1,
              Paint()..color = const Color(0xff9e7039),
            );
            c.drawCircle(
              center,
              radius - 1,
              Paint()
                ..shader = const RadialGradient(
                  center: Alignment(.2, .35),
                  radius: .75,
                  colors: [Color(0xffd9b87c), Color(0xffa47941)],
                ).createShader(hole),
            );
          }),
          if (target)
            Positioned.fill(
              child: FractionallySizedBox(
                widthFactor: .78,
                heightFactor: .78,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffc5df88).withValues(alpha: 0.35),
                    border: Border.all(
                      color: const Color(0xff629c52),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
          if (piece != null)
            Positioned.fill(
              child: FractionallySizedBox(
                widthFactor: .69,
                heightFactor: .69,
                child: Container(
                  decoration: active
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: gold, width: 3),
                        )
                      : null,
                  child: _stone(
                    piece == AlsijaPiece.player
                        ? widget.playerColor
                        : widget.opponentColor,
                  ),
                ),
              ),
            ),
        ],
      ),
      selected: active,
    );
  }

  List<Widget> _counter(
    double x,
    double y,
    Color color,
    int number,
    bool captured, {
    bool rotateLabel = false,
  }) => [
    _at(x, y, 164, 116, _bowl(color, number)),
    _label(
      x - 5,
      y + 116,
      174,
      48,
      '${captured ? _s.captured : _s.remaining} $number',
      36,
      rotate: rotateLabel,
    ),
  ];

  // ---------------------------------------------------------- لوحة اللاعب

  /// One player's plaque (stone + name + «دورك» on their turn +
  /// lantern, lit on their turn). The top plaque and the bottom
  /// bar are the SAME widget, so they look identical. In
  /// two-player mode the top plaque is rotated 180° so player 2
  /// reads it right-side-up from their side (its rect does not
  /// move, so nothing can overlap the coins).
  Widget _playerPlaque({
    required Color stoneColor,
    required String name,
    required bool isTurn,
    bool rotate = false,
  }) {
    final inner = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xffe5cb8d),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ink, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            SizedBox(width: 76, height: 76, child: _stone(stoneColor)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _text(name, 44),
                  ),
                  if (isTurn) _text(_s.yourTurn, 28, color: red),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(width: 70, height: 100, child: _lantern(lit: isTurn)),
          ],
        ),
      ),
    );
    return rotate ? RotatedBox(quarterTurns: 2, child: inner) : inner;
  }

  // ---------------------------------------------------------- سطر الدور

  Widget _turnLine() {
    final label = widget.turnLabel ??
        (widget.playerTurn ? _s.turnLineChoose : _s.turnOf(_p2Name));
    return _at(
      68,
      950,
      632,
      64,
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _text(label, 42),
            ),
          ),
          if (widget.isPlacing) ...[
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final filled = i < widget.placedThisTurn;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? (widget.playerTurn
                            ? widget.playerColor
                            : widget.opponentColor)
                        : const Color(0xff8a6d4b),
                    border: Border.all(color: ink, width: 1),
                  ),
                );
              }),
            ),
          ],
          if (widget.isAiThinking) ...[
            const SizedBox(width: 8),
            _thinkingDots(),
          ],
        ],
      ),
    );
  }

  Widget _thinkingDots() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_pulseController.value * 3 - i).clamp(0.0, 1.0);
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ink.withValues(alpha: 0.3 + 0.7 * (1 - phase)),
              ),
            );
          }),
        );
      },
    );
  }

  // ---------------------------------------------------------- البناء

  @override
  Widget build(BuildContext context) => _Stage([
    _stripe(172),
    _at(18, 24, 117, 122, _coin(Icons.pause, _s.pause, widget.onPause)),
    _at(
      634,
      24,
      117,
      122,
      _coin(
        widget.soundEnabled ? Icons.volume_up : Icons.volume_off,
        _s.sound,
        widget.onSound,
      ),
    ),
    // Top: vs computer keeps the person figure + lantern; two
    // players get the second player's plaque (rotated so player 2
    // reads it). The counters sit at the same place in both modes
    // — below the coins, never over them — with only their labels
    // rotated in 2P; in 2P the two counters swap sides so each
    // player sees «باقي» on their right, as in the original.
    if (widget.vsComputer) ...[
      _at(
        254,
        5,
        260,
        327,
        _person(variant: widget.opponent.index, seated: true),
      ),
      _at(470, 180, 100, 148, _lantern(lit: !widget.playerTurn)),
      ..._counter(5, 160, widget.playerColor, widget.opponentCaptured, true),
      ..._counter(
        599,
        160,
        widget.opponentColor,
        widget.opponentRemaining,
        false,
      ),
    ] else ...[
      _at(
        150,
        24,
        468,
        110,
        _playerPlaque(
          stoneColor: widget.opponentColor,
          name: _p2Name,
          isTurn: !widget.playerTurn,
          rotate: true,
        ),
      ),
      ..._counter(
        5,
        160,
        widget.opponentColor,
        widget.opponentRemaining,
        false,
        rotateLabel: true,
      ),
      ..._counter(
        599,
        160,
        widget.playerColor,
        widget.opponentCaptured,
        true,
        rotateLabel: true,
      ),
    ],
    _at(84, 340, alsijaBoardSize, alsijaBoardSize, widget.board ?? _board()),
    _turnLine(),
    ..._counter(42, 1024, widget.opponentColor, widget.playerCaptured, true),
    ..._counter(563, 1024, widget.playerColor, widget.playerRemaining, false),
    if (widget.vsComputer) ...[
      _at(
        262,
        1032,
        101,
        108,
        _coin(Icons.lightbulb_outline, _s.hint, widget.onHint),
      ),
      _at(
        405,
        1032,
        101,
        108,
        _coin(Icons.reply, _s.undo, widget.onUndo),
      ),
      _label(258, 1140, 110, 48, _s.hint, 36),
      _label(399, 1140, 110, 48, _s.undo, 36),
    ],
    // Bottom bar: the same plaque as the top one (player 1).
    _at(
      150,
      1200,
      468,
      110,
      _playerPlaque(
        stoneColor: widget.playerColor,
        name: _p1Name,
        isTurn: widget.playerTurn,
      ),
    ),
    _at(
      0,
      1321,
      768,
      55,
      _Art((c, s) {
        _rect(c, Offset.zero & s, ink);
        for (var x = 0.0; x < s.width; x += 21) {
          _dot(c, x + 6, 3, 5, gold);
          for (var i = 0; i < 3; i++) {
            _line(
              c,
              Offset(x + 6, 8),
              Offset(x + i * 6, s.height - 4 - i * 2),
              gold,
              3,
            );
          }
        }
      }),
    ),
    if (widget.hud != null) ...widget.hud!,
  ]);
}

enum AlsijaOutcome { win, loss, draw }

class AlsijaResult extends StatelessWidget {
  const AlsijaResult({
    super.key,
    required this.onReplay,
    required this.onHome,
    this.outcome = AlsijaOutcome.win,
    this.wins = 3,
    this.losses = 1,
    this.draws = 0,
    this.background,
    this.scoreCards,
    this.isArabic = true,
  });

  final VoidCallback onReplay, onHome;
  final AlsijaOutcome outcome;
  final int wins, losses, draws;
  final Widget? background, scoreCards;
  final bool isArabic;

  Strings get _s => Strings(isArabic);

  @override
  Widget build(BuildContext context) => _Stage([
    Positioned.fill(
      child: IgnorePointer(
        child: ExcludeSemantics(child: background ?? const AlsijaGame()),
      ),
    ),
    const ColoredBox(color: Color(0xa4281b11)),
    _at(
      0,
      376,
      768,
      1000,
      _Art((c, s) {
        c.drawPath(_arch(Offset.zero & s), Paint()..color = teal);
        c.drawPath(
          _arch(Rect.fromLTWH(20, 24, s.width - 40, s.height - 24)),
          Paint()..color = cream,
        );
        _archStitch(c, 36, 42, s.width - 72, s.height);
      }),
    ),
    _at(219, 257, 330, 329, _disk(true)),
    _at(
      0,
      0,
      768,
      444,
      IgnorePointer(
        child: _Art((c, s) {
          final random = math.Random(47);
          const colors = [cream, teal, red, gold, Color(0xff437b45)];
          for (var i = 0; i < 21; i++) {
            final x = random.nextDouble() * s.width,
                y = random.nextDouble() * s.height;
            if (x > 210 && x < 560 && y > 260) continue;
            final turn = random.nextDouble() * math.pi * 2;
            c.save();
            c.translate(x, y);
            c.rotate(turn);
            _poly(c, const [
              Offset(-15, -8),
              Offset(14, -9),
              Offset(-2, 20),
            ], colors[i % colors.length]);
            c.restore();
          }
        }),
      ),
    ),
    _label(
      58,
      605,
      652,
      111,
      switch (outcome) {
        AlsijaOutcome.win => _s.victory,
        AlsijaOutcome.loss => _s.betterLuck,
        AlsijaOutcome.draw => _s.draw,
      },
      86,
      color: red,
    ),
    _label(70, 716, 628, 62, switch (outcome) {
      AlsijaOutcome.win => _s.youWon,
      AlsijaOutcome.loss => _s.tryAgain,
      AlsijaOutcome.draw => _s.drawSubtitle,
    }, 40),
    if (scoreCards != null)
      _at(72, 814, 624, 134, scoreCards!)
    else
      for (final (index, (title, value)) in [
        (_s.draws, draws),
        (_s.losses, losses),
        (_s.wins, wins),
      ].indexed)
        _at(
          72 + index * 214.0,
          814,
          196,
          134,
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffe5cb8d),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _text('$value', 52),
                const SizedBox(height: 9),
                _text(title, 30),
              ],
            ),
          ),
        ),
    _at(
      82,
      1005,
      611,
      132,
      _plank(_s.playAgain, _s.playAgainCaption, onReplay, crimson: true),
    ),
    _at(82, 1153, 611, 121, _plank(_s.backHome, null, onHome)),
  ]);
}
