import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/sudanese_theme.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/settings_store.dart';
import '../ui/painters/wall_painter.dart';
import '../ui/painters/tabaq_painter.dart';
import '../ui/painters/elder_painter.dart';
import '../ui/painters/board_painter.dart';
import '../ui/widgets/plank_button.dart';
import '../ui/widgets/wood_token.dart';
import '../ui/widgets/arched_sheet.dart';
import 'setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _openSettings() {
    bool isAr = AlseejaApp.of(context)?.isArabic ?? true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => ArchedSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.get('settings', isArabic: isAr), style: const TextStyle(fontFamily: 'ReemKufi', fontSize: 26, color: SudaneseTheme.tabaqRed)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(AppStrings.get('sound', isArabic: isAr), style: const TextStyle(fontWeight: FontWeight.bold)),
                value: SettingsStore.soundEnabled,
                activeColor: SudaneseTheme.palmGreen,
                onChanged: (v) async {
                  await SettingsStore.setSoundEnabled(v);
                  setModalState(() {});
                },
              ),
              SwitchListTile(
                title: Text(AppStrings.get('haptics', isArabic: isAr), style: const TextStyle(fontWeight: FontWeight.bold)),
                value: SettingsStore.hapticsEnabled,
                activeColor: SudaneseTheme.palmGreen,
                onChanged: (v) async {
                  await SettingsStore.setHapticsEnabled(v);
                  setModalState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('العربية / English', style: TextStyle(fontWeight: FontWeight.bold)),
                value: isAr,
                activeColor: SudaneseTheme.tabaqRed,
                onChanged: (v) {
                  AlseejaApp.of(context)?.toggleLanguage(v);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openInfoSheet(String titleKey, String bodyKey) {
    bool isAr = AlseejaApp.of(context)?.isArabic ?? true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ArchedSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.get(titleKey, isArabic: isAr), style: const TextStyle(fontFamily: 'ReemKufi', fontSize: 26, color: SudaneseTheme.tabaqRed)),
            const SizedBox(height: 14),
            Text(AppStrings.get(bodyKey, isArabic: isAr), style: const TextStyle(fontSize: 16, height: 1.5, color: SudaneseTheme.earthBlack)),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [WoodToken(icon: Icons.settings, onTap: _openSettings), const SizedBox(width: 48)],
                  ),
                  Text(
                    AppStrings.get('title', isArabic: isAr),
                    style: const TextStyle(
                      fontFamily: 'ReemKufi',
                      fontSize: 60,
                      height: 1.0,
                      color: SudaneseTheme.indigoNight,
                      shadows: [Shadow(color: SudaneseTheme.tabaqRed, offset: Offset(3, 4))],
                    ),
                  ),
                  Text(AppStrings.get('subtitle', isArabic: isAr), style: const TextStyle(fontSize: 16, color: SudaneseTheme.earthBlack, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: List.generate(2, (_) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: CustomPaint(size: const Size(52, 52), painter: TabaqPainter())))),
                      CustomPaint(size: const Size(120, 120), painter: ElderPainter()),
                      Column(children: List.generate(2, (_) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: CustomPaint(size: const Size(52, 52), painter: TabaqPainter())))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen(isTwoPlayer: false))),
                    child: CustomPaint(size: const Size(145, 145), painter: BoardPainter(size: 5)),
                  ),
                  const Spacer(),
                  PlankButton(
                    title: AppStrings.get('playVsComputer', isArabic: isAr),
                    subtitle: AppStrings.get('playVsComputerDesc', isArabic: isAr),
                    color: SudaneseTheme.tabaqRed,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen(isTwoPlayer: false))),
                  ),
                  const SizedBox(height: 14),
                  PlankButton(
                    title: AppStrings.get('twoPlayers', isArabic: isAr),
                    subtitle: AppStrings.get('twoPlayersDesc', isArabic: isAr),
                    color: SudaneseTheme.mudBrickDark,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen(isTwoPlayer: true))),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: () => _openInfoSheet('howToPlay', 'rulesText'), child: Text(AppStrings.get('howToPlay', isArabic: isAr), style: const TextStyle(color: SudaneseTheme.earthBlack, fontWeight: FontWeight.bold))),
                      const Text('·', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => _openInfoSheet('about', 'aboutText'), child: Text(AppStrings.get('about', isArabic: isAr), style: const TextStyle(color: SudaneseTheme.earthBlack, fontWeight: FontWeight.bold))),
                      const Text('·', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => launchUrl(Uri.parse('https://www.tiktok.com/@nubax')), child: Text(AppStrings.get('tiktok', isArabic: isAr), style: const TextStyle(color: SudaneseTheme.earthBlack, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
