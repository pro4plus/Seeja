import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/sudanese_theme.dart';
import 'services/settings_store.dart';
import 'game/sound_manager.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SettingsStore.init();
  await SoundManager.init();
  runApp(const AlseejaApp());
}

class AlseejaApp extends StatefulWidget {
  const AlseejaApp({super.key});
  static _AlseejaAppState? of(BuildContext context) => context.findAncestorStateOfType<_AlseejaAppState>();
  @override
  State<AlseejaApp> createState() => _AlseejaAppState();
}

class _AlseejaAppState extends State<AlseejaApp> {
  bool isArabic = SettingsStore.isArabic;
  void toggleLanguage(bool arabic) {
    setState(() {
      isArabic = arabic;
      SettingsStore.setArabic(arabic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'السيجا السودانية',
      debugShowCheckedModeBanner: false,
      theme: SudaneseTheme.theme,
      locale: Locale(isArabic ? 'ar' : 'en'),
      builder: (context, child) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: const SplashScreen(),
    );
  }
}
