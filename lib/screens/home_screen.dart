// الرئيسية: شاشات الحزمة الجديدة (AlsijaHome) — رسم CustomPainter.
// التنقل والإعدادات وطريقة اللعب وعن اللعبة والتيك توك كما كانت.
import 'package:flutter/material.dart';

import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/alsija_screens.dart';
import '../ui/sheets.dart';
import 'setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Strings get s => Strings(AppSettings.instance.isArabic);

  void _goSetup(BuildContext context, bool vsComputer) {
    SoundManager.instance.tap();
    Navigator.of(context).push(
      FadeSlidePageRoute(
        builder: (_) => SetupScreen(vsComputer: vsComputer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, child) => AlsijaHome(
        onComputer: () => _goSetup(context, true),
        onLocal: () => _goSetup(context, false),
        onSettings: () => showSettingsSheet(context, s),
        onHowTo: () => showHowToPlaySheet(context, s),
        onAbout: () => showAboutSheet(context, s),
        // رابط تيك توك يفتح صفحة «عن اللعبة» كما كان —
        // وفيها زر تيك توك والبريد.
        onTikTok: () => showAboutSheet(context, s),
        isArabic: s.isArabic,
      ),
    );
  }
}
