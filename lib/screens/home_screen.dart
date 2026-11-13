// الرئيسية v4: الحوش. الجدار المبيّض والباب المقوّس
// والشيخ في الباب، ولوحة رمل للعرض تتحرك كل 6 ثوانٍ،
// ولوحا خشب للعب، وروابط أسفل الصفحة.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/painters/board.dart';
import '../ui/painters/elder.dart';
import '../ui/painters/mat.dart';
import '../ui/painters/pebble.dart';
import '../ui/painters/wall.dart';
import '../ui/painters/tabaq.dart';
import '../ui/sheets.dart';
import '../ui/widgets/plank_button.dart';
import '../ui/widgets/wood_token.dart';
import 'setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _sway;

  @override
  void initState() {
    super.initState();
    _sway = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sway.dispose();
    super.dispose();
  }

  Strings get s => Strings(AppSettings.instance.isArabic);

  void _goSetup(bool vsComputer) {
    SoundManager.instance.tap();
    Navigator.of(context).push(
      FadeSlidePageRoute(
        builder: (_) => SetupScreen(vsComputer: vsComputer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final wallH = math.min(size.height * 0.48, 390.0);
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, child) {
        return Scaffold(
          body: Column(
            children: [
              // ---- الواجهة الرئيسية: جدار مبيّض + باب مقوّس + مشهد سوداني ----
              SizedBox(
                height: wallH,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _sway,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: WallPainter(
                              sunT: 1.0,
                              palmSway: math.sin(_sway.value * 2 * math.pi) * 0.03,
                              doorTopFraction: 0.30,
                              doorHeightFraction: 0.68,
                            ),
                          );
                        },
                      ),
                    ),

                    // العنوان كبير ومباشر مثل لافتة اللعبة، بلا بطاقة تغطي المشهد.
                    Positioned(
                      top: 12,
                      left: 48,
                      right: 48,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              s.homeTitle,
                              style: SudaneseTheme.display.copyWith(
                                fontSize: 54,
                                height: 1.05,
                                color: SudaneseTheme.indigo,
                                shadows: const [
                                  Shadow(
                                    color: SudaneseTheme.tabaqRed,
                                    offset: Offset(2, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              s.homeSubtitle,
                              style: SudaneseTheme.bodyBold.copyWith(
                                fontSize: 16,
                                color: SudaneseTheme.ink,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // زخارف الطبق على جانبي المشهد، مثل جدار الحوش الحقيقي.
                    Positioned(
                      left: 8,
                      top: wallH * 0.33,
                      child: const RepaintBoundary(
                        child: CustomPaint(
                          size: Size(54, 54),
                          painter: TabaqPainter(),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: wallH * 0.33,
                      child: const RepaintBoundary(
                        child: CustomPaint(
                          size: Size(54, 54),
                          painter: TabaqPainter(rotation: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      top: wallH * 0.63,
                      child: const RepaintBoundary(
                        child: CustomPaint(
                          size: Size(42, 42),
                          painter: TabaqPainter(rotation: 0.04),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 18,
                      top: wallH * 0.63,
                      child: const RepaintBoundary(
                        child: CustomPaint(
                          size: Size(42, 42),
                          painter: TabaqPainter(rotation: -0.04),
                        ),
                      ),
                    ),

                    // زر الإعدادات.
                    Positioned(
                      top: 10,
                      left: 10,
                      child: WoodToken(
                        icon: Icons.tune,
                        size: 48,
                        tooltip: s.settings,
                        onPressed: () => showSettingsSheet(context, s),
                      ),
                    ),

                    // الشيخ جالس أمام مدخل الحوش.
                    Positioned(
                      bottom: wallH * 0.015,
                      left: (size.width - 118) / 2,
                      child: const RepaintBoundary(
                        child: CustomPaint(
                          size: Size(118, 145),
                          painter: ElderPainter(
                            kind: ElderKind.elder,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- البرش: لوحة العرض + أزرار اللعب ----
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const RepaintBoundary(
                      child: CustomPaint(
                        painter: MatPainter(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          const SizedBox(height: 4),
                          Expanded(
                            child: Center(
                              child: _DemoBoard(
                                onTap: () => _goSetup(true),
                              ),
                            ),
                          ),
                          _Entrance(
                            delay: 0,
                            fromLeft: true,
                            child: PlankButton(
                              label: s.playVsComputer,
                              caption: s.playVsComputerCaption,
                              kind: PlankKind.red,
                              onPressed: () => _goSetup(true),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Entrance(
                            delay: 80,
                            fromLeft: false,
                            child: PlankButton(
                              label: s.playVsFriend,
                              caption: s.playVsFriendCaption,
                              kind: PlankKind.dark,
                              onPressed: () => _goSetup(false),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _FooterLink(
                                label: s.howToPlay,
                                onTap: () => showHowToPlaySheet(context, s),
                              ),
                              Text(' · ', style: SudaneseTheme.bodyBold),
                              _FooterLink(
                                label: s.aboutGame,
                                onTap: () => showAboutSheet(context, s),
                              ),
                              Text(' · ', style: SudaneseTheme.bodyBold),
                              _FooterLink(
                                label: s.tiktokLink,
                                onTap: () => showAboutSheet(context, s),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// دخول متدرج: انزلاق من جهة + تلاشٍ (320ms).
class _Entrance extends StatefulWidget {
  final int delay;
  final bool fromLeft;
  final Widget child;

  const _Entrance({
    required this.delay,
    required this.fromLeft,
    required this.child,
  });

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
        parent: _controller, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(widget.fromLeft ? -0.3 : 0.3, 0),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Text(
          label,
          style: SudaneseTheme.bodyBold.copyWith(fontSize: 15),
        ),
      ),
    );
  }
}

/// لوحة عرض صغيرة للعبة جارية: حجر ينزلق إلى حفرة مجاورة
/// كل 6 ثوانٍ. النقر عليها يبدأ إعداد لعبة ضد الكمبيوتر.
class _DemoBoard extends StatefulWidget {
  final VoidCallback onTap;

  const _DemoBoard({required this.onTap});

  @override
  State<_DemoBoard> createState() => _DemoBoardState();
}

class _DemoBoardState extends State<_DemoBoard> {
  // (اللاعب، الصف، العمود).
  late List<List<int>> _pebbles;
  Timer? _timer;
  final _rng = math.Random(11);

  static const _start = [
    [1, 0, 0],
    [1, 0, 1],
    [1, 1, 0],
    [1, 2, 1],
    [1, 3, 2],
    [2, 0, 2],
    [2, 1, 2],
    [2, 2, 3],
    [2, 3, 4],
    [2, 4, 4],
  ];

  @override
  void initState() {
    super.initState();
    _pebbles = _start.map((e) => List<int>.of(e)).toList();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) => _idleMove());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _idleMove() {
    if (!mounted) return;
    final occupied = {
      for (final p in _pebbles) '${p[1]},${p[2]}',
    };
    final movable = <int>[];
    for (var i = 0; i < _pebbles.length; i++) {
      final p = _pebbles[i];
      for (final d in [
        [1, 0],
        [-1, 0],
        [0, 1],
        [0, -1],
      ]) {
        final r = p[1] + d[0];
        final c = p[2] + d[1];
        if (r >= 0 && r < 5 && c >= 0 && c < 5 && !(r == 2 && c == 2)) {
          if (!occupied.contains('$r,$c')) movable.add(i);
          break;
        }
      }
    }
    if (movable.isEmpty) return;
    final i = movable[_rng.nextInt(movable.length)];
    final p = _pebbles[i];
    final options = <List<int>>[];
    for (final d in [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ]) {
      final r = p[1] + d[0];
      final c = p[2] + d[1];
      if (r >= 0 &&
          r < 5 &&
          c >= 0 &&
          c < 5 &&
          !(r == 2 && c == 2) &&
          !occupied.contains('$r,$c')) {
        options.add([r, c]);
      }
    }
    if (options.isEmpty) return;
    final dest = options[_rng.nextInt(options.length)];
    setState(() {
      _pebbles[i][1] = dest[0];
      _pebbles[i][2] = dest[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Reserve room for the carved wooden surround so the complete
        // board remains inside the available space on short screens.
        final available = math.min(constraints.maxWidth, constraints.maxHeight);
        final side = math.max(0.0, math.min(available - 16, 300.0));
        final cell = (side - 16) / 5;
        final pebblePx = cell * 0.72;
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: side + 16,
            height: side + 16,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF9A6538),
                  Color(0xFF5B351F),
                  Color(0xFF3D2518),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: SudaneseTheme.sunGold.withValues(alpha: 0.9),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: SudaneseTheme.earthBlack.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
                BoxShadow(
                  color: SudaneseTheme.sunGold.withValues(alpha: 0.16),
                  blurRadius: 7,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: SizedBox(
                width: side,
                height: side,
                child: Stack(
                  children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size(side, side),
                    painter:
                        const BoardPainter(size: 5, centreOccupied: false),
                  ),
                ),
                for (var i = 0; i < _pebbles.length; i++)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    left: 8 +
                        (_pebbles[i][2] + 0.5) * cell -
                        pebblePx / 2,
                    top: 8 +
                        (_pebbles[i][1] + 0.5) * cell -
                        pebblePx / 2,
                    width: pebblePx,
                    height: pebblePx,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: PebblePainter(
                          def: SudaneseTheme.pebbles[
                              _pebbles[i][0] == 1 ? 0 : 1],
                        ),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
