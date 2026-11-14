// الإعداد: شاشة الحزمة الجديدة (AlsijaSetup) — واختيار حجر
// اللاعب 2 في خطوة ثانية على الشاشة نفسها (بلا شاشة ثانية):
// الخطوة 0 تختار حجم اللوحة ولون اللاعب 1، والخطوة 1 تختار
// لون اللاعب 2 ولون اللاعب 1 مقفل فيها — كما كان في الأصل.
//
// ضد الكمبيوتر: إعداد واحد يكفي؛ حجر الكمبيوتر يُشتق من حجر
// اللاعب (+3 ضمن الأحجار السبعة) كما كان.
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/alsija_pebbles.dart';
import '../ui/alsija_screens.dart';
import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  final bool vsComputer;

  const SetupScreen({super.key, required this.vsComputer});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  /// وضع اللاعبين فقط: 0 = إعداد اللاعب 1، 1 = اختيار لون اللاعب 2.
  int _step = 0;
  int _boardSize = 5;
  int? _p1Pebble;

  Strings get s => Strings(AppSettings.instance.isArabic);

  void _startVsComputer(AlsijaSettings settings) {
    // النقرة تصدر من _press نفسه في زر «يلا».
    final p1 = pebbleForAlsijaColor(settings.color);
    final config = GameConfig(
      boardSize: settings.boardSize,
      vsComputer: true,
      difficulty: difficultyForOpponent(settings.opponent),
      p1Pebble: p1,
      p2Pebble: (p1 + 3) % SudaneseTheme.pebbles.length,
    );
    Navigator.of(context).pushNamed('/game', arguments: config);
  }

  void _onP1Chosen(AlsijaSettings settings) {
    setState(() {
      _boardSize = settings.boardSize;
      _p1Pebble = pebbleForAlsijaColor(settings.color);
      _step = 1;
    });
  }

  void _startTwoPlayer(AlsijaSettings settings) {
    final config = GameConfig(
      boardSize: settings.boardSize,
      vsComputer: false,
      p1Pebble: _p1Pebble ?? 0,
      p2Pebble: pebbleForAlsijaColor(settings.color),
    );
    Navigator.of(context).pushNamed('/game', arguments: config);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vsComputer) {
      return AlsijaSetup(
        onBack: () => Navigator.of(context).pop(),
        onStart: _startVsComputer,
        isArabic: s.isArabic,
        showOpponents: true,
      );
    }
    // لاعبان: الخطوة نفسها على الشاشة نفسها — مفتاح مختلف
    // لكل خطوة فيعيد AlsijaSetup حالته من المعاملات.
    if (_step == 1) {
      final p1 = _p1Pebble ?? 0;
      return AlsijaSetup(
        key: const ValueKey(1),
        onBack: () => setState(() => _step = 0),
        onStart: _startTwoPlayer,
        lockedColor: alsijaColorForPebble(p1),
        initialColor:
            alsijaColorForPebble((p1 + 3) % SudaneseTheme.pebbles.length),
        initialBoardSize: _boardSize,
        title: s.chooseStoneP2First,
        isArabic: s.isArabic,
        showOpponents: false,
      );
    }
    return AlsijaSetup(
      key: const ValueKey(0),
      onBack: () => Navigator.of(context).pop(),
      onStart: _onP1Chosen,
      initialColor: alsijaColorForPebble(_p1Pebble ?? 0),
      initialBoardSize: _boardSize,
      isArabic: s.isArabic,
      showOpponents: false,
    );
  }
}
