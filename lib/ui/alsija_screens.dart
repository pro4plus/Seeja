import 'dart:math' as math;

import 'package:flutter/material.dart';

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
}) => Text(
  value,
  textDirection: TextDirection.rtl,
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
}) => _at(x, y, w, h, Center(child: _text(value, size, color: color)));

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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _text(title, 47, color: cream),
                if (subtitle != null)
                  _text(subtitle, 29, color: cream, weight: FontWeight.w600),
              ],
            ),
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

Widget _lantern() => _Art((c, s) {
  c.save();
  c.scale(s.width / 100, s.height / 140);
  c.drawCircle(
    const Offset(50, 74),
    45,
    Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xffffd449), Color(0x00ffcb43)],
      ).createShader(const Rect.fromLTWH(5, 29, 90, 90)),
  );
  _round(c, const Rect.fromLTWH(31, 47, 38, 63), 13, const Color(0xffffd65d));
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
  });
  final VoidCallback onComputer, onLocal;
  final VoidCallback? onSettings, onHowTo, onAbout, onTikTok;

  @override
  Widget build(BuildContext context) => _Stage([
    _at(25, 28, 96, 105, _coin(Icons.settings, 'الإعدادات', onSettings)),
    _label(145, 57, 482, 150, 'السيجا', 132, color: red),
    _label(139, 50, 482, 150, 'السيجا', 132, color: const Color(0xff28234c)),
    _label(
      119,
      203,
      530,
      56,
      'السودانية • لعبة الحصار والدهاء',
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
        'العب ضد الكمبيوتر',
        'اجلس قبالة الشيخ وجرّب حظك',
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
        'لاعبان على جهاز واحد',
        'تحدّ صديقك وجهاً لوجه',
        onLocal,
        angled: true,
      ),
    ),
    for (final (x, w, text, tap) in [
      (502.0, 200.0, 'طريقة اللعب', onHowTo),
      (350.0, 153.0, 'عن اللعبة', onAbout),
      (67.0, 282.0, 'تيك توك @nubax', onTikTok),
    ])
      _at(x, 1310, w, 59, _press(text, tap, Center(child: _text(text, 30)))),
  ], home: true);
}

class AlsijaSetup extends StatefulWidget {
  const AlsijaSetup({super.key, required this.onBack, required this.onStart});
  final VoidCallback onBack;
  final ValueChanged<AlsijaSettings> onStart;
  @override
  State<AlsijaSetup> createState() => _SetupState();
}

class _SetupState extends State<AlsijaSetup> {
  AlsijaOpponent opponent = AlsijaOpponent.medium;
  int boardSize = 5;
  AlsijaColor color = AlsijaColor.blue;

  Widget _opponent(AlsijaOpponent option) {
    final i = option.index, active = option == opponent;
    final name = const ['ود البلد', 'الأستاذ', 'الشيخ'][i];
    final level = const ['سهل', 'وسط', 'صعب'][i];
    return _press(
      '$name، $level',
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
          _label(0, 218, 225, 48, n == 5 ? '٥×٥ • سريعة' : '٧×٧ • طويلة', 34),
        ],
      ),
      selected: active,
    );
  }

  @override
  Widget build(BuildContext context) => _Stage([
    _stripe(81),
    _at(24, 24, 95, 106, _coin(Icons.arrow_back, 'رجوع', widget.onBack)),
    _at(209, 36, 350, 84, _plank('اجلس للعب', null, null)),
    _label(200, 145, 368, 60, 'ضد من ؟', 45),
    for (final option in AlsijaOpponent.values)
      _at(42 + option.index * 239.0, 215, 204, 355, _opponent(option)),
    _label(250, 592, 268, 56, 'اللوحة', 48),
    _at(127, 646, 225, 266, _board(5)),
    _at(418, 650, 225, 266, _board(7)),
    _at(
      60,
      945,
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
        choice == color ? 915 : 971,
        80,
        103,
        _press(
          const ['رمادي',
            'ذهبي',
            'فيروزي',
            'أحمر',
            'أخضر',
            'نحاسي',
            'أزرق',
          ][choice.index],
          () => setState(() => color = choice),
          Container(
            decoration: choice != color
                ? null
                : BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold, width: 6),
                  ),
            child: _stone(choice.value),
          ),
          selected: choice == color,
        ),
      ),
    _stripe(1227),
    _at(283, 1144, 202, 208, _disk(false)),
    _at(
      327,
      1191,
      114,
      116,
      _press(
        'يلا',
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
          child: Center(child: _text('يلا', 49, color: cream)),
        ),
      ),
    ),
  ]);
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

