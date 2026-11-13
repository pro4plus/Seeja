// شاشة البداية v4 (2.2 ث): جدار الحوش يظهر، شمس الطبق
// تشرق خلف الأهرامات، العنوان يُرسم مسحاً حرفاً حرفاً،
// والأطباق الستة تظهر واحداً واحداً (60ms بينها)، ثم
// يكبر الباب كتلاشٍ متقاطع إلى الرئيسية.
import 'package:flutter/material.dart';

import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/painters/wall.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _controller.addListener(() {
      if (!_soundPlayed && _controller.value > 0.05) {
        _soundPlayed = true;
        SoundManager.instance.start();
      }
    });
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        FadeSlidePageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _interval(double start, double end, double value) {
    if (value <= start) return 0.0;
    if (value >= end) return 1.0;
    final t = (value - start) / (end - start);
    return Curves.easeOutCubic.transform(t);
  }

  double _pop(int i, double value) {
    final start = 0.15 + i * 0.06;
    final t = _interval(start, start + 0.15, value);
    return Curves.easeOutBack.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings(AppSettings.instance.isArabic);
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final v = _controller.value;
          final sunT = _interval(0.0, 0.5, v);
          final glow = _interval(0.0, 0.4, v);
          final plates = List.generate(6, (i) => _pop(i, v));
          final titleReveal = _interval(0.35, 0.75, v);
          final subFade = _interval(0.6, 0.85, v);
          return Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: WallPainter(
                    sunT: sunT,
                    glow: glow,
                    plates: plates,
                    // الباب تحت منطقة العنوان.
                    doorTopFraction: 0.18,
                    doorHeightFraction: 0.75,
                  ),
                ),
              ),
              // العنوان يُرسم مسحاً من اليمين (RTL).
              Positioned(
                top: 34,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 13, 18, 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF4D8),
                        Color(0xFFE9D2A0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: SudaneseTheme.sunGold,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x660F0905),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Color(0x88FFFFFF),
                        blurRadius: 0,
                        spreadRadius: -5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: SudaneseTheme.mudBrick.withValues(alpha: 0.48),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRect(
                          child: Align(
                            alignment: Alignment.centerRight,
                            widthFactor: titleReveal.clamp(0.01, 1.0),
                            child: Text(
                              strings.appTitle,
                              style: SudaneseTheme.display.copyWith(
                                fontSize: (MediaQuery.sizeOf(context).width * 0.15)
                                    .clamp(42.0, 62.0),
                                height: 1.15,
                                color: SudaneseTheme.indigo,
                                shadows: const [
                                  Shadow(
                                    color: SudaneseTheme.tabaqRed,
                                    offset: Offset(2, 3),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 62,
                          height: 3,
                          decoration: BoxDecoration(
                            color: SudaneseTheme.tabaqRed,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Opacity(
                          opacity: subFade,
                          child: Text(
                            strings.tagline,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
