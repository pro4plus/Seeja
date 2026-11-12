import 'package:flutter/material.dart';
import '../theme/sudanese_theme.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../game/seega_ai.dart';
import '../game/sound_manager.dart';
import '../ui/painters/mat_painter.dart';
import '../ui/painters/elder_painter.dart';
import '../ui/painters/board_painter.dart';
import '../ui/painters/tabaq_painter.dart';
import '../ui/widgets/wood_token.dart';
import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  final bool isTwoPlayer;
  const SetupScreen({super.key, required this.isTwoPlayer});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  AIDifficulty difficulty = AIDifficulty.medium;
  int boardSize = 5;
  int p1ColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isAr = AlseejaApp.of(context)?.isArabic ?? true;
    int p2ColorIndex = (p1ColorIndex + 1) % SudaneseTheme.pebbleColors.length;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: MatPainter()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      WoodToken(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                      const SizedBox(width: 14),
                      Text(AppStrings.get('setupTitle', isArabic: isAr), style: const TextStyle(fontFamily: 'ReemKufi', fontSize: 30, color: SudaneseTheme.earthBlack)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (!widget.isTwoPlayer) ...[
                    Text(AppStrings.get('against', isArabic: isAr), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SudaneseTheme.earthBlack)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildNiche(AIDifficulty.easy, AppStrings.get('easyName', isArabic: isAr), AppStrings.get('easy', isArabic: isAr)),
                        const SizedBox(width: 10),
                        _buildNiche(AIDifficulty.medium, AppStrings.get('mediumName', isArabic: isAr), AppStrings.get('medium', isArabic: isAr)),
                        const SizedBox(width: 10),
                        _buildNiche(AIDifficulty.hard, AppStrings.get('hardName', isArabic: isAr), AppStrings.get('hard', isArabic: isAr)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(AppStrings.get('boardType', isArabic: isAr), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SudaneseTheme.earthBlack)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBoardCard(5, AppStrings.get('quickBoard', isArabic: isAr)),
                      _buildBoardCard(7, AppStrings.get('longBoard', isArabic: isAr)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(AppStrings.get('yourStone', isArabic: isAr), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SudaneseTheme.earthBlack)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: SudaneseTheme.mudBrickDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: SudaneseTheme.earthBlack, width: 2)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(SudaneseTheme.pebbleColors.length, (i) {
                        bool selected = p1ColorIndex == i;
                        return GestureDetector(
                          onTap: () {
                            SoundManager.select();
                            setState(() => p1ColorIndex = i);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: SudaneseTheme.pebbleColors[i],
                              shape: BoxShape.circle,
                              border: Border.all(color: selected ? SudaneseTheme.sunGold : SudaneseTheme.earthBlack, width: selected ? 3.5 : 1.5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      SoundManager.play('start.wav');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            boardSize: boardSize,
                            isTwoPlayer: widget.isTwoPlayer,
                            difficulty: difficulty,
                            p1Color: SudaneseTheme.pebbleColors[p1ColorIndex],
                            p2Color: SudaneseTheme.pebbleColors[p2ColorIndex],
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(size: const Size(96, 96), painter: TabaqPainter(showYalla: true)),
                          Text(AppStrings.get('startBtn', isArabic: isAr), style: const TextStyle(fontFamily: 'ReemKufi', fontSize: 24, color: SudaneseTheme.cream, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNiche(AIDifficulty diff, String name, String level) {
    bool active = difficulty == diff;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundManager.tap();
          setState(() => difficulty = diff);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? SudaneseTheme.mudBrickDark : SudaneseTheme.mudBrickDark.withOpacity(0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(48), bottom: Radius.circular(12)),
            border: Border.all(color: active ? SudaneseTheme.sunGold : SudaneseTheme.earthBlack, width: active ? 3 : 2),
          ),
          child: Column(
            children: [
              CustomPaint(size: const Size(68, 72), painter: ElderPainter(difficulty: diff)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: SudaneseTheme.straw, borderRadius: BorderRadius.circular(6)),
                child: Column(
                  children: [
                    FittedBox(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SudaneseTheme.earthBlack))),
                    Text(level, style: const TextStyle(fontSize: 11, color: SudaneseTheme.tabaqRed, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardCard(int size, String label) {
    bool active = boardSize == size;
    return GestureDetector(
      onTap: () {
        SoundManager.tap();
        setState(() => boardSize = size);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: active ? SudaneseTheme.tabaqRed : Colors.transparent, width: 3.5)),
            child: CustomPaint(size: const Size(110, 110), painter: BoardPainter(size: size)),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: SudaneseTheme.earthBlack)),
        ],
      ),
    );
  }
}