/// Animation triggers for [AlsijaGame], mirroring the original BoardFx:
/// nonce-based so the same move can be re-triggered. The widget owns the
/// animation controllers; the screen only bumps the nonces and passes the
/// move data. All fields are plain data — no game logic lives here.
class AlsijaFx {
  int slideNonce = 0;
  AlsijaCell? slideFrom;
  AlsijaCell? slideTo;
  AlsijaPiece? slideMover;
  List<AlsijaCell> slideCaptured = const [];
  int placedNonce = 0;
  AlsijaCell? placedCell;
  int shakeNonce = 0;
  AlsijaCell? shakeCell;
  int waveNonce = 0;
  int hintNonce = 0;
  AlsijaCell? hintFrom;
  AlsijaCell? hintTo;
  int clearNonce = 0;
}

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
    this.player1Name = 'أنت',
    this.player2Name = 'الخصم',
    this.turnLabel,
    this.isPlacing = false,
    this.placedThisTurn = 0,
    this.isAiThinking = false,
    this.fx,
    this.onFxDone,
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

  /// Two-player mode: the top block rotates 180° and shows the
  /// second player's seat instead of the computer figure.
  final bool vsComputer;
  final String player1Name, player2Name;

  /// Full turn-line text (computed by the screen from the real
  /// phase/player, e.g. «الدور: اللاعب 1 — ضع 3 أحجار»).
  /// Null keeps the old «دورك…» / «دور الخصم» fallback.
  final String? turnLabel;
  final bool isPlacing;
  final int placedThisTurn;
  final bool isAiThinking;

  /// Animation triggers (see [AlsijaFx]). Null means no animations.
  final AlsijaFx? fx;

  /// Called after the slide + capture animations finish, so the
  /// screen can call TurnController.finishAnimation().
  final VoidCallback? onFxDone;

  @override
  State<AlsijaGame> createState() => _AlsijaGameState();
}

