// الرئيسية: حزمة التصميم — جدار وباب وشيخ وشعار من الصور،
// ولوحة رمل للعرض تتحرك كل 6 ثوانٍ، ولوحا خشب للعب،
// وروابط أسفل الصفحة.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/design_kit.dart';
import '../ui/sheets.dart';
import 'setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, child) {
        final double btnW = math.min(size.width * 0.80, 340);
        final double doorW = math.min(size.width * 0.56, 280);
        final double logoW = math.min(size.width * 0.62, 320);
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                DesignKit.bgHome,
                fit: BoxFit.cover,
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: size.height),
                  child: Column(
                    children: [
                      // زر الإعدادات أعلى اليسار.
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 12,
                          right: 12,
                        ),
                        child: Row(
                          children: [
                            _TokenButton(
                              asset: DesignKit.tokenSettings,
                              label: s.settings,
                              onTap: () =>
                                  showSettingsSheet(context, s),
                            ),
                          ],
                        ),
                      ),
                      // الشعار.
                      Image.asset(
                        DesignKit.logo,
                        width: logoW,
                        semanticLabel: s.homeTitle,
                      ),
                      const SizedBox(height: 2),
                      // الباب والشيخ، وبينهما أطباق الجدار.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const _PlateColumn(
                            plates: [
                              DesignKit.plateRainbow,
                              DesignKit.plateRed,
                              DesignKit.plateStar,
                            ],
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            DesignKit.doorWithElder,
                            width: doorW,
                          ),
                          const SizedBox(width: 6),
                          const _PlateColumn(
                            plates: [
                              DesignKit.plateRainbow,
                              DesignKit.plateStar,
                              DesignKit.plateRed,
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // شريط الحصيرة مع لوحة العرض المتحركة.
                      SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              DesignKit.rugStripes,
                              fit: BoxFit.cover,
                            ),
                            Center(
                              child: _DemoBoard(
                                onTap: () => _goSetup(true),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _Entrance(
                        delay: 0,
                        fromLeft: true,
                        child: KitImageButton(
                          asset: DesignKit.btnPlankRed,
                          semanticLabel: s.playVsComputer,
                          width: btnW,
                          onPressed: () => _goSetup(true),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Entrance(
                        delay: 80,
                        fromLeft: false,
                        child: KitImageButton(
                          asset: DesignKit.btnPlankDark,
                          semanticLabel: s.playVsFriend,
                          width: btnW,
                          onPressed: () => _goSetup(false),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // روابط أسفل الصفحة (منطقة لمس 48dp).
                      // Wrap لا Row: عند 360 بكسل أو خط مكبّر
                      // تلتف الروابط على سطرين بدل التجاوز.
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
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// زر دائري من صورة (إعدادات ونحوها): منطقة لمس 48dp.
class _TokenButton extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;

  const _TokenButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          asset,
          width: 48,
          height: 48,
          semanticLabel: label,
        ),
      ),
    );
  }
}

/// عمود أطباق جدار (3 أطباق مكدسة) بجانب الباب.
class _PlateColumn extends StatelessWidget {
  final List<String> plates;

  const _PlateColumn({required this.plates});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < plates.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          Image.asset(plates[i], width: 40, height: 40),
        ],
      ],
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
        final side = math.min(
            math.min(constraints.maxWidth, constraints.maxHeight),
            124.0);
        final pitch = DesignKit.holePitchPx(5, side);
        final pebblePx = pitch * 0.88;
        return GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                Image.asset(
                  DesignKit.boardAsset(5),
                  width: side,
                  height: side,
                  fit: BoxFit.fill,
                ),
                for (var i = 0; i < _pebbles.length; i++)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    left: DesignKit.holeCenter(
                              5, side, _pebbles[i][1], _pebbles[i][2])
                          .dx -
                        pebblePx / 2,
                    top: DesignKit.holeCenter(
                              5, side, _pebbles[i][1], _pebbles[i][2])
                          .dy -
                        pebblePx / 2,
                    width: pebblePx,
                    height: pebblePx,
                    child: Image.asset(
                      DesignKit.pebbleAsset(
                          _pebbles[i][0] == 1 ? 0 : 1),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
