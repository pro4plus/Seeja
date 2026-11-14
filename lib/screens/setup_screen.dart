// الإعداد: شاشة الحزمة الجديدة (AlsijaSetup) + خطوة ثانية لاختيار
// حجر اللاعب 2 في وضع اللاعبين — الحزمة فيها لون واحد فقط،
// واللاعب 2 يجب أن يختار لونه هو أيضاً (كما كان).
//
// ضد الكمبيوتر: إعداد واحد يكفي؛ حجر الكمبيوتر يُشتق من حجر
// اللاعب (+3 ضمن الأحجار السبعة) كما كان.
// لاعبان: الإعداد الأول يأخذ حجم اللوحة ولون اللاعب 1، ثم خطوة
// ثانية للون اللاعب 2 (بلا لون اللاعب 1).
import 'package:flutter/material.dart';

import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/alsija_pebbles.dart';
import '../ui/alsija_screens.dart';
import 'game_screen.dart';

/// أسماء ألوان الحزمة (نفس ترتيب AlsijaColor.values ونفس
// الأسماء المثبتة في شاشة الإعداد بالحزمة).
const _colorNames = [
  'رمادي',
  'ذهبي',
  'فيروزي',
  'أحمر',
  'أخضر',
  'نحاسي',
  'أزرق',
];

class SetupScreen extends StatefulWidget {
  final bool vsComputer;

  const SetupScreen({super.key, required this.vsComputer});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  /// وضع اللاعبين فقط: 0 = إعداد اللاعب 1 (الحزمة)،
  /// 1 = اختيار لون اللاعب 2.
  int _step = 0;
  int _boardSize = 5;
  int? _p1Pebble;

  Strings get s => Strings(AppSettings.instance.isArabic);

  void _startVsComputer(AlsijaSettings settings) {
    SoundManager.instance.tap();
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
    SoundManager.instance.tap();
    setState(() {
      _boardSize = settings.boardSize;
      _p1Pebble = pebbleForAlsijaColor(settings.color);
      _step = 1;
    });
  }

  void _startTwoPlayer(int p2Pebble) {
    SoundManager.instance.tap();
    final config = GameConfig(
      boardSize: _boardSize,
      vsComputer: false,
      p1Pebble: _p1Pebble ?? 0,
      p2Pebble: p2Pebble,
    );
    Navigator.of(context).pushNamed('/game', arguments: config);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.vsComputer && _step == 1) {
      return _P2ColorStep(
        lockedPebble: _p1Pebble ?? 0,
        onBack: () => setState(() => _step = 0),
        onPick: _startTwoPlayer,
      );
    }
    return AlsijaSetup(
      onBack: () => Navigator.of(context).pop(),
      onStart: widget.vsComputer ? _startVsComputer : _onP1Chosen,
    );
  }
}

/// خطوة اختيار لون اللاعب 2: دوائر ألوان الحزمة السبعة،
// لون اللاعب 1 مقفل (معتم ولا يُختار)، وزر «يلا» يبدأ اللعب.
class _P2ColorStep extends StatefulWidget {
  final int lockedPebble;
  final VoidCallback onBack;
  final ValueChanged<int> onPick;

  const _P2ColorStep({
    required this.lockedPebble,
    required this.onBack,
    required this.onPick,
  });

  @override
  State<_P2ColorStep> createState() => _P2ColorStepState();
}

class _P2ColorStepState extends State<_P2ColorStep> {
  AlsijaColor? _picked;

  Strings get s => Strings(AppSettings.instance.isArabic);

  @override
  Widget build(BuildContext context) {
    final lockedColor = alsijaColorForPebble(widget.lockedPebble);
    return Scaffold(
      backgroundColor: SudaneseTheme.mudBrickDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SudaneseTheme.cream),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.chooseStoneP2First,
                style: SudaneseTheme.title.copyWith(
                  color: SudaneseTheme.cream,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${s.chooseStoneP1First}: ${_colorNames[lockedColor.index]}',
                style: SudaneseTheme.body.copyWith(
                  color: SudaneseTheme.cream,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final color in AlsijaColor.values)
                    _ColorDot(
                      color: color,
                      name: _colorNames[color.index],
                      locked: color == lockedColor,
                      selected: color == _picked,
                      onTap: color == lockedColor
                          ? null
                          : () => setState(() => _picked = color),
                    ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: _picked == null
                      ? null
                      : () => widget
                          .onPick(pebbleForAlsijaColor(_picked!)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SudaneseTheme.tabaqRed,
                    foregroundColor: SudaneseTheme.cream,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: SudaneseTheme.title.copyWith(fontSize: 24),
                  ),
                  child: Text(s.letsGo),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final AlsijaColor color;
  final String name;
  final bool locked;
  final bool selected;
  final VoidCallback? onTap;

  const _ColorDot({
    required this.color,
    required this.name,
    required this.locked,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: locked ? 0.35 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.value,
                  border: selected
                      ? Border.all(
                          color: SudaneseTheme.sunGold,
                          width: 4,
                        )
                      : Border.all(
                          color: SudaneseTheme.earthBlack,
                          width: 2,
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                style: SudaneseTheme.caption.copyWith(
                  color: SudaneseTheme.cream,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