class _AlsijaGameState extends State<AlsijaGame>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _captureController;
  late final AnimationController _placeController;
  late final AnimationController _shakeController;
  late final AnimationController _waveController;
  late final AnimationController _hintController;
  late final AnimationController _trailController;
  late final AnimationController _pulseController;
  late final AnimationController _breathController;
  late final AnimationController _boardShakeController;

  int _seenSlide = 0;
  int _seenPlaced = 0;
  int _seenShake = 0;
  int _seenWave = 0;
  int _seenHint = 0;
  int _seenClear = 0;

  AlsijaCell? _slidingFrom;
  AlsijaCell? _slidingTo;
  AlsijaPiece? _slidingMover;
  List<AlsijaCell> _capturingCells = const [];
  AlsijaPiece? _capturingMover;
  AlsijaCell? _capturingTo;
  AlsijaCell? _placingCell;
  AlsijaCell? _shakingCell;
  AlsijaCell? _hintFrom;
  AlsijaCell? _hintTo;
  AlsijaCell? _trailFrom;
  AlsijaCell? _trailTo;
  bool _waveActive = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _captureController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _placeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _trailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _boardShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _slideController,
      _captureController,
      _placeController,
      _shakeController,
      _waveController,
      _hintController,
      _trailController,
      _pulseController,
      _breathController,
      _boardShakeController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AlsijaGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    final fx = widget.fx;
    if (fx == null) {
      return;
    }
    if (fx.clearNonce != _seenClear) {
      _seenClear = fx.clearNonce;
      _clearFx();
    }
    if (fx.placedNonce != _seenPlaced) {
      _seenPlaced = fx.placedNonce;
      _placingCell = fx.placedCell;
      if (_placingCell != null) {
        _placeController.forward(from: 0);
      }
    }
    if (fx.slideNonce != _seenSlide) {
      _seenSlide = fx.slideNonce;
      _startMoveAnimation(fx);
    }
    if (fx.shakeNonce != _seenShake) {
      _seenShake = fx.shakeNonce;
      _shakingCell = fx.shakeCell;
      if (_shakingCell != null) {
        _shakeController.forward(from: 0);
      }
    }
    if (fx.waveNonce != _seenWave) {
      _seenWave = fx.waveNonce;
      _waveActive = true;
      _waveController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() => _waveActive = false);
        }
      });
    }
    if (fx.hintNonce != _seenHint) {
      _seenHint = fx.hintNonce;
      _hintFrom = fx.hintFrom;
      _hintTo = fx.hintTo;
      if (_hintFrom != null && _hintTo != null) {
        _hintController.forward(from: 0);
      }
    }
  }

  void _clearFx() {
    for (final c in [
      _slideController,
      _captureController,
      _placeController,
      _shakeController,
      _waveController,
      _hintController,
      _trailController,
      _boardShakeController,
    ]) {
      c.stop();
    }
    _slidingFrom = null;
    _slidingTo = null;
    _slidingMover = null;
    _capturingCells = const [];
    _capturingMover = null;
    _capturingTo = null;
    _placingCell = null;
    _shakingCell = null;
    _hintFrom = null;
    _hintTo = null;
    _trailFrom = null;
    _trailTo = null;
    _waveActive = false;
  }

  Future<void> _startMoveAnimation(AlsijaFx fx) async {
    final from = fx.slideFrom;
    final to = fx.slideTo;
    final mover = fx.slideMover;
    if (from == null || to == null || mover == null) {
      return;
    }
    final captured = fx.slideCaptured;
    // Plain assignment (no setState): didUpdateWidget runs before the
    // build that follows it, so the slide overlay renders in this
    // frame — same as the original SandBoard.
    _slidingFrom = from;
    _slidingTo = to;
    _slidingMover = mover;
    await _slideController.forward(from: 0);
    if (!mounted) {
      return;
    }
    setState(() {
      _slidingFrom = null;
      _slidingTo = null;
      _slidingMover = null;
      _trailFrom = from;
      _trailTo = to;
    });
    _trailController.forward(from: 0);
    if (captured.isNotEmpty) {
      setState(() {
        _capturingCells = captured;
        _capturingMover = mover;
        _capturingTo = to;
      });
      if (captured.length > 1) {
        _boardShakeController.forward(from: 0);
      }
      await _captureController.forward(from: 0);
      if (!mounted) {
        return;
      }
      setState(() {
        _capturingCells = const [];
        _capturingMover = null;
        _capturingTo = null;
      });
    }
    widget.onFxDone?.call();
  }

  // ---------------------------------------------------------- الهندسة

  /// Board grid: inside the 540×500 board area at offset (40, 20),
  /// size 460×440 — same geometry the static board already uses.
  int get _boardSize => widget.cells.isEmpty ? 5 : widget.cells.length;

  Offset _cellCenter(int row, int column) {
    final n = _boardSize;
    return Offset(
      40 + (column + 0.5) * 460.0 / n,
      20 + (row + 0.5) * 440.0 / n,
    );
  }

  double get _pebblePx {
    final n = _boardSize;
    return math.min(460.0 / n, 440.0 / n) * 0.69;
  }

  // ---------------------------------------------------------- اللوحة

  Widget _board() {
    final board = Stack(
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
            40,
            20,
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
        if (_trailFrom != null && _trailTo != null) _trailOverlay(),
        if (_hintFrom != null && _hintTo != null) _hintOverlay(),
        if (_waveActive) _waveOverlay(),
        if (_slidingFrom != null &&
            _slidingTo != null &&
            _slidingMover != null)
          _slideOverlay(),
        if (_capturingCells.isNotEmpty) _captureOverlay(),
        if (_shakingCell != null) _shakeFlashOverlay(),
      ],
    );
    return AnimatedBuilder(
      animation: _boardShakeController,
      builder: (context, child) {
        final t = _boardShakeController.value;
        final dx = t > 0 ? math.sin(t * math.pi * 4) * 4 * (1 - t) : 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: board,
    );
  }

  Widget _slideOverlay() {
    final from = _slidingFrom!;
    final to = _slidingTo!;
    final mover = _slidingMover!;
    final color = mover == AlsijaPiece.player
        ? widget.playerColor
        : widget.opponentColor;
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(_slideController.value);
        final fromPx = _cellCenter(from.row, from.column);
        final toPx = _cellCenter(to.row, to.column);
        final pos = Offset.lerp(fromPx, toPx, t)!;
        final px = _pebblePx;
        return Positioned(
          left: pos.dx - px / 2,
          top: pos.dy - px / 2,
          child: Transform.scale(
            scale: 1 + 0.08 * math.sin(t * math.pi),
            child: SizedBox(width: px, height: px, child: _stone(color)),
          ),
        );
      },
    );
  }

  Widget _captureOverlay() {
    final mover = _capturingMover;
    final to = _capturingTo;
    final captured = _capturingCells;
    if (mover == null || to == null) {
      return const SizedBox.shrink();
    }
    final victimColor = mover == AlsijaPiece.player
        ? widget.opponentColor
        : widget.playerColor;
    final px = _pebblePx;
    return AnimatedBuilder(
      animation: _captureController,
      builder: (context, child) {
        final t = _captureController.value;
        final widgets = <Widget>[];
        for (var i = 0; i < captured.length; i++) {
          final sq = captured[i];
          final interval = Interval(
            (i * 0.07).clamp(0.0, 0.8),
            1.0,
            curve: Curves.easeIn,
          );
          final lt = interval.transform(t);
          final centre = _cellCenter(sq.row, sq.column);
          widgets.add(
            Positioned(
              left: centre.dx - px / 2,
              top: centre.dy - px / 2,
              child: Opacity(
                opacity: (1 - lt).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: lt * 0.44,
                  child: Transform.scale(
                    scale: (1 - lt).clamp(0.0, 1.0),
                    child: SizedBox(
                      width: px,
                      height: px,
                      child: _stone(victimColor),
                    ),
                  ),
                ),
              ),
            ),
          );
          widgets.add(
            Positioned.fill(
              child: _Art((c, s) {
                final rng = math.Random(5);
                for (var j = 0; j < 7; j++) {
                  final a = rng.nextDouble() * math.pi * 2;
                  final d = lt * (14 + rng.nextDouble() * 18);
                  final p =
                      centre + Offset(math.cos(a) * d, math.sin(a) * d);
                  c.drawCircle(
                    p,
                    2.5 * (1 - lt),
                    Paint()
                      ..color = (j.isEven ? gold : cream)
                          .withValues(alpha: 1 - lt),
                  );
                }
              }),
            ),
          );
          widgets.add(
            Positioned.fill(
              child: _Art((c, s) {
                if (lt <= 0) {
                  return;
                }
                final landing = _cellCenter(to.row, to.column);
                c.drawCircle(
                  landing,
                  lt * px * 0.9,
                  Paint()
                    ..color = gold.withValues(alpha: (1 - lt) * 0.7)
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3,
                );
              }),
            ),
          );
        }
        if (captured.length > 1) {
          final landing = _cellCenter(to.row, to.column);
          final dx = math.sin(t * math.pi * 4) * 2 * (1 - t);
          widgets.add(
            Positioned(
              left: landing.dx - 14 + dx,
              top: landing.dy - px * 0.55,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  'x${captured.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }
        return IgnorePointer(child: Stack(children: widgets));
      },
    );
  }

  Widget _trailOverlay() {
    final from = _trailFrom!;
    final to = _trailTo!;
    return AnimatedBuilder(
      animation: _trailController,
      builder: (context, child) {
        final t = _trailController.value;
        if (t >= 1) {
          return const SizedBox.shrink();
        }
        final fromPx = _cellCenter(from.row, from.column);
        final toPx = _cellCenter(to.row, to.column);
        return IgnorePointer(
          child: _Art((c, s) {
            final paint = Paint()
              ..color =
                  const Color(0xff9e7039).withValues(alpha: (1 - t) * 0.7)
              ..strokeWidth = 4
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke;
            final middle = Offset.lerp(fromPx, toPx, 0.5)!;
            final path = Path()
              ..moveTo(fromPx.dx, fromPx.dy)
              ..quadraticBezierTo(
                middle.dx + 5,
                middle.dy - 5,
                toPx.dx,
                toPx.dy,
              );
            c.drawPath(path, paint);
          }),
        );
      },
    );
  }

  Widget _hintOverlay() {
    final from = _hintFrom!;
    final to = _hintTo!;
    return AnimatedBuilder(
      animation: _hintController,
      builder: (context, child) {
        if (!_hintController.isAnimating) {
          return const SizedBox.shrink();
        }
        final pulse =
            0.6 + 0.4 * math.sin(_hintController.value * math.pi * 6);
        final fromPx = _cellCenter(from.row, from.column);
        final toPx = _cellCenter(to.row, to.column);
        return IgnorePointer(
          child: _Art((c, s) {
            final paint = Paint()
              ..color = gold.withValues(alpha: pulse)
              ..strokeWidth = 5
              ..strokeCap = StrokeCap.round;
            c.drawLine(fromPx, toPx, paint);
            final angle =
                math.atan2(toPx.dy - fromPx.dy, toPx.dx - fromPx.dx);
            const head = 12.0;
            final path = Path()
              ..moveTo(toPx.dx, toPx.dy)
              ..lineTo(
                toPx.dx - head * math.cos(angle - 0.5),
                toPx.dy - head * math.sin(angle - 0.5),
              )
              ..lineTo(
                toPx.dx - head * math.cos(angle + 0.5),
                toPx.dy - head * math.sin(angle + 0.5),
              )
              ..close();
            c.drawPath(path, paint..style = PaintingStyle.fill);
          }),
        );
      },
    );
  }

  Widget _waveOverlay() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_waveController.value);
        return IgnorePointer(
          child: _Art((c, s) {
            c.drawCircle(
              const Offset(270, 250),
              t * 350,
              Paint()
                ..color = gold.withValues(alpha: (1 - t) * 0.6)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3,
            );
          }),
        );
      },
    );
  }

  Widget _shakeFlashOverlay() {
    final sq = _shakingCell!;
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        if (!_shakeController.isAnimating) {
          return const SizedBox.shrink();
        }
        final t = _shakeController.value;
        final centre = _cellCenter(sq.row, sq.column);
        final n = _boardSize;
        final cellW = 460.0 / n;
        final cellH = 440.0 / n;
        return Positioned(
          left: centre.dx - cellW / 2,
          top: centre.dy - cellH / 2,
          child: Container(
            width: cellW,
            height: cellH,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: red.withValues(alpha: 0.25 * (1 - t)),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------- الخلية

  Widget _targetRing() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 0.92 + _pulseController.value * 0.16;
            return Transform.scale(
              scale: scale,
              child: _Art((c, s) {
                final center = s.center(Offset.zero);
                final radius = math.min(s.width, s.height) * .39;
                final hole =
                    Rect.fromCircle(center: center, radius: radius);
                _dot(
                  c,
                  center.dx,
                  center.dy,
                  radius,
                  const Color(0xffc5df88),
                );
                for (var i = 0; i < 12; i++) {
                  c.drawArc(
                    hole.inflate(3),
                    i * math.pi / 6,
                    .28,
                    false,
                    Paint()
                      ..color = const Color(0xff629c52)
                      ..strokeWidth = 4
                      ..style = PaintingStyle.stroke,
                  );
                }
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _placingRing() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _placeController,
        builder: (context, child) {
          final t = _placeController.value;
          return Opacity(
            opacity: (1 - t) * 0.6,
            child: FractionallySizedBox(
              widthFactor: 0.69 * (0.8 + t * 0.7),
              heightFactor: 0.69 * (0.8 + t * 0.7),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gold.withValues(alpha: 0.8),
                    width: 2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// The stone with the original selection / placement / shake
  /// effects: gold ring + pulsing glow + lift + grow when selected,
  /// drop + squash when just placed, shake when the tap was invalid.
  Widget _stoneWithEffects(
    Color color, {
    required bool active,
    required bool placing,
    required bool shaking,
  }) {
    Widget stone = _stone(color);
    if (active) {
      stone = AnimatedBuilder(
        animation: _breathController,
        builder: (context, child) {
          final breath = 0.5 + _breathController.value * 0.5;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.35 + breath * 0.4),
                  blurRadius: 14,
                  spreadRadius: 3,
                ),
              ],
              border: Border.all(color: gold, width: 3),
            ),
            child: child,
          );
        },
        child: stone,
      );
    }
    stone = AnimatedScale(
      scale: active ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: AnimatedSlide(
        offset: active ? const Offset(0, -0.10) : Offset.zero,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: stone,
      ),
    );
    if (placing) {
      stone = AnimatedBuilder(
        animation: _placeController,
        builder: (context, child) {
          final t = Curves.easeOutCubic.transform(_placeController.value);
          final drop = (1 - t) * -28.0;
          final squash = t < 0.85 ? 1.0 : 1.0 - (t - 0.85) * 0.6;
          return Transform.translate(
            offset: Offset(0, drop),
            child: Transform.scale(
              scaleY: squash,
              scaleX: 1 + (1 - squash) * 0.5,
              child: child,
            ),
          );
        },
        child: stone,
      );
    }
    if (shaking) {
      stone = AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final t = _shakeController.value;
          final dx = math.sin(t * math.pi * 6) * 3 * (1 - t);
          return Transform.translate(
            offset: Offset(dx, 0),
            child: Opacity(
              opacity: 1 - t * 0.2,
              child: child,
            ),
          );
        },
        child: stone,
      );
    }
    return stone;
  }

  Widget _cell(int row, int column, AlsijaPiece? piece) {
    final cell = (row: row, column: column);
    final active = widget.selected == cell;
    final target = widget.targets.contains(cell);
    final isPlacing = _placingCell == cell;
    final isShaking =
        _shakingCell == cell && _shakeController.isAnimating;
    final hiddenBySlide = _slidingTo == cell;
    final hiddenByCapture = _capturingCells.contains(cell);
    return _press(
      'الصف ${row + 1}، العمود ${column + 1}',
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
          if (target) _targetRing(),
          if (isPlacing) _placingRing(),
          if (piece != null && !hiddenBySlide && !hiddenByCapture)
            Positioned.fill(
              child: FractionallySizedBox(
                widthFactor: .69,
                heightFactor: .69,
                child: _stoneWithEffects(
                  piece == AlsijaPiece.player
                      ? widget.playerColor
                      : widget.opponentColor,
                  active: active,
                  placing: isPlacing,
                  shaking: isShaking,
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
    bool captured,
  ) => [
    _at(x, y, 164, 116, _bowl(color, number)),
    _label(
      x - 5,
      y + 116,
      174,
      48,
      '${captured ? 'أكلت' : 'باقي'} $number',
      36,
    ),
  ];

  // ---------------------------------------------------------- المقعد العلوي

  /// Player 2's seat (two-player mode): a straw plaque with their
  /// pebble and name, drawn in the package's own style.
  Widget _p2Seat() => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xffe5cb8d),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: ink, width: 1.5),
    ),
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: _stone(widget.opponentColor),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _text(widget.player2Name, 56),
            ),
          ),
        ],
      ),
    ),
  );

  /// The top block (figure + lantern + both counters) as one
  /// positioned unit. In two-player mode the whole block rotates
  /// 180° so player 2 reads it right-side-up from their side, and
  /// the computer figure becomes player 2's seat.
  Widget _topBlock() {
    final inner = Stack(
      children: [
        if (widget.vsComputer)
          _at(
            183,
            0,
            346,
            435,
            _person(variant: widget.opponent.index, seated: true),
          )
        else
          _at(183, 130, 346, 170, _p2Seat()),
        _at(480, 187, 110, 168, _lantern()),
        ..._counter(
          5,
          279,
          widget.playerColor,
          widget.opponentCaptured,
          true,
        ),
        ..._counter(
          544,
          279,
          widget.opponentColor,
          widget.opponentRemaining,
          false,
        ),
      ],
    );
    return Positioned(
      left: 28,
      top: 5,
      width: 713,
      height: 443,
      child: widget.vsComputer
          ? inner
          : RotatedBox(quarterTurns: 2, child: inner),
    );
  }

  // ---------------------------------------------------------- سطر الدور

  Widget _turnLine() {
    final label = widget.turnLabel ??
        (widget.playerTurn ? 'دورك: اختر حجراً ثم وجهته' : 'دور الخصم');
    return _at(
      68,
      938,
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
    _at(18, 24, 117, 122, _coin(Icons.pause, 'إيقاف مؤقت', widget.onPause)),
    _at(
      634,
      24,
      117,
      122,
      _coin(
        widget.soundEnabled ? Icons.volume_up : Icons.volume_off,
        'الصوت',
        widget.onSound,
      ),
    ),
    _topBlock(),
    _at(114, 437, 540, 500, widget.board ?? _board()),
    _turnLine(),
    ..._counter(42, 994, widget.opponentColor, widget.playerCaptured, true),
    ..._counter(563, 994, widget.playerColor, widget.playerRemaining, false),
    if (widget.vsComputer) ...[
      _at(
        262,
        1010,
        101,
        108,
        _coin(Icons.lightbulb_outline, 'تلميح', widget.onHint),
      ),
      _at(
        405,
        1010,
        101,
        108,
        _coin(Icons.reply, 'تراجع', widget.onUndo),
      ),
      _label(258, 1116, 110, 48, 'تلميح', 36),
      _label(399, 1116, 110, 48, 'تراجع', 36),
    ],
    _stripe(1171),
    _at(
      146,
      1201,
      481,
      104,
      DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xff57321b),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
    _at(
      224,
      1210,
      74,
      85,
      _stone(
        widget.playerTurn ? widget.playerColor : widget.opponentColor,
      ),
    ),
    _at(
      299,
      1209,
      170,
      89,
      Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: _text(
            widget.playerTurn ? widget.player1Name : widget.player2Name,
            60,
            color: cream,
          ),
        ),
      ),
    ),
    _at(528, 1191, 96, 115, _lantern()),
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
  });

  final VoidCallback onReplay, onHome;
  final AlsijaOutcome outcome;
  final int wins, losses, draws;
  final Widget? background, scoreCards;

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
        AlsijaOutcome.win => 'مبروووك!',
        AlsijaOutcome.loss => 'حظ أوفر!',
        AlsijaOutcome.draw => 'تعادل!',
      },
      86,
      color: red,
    ),
    _label(70, 716, 628, 62, switch (outcome) {
      AlsijaOutcome.win => 'فزت! شغل نضيف والله',
      AlsijaOutcome.loss => 'جرّب مرة تانية',
      AlsijaOutcome.draw => 'المباراة انتهت بالتعادل',
    }, 40),
    if (scoreCards != null)
      _at(72, 814, 624, 134, scoreCards!)
    else
      for (final (index, (title, value)) in [
        ('تعادل', draws),
        ('خسارة', losses),
        ('فوز', wins),
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
      _plank('العب تاني', 'نفس الإعدادات', onReplay, crimson: true),
    ),
    _at(82, 1153, 611, 121, _plank('العودة للرئيسية', null, onHome)),
  ]);
}
