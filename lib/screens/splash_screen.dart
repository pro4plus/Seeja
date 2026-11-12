import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/sudanese_theme.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../ui/painters/wall_painter.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = AlseejaApp.of(context)?.isArabic ?? true;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: WallPainter()),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 36),
                Text(
                  AppStrings.get('title', isArabic: isAr),
                  style: const TextStyle(
                    fontFamily: 'ReemKufi',
                    fontSize: 68,
                    color: SudaneseTheme.indigoNight,
                    shadows: [Shadow(color: SudaneseTheme.tabaqRed, offset: Offset(3, 4))],
                  ),
                ),
                Text(AppStrings.get('subtitle', isArabic: isAr), style: const TextStyle(fontSize: 17, color: SudaneseTheme.earthBlack, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
