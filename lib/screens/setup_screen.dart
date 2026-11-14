// شاشة الإعداد "اجلس للعب" (§6.3 + حزمة التصميم):
// خلفية حصير، ولوح عنوان، وثلاث كوات (ود البلد/الأستاذ/الشيخ)
// ثم لوحتان مصغرتان ثم صينية الحجارة.
// لاعبان: الصينية للاعب 1 ثم تنزلق وتعود للاعب 2.
// زر "يلا" دائري ثابت أسفل الوسط على شريط منسوج.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/seega_ai.dart';
import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/design_kit.dart';
import '../ui/widgets/niche.dart';
import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  final bool vsComputer;

  const SetupScreen({super.key, required this.vsComputer});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with TickerProviderStateMixin {
  Difficulty _difficulty = Difficulty.medium;
  int _boardSize = 5;
  int? _p1Pebble;
  int? _p2Pebble;
  int _step = 0; // لاعبان فقط: 0 = حجر اللاعب 1، 1 = حجر اللاعب 2.
  bool _spinning = false;
  late final AnimationController _pulse;
  late final AnimationController _spin;

  Strings get s => Strings(AppSettings.instance.isArabic);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _spin.dispose();
    super.dispose();
  }

  bool get _ready {
    if (widget.vsComputer) return _p1Pebble != null;
    return _p1Pebble != null && _p2Pebble != null;
  }

  /// الكمبيوتر يأخذ حجراً مختلفاً تلقائياً.
  int get _computerPebble {
    if (_p1Pebble == null) return 1;
    return (_p1Pebble! + 3) % SudaneseTheme.pebbles.length;
  }

  void _pickPebble(int index) {
    SoundManager.instance.tap();
    setState(() {
      if (widget.vsComputer) {
        _p1Pebble = index;
      } else if (_step == 0) {
        _p1Pebble = index;
        // انزلاق الصينية وعودتها للاعب 2 بعد لحظة.
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) setState(() => _step = 1);
        });
      } else {
        _p2Pebble = index;
      }
    });
  }

  void _start() {
    if (!_ready || _spinning) return;
    SoundManager.instance.start();
    setState(() => _spinning = true);
    _spin.forward(from: 0).then((_) {
      if (!mounted) return;
      final config = GameConfig(
        boardSize: _boardSize,
        vsComputer: widget.vsComputer,
        difficulty: _difficulty,
        p1Pebble: _p1Pebble ?? 0,
        p2Pebble: widget.vsComputer ? _computerPebble : (_p2Pebble ?? 1),
      );
      Navigator.of(context).pushNamed('/game', arguments: config);
    });
  }

  void _pickDifficulty(Difficulty difficulty) {
    SoundManager.instance.tap();
    setState(() => _difficulty = difficulty);
  }

  void _pickBoardSize(int size) {
    SoundManager.instance.tap();
    setState(() => _boardSize = size);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final double headerW = math.min(size.width * 0.55, 300);
        // عرض الكوّة: ثلث العرض المتاح بحد أقصى 104 حتى لا
        // تطول الصورة (نسبتها 440×860) وتتجاوز الشاشة.
        final double nicheW = math.min(
          (size.width - 40 - 20) / 3,
          104,
        );
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                DesignKit.bgStraw,
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            // ---- الأعلى: رجوع + لوح العنوان ----
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: SizedBox(
                                height: 56,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _TokenButton(
                                        asset: DesignKit.tokenBack,
                                        label: s.close,
                                        flipInRtl: true,
                                        onTap: () {
                                          SoundManager.instance.tap();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                    Center(
                                      child: Image.asset(
                                        DesignKit.headerPlank,
                                        width: headerW,
                                        semanticLabel: s.sitToPlay,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // شريط منسوج تحت العنوان.
                            const _WeaveBand(),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // ---- الكوات (ضد الكمبيوتر فقط) ----
                                  // الترتيب في الصورة المرجعية من اليمين:
                                  // الشيخ، الأستاذ، ود البلد.
                                  if (widget.vsComputer) ...[
                                    _SectionLabel(s.againstWho),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: nicheW,
                                          child: OpponentNiche(
                                            difficulty: Difficulty.hard,
                                            name: s.elderElder,
                                            level: s.hard,
                                            selected: _difficulty ==
                                                Difficulty.hard,
                                            onTap: () => _pickDifficulty(
                                                Difficulty.hard),
                                          ),
                                        ),
                                        SizedBox(
                                          width: nicheW,
                                          child: OpponentNiche(
                                            difficulty: Difficulty.medium,
                                            name: s.elderTeacher,
                                            level: s.medium,
                                            selected: _difficulty ==
                                                Difficulty.medium,
                                            onTap: () => _pickDifficulty(
                                                Difficulty.medium),
                                          ),
                                        ),
                                        SizedBox(
                                          width: nicheW,
                                          child: OpponentNiche(
                                            difficulty: Difficulty.easy,
                                            name: s.elderYoung,
                                            level: s.easy,
                                            selected: _difficulty ==
                                                Difficulty.easy,
                                            onTap: () => _pickDifficulty(
                                                Difficulty.easy),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  // ---- اللوحة ----
                                  // في الصورة المرجعية: 5×5 على اليسار
                                  // و7×7 على اليمين.
                                  _SectionLabel(s.boardSection),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _BoardMini(
                                          size: 7,
                                          caption: s.board7Short,
                                          selected: _boardSize == 7,
                                          onTap: () => _pickBoardSize(7),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _BoardMini(
                                          size: 5,
                                          caption: s.board5Short,
                                          selected: _boardSize == 5,
                                          onTap: () => _pickBoardSize(5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // ---- صينية الحجارة ----
                                  _SectionLabel(widget.vsComputer
                                      ? s.yourPebble
                                      : (_step == 0
                                          ? s.chooseStoneP1First
                                          : s.chooseStoneP2First)),
                                  const SizedBox(height: 8),
                                  AnimatedSwitcher(
                                    duration: const Duration(
                                        milliseconds: 350),
                                    transitionBuilder: (child, animation) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.4),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _PebbleTray(
                                      key: ValueKey(_step),
                                      selected: widget.vsComputer
                                          ? _p1Pebble
                                          : (_step == 0
                                              ? _p1Pebble
                                              : _p2Pebble),
                                      locked: widget.vsComputer
                                          ? null
                                          : (_step == 1 ? _p1Pebble : null),
                                      onPick: _pickPebble,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // سطر حجر الكمبيوتر / تغيير حجر اللاعب 1.
                                  SizedBox(
                                    height: 20,
                                    child: Center(
                                      child: widget.vsComputer
                                          ? (_p1Pebble == null
                                              ? const SizedBox.shrink()
                                              : Text(
                                                  s.computerTakes(
                                                    SudaneseTheme.pebbles[
                                                            _computerPebble]
                                                        .nameAr,
                                                  ),
                                                  style:
                                                      SudaneseTheme.caption,
                                                ))
                                          : (_step == 1
                                              ? GestureDetector(
                                                  onTap: () =>
                                                      setState(() {
                                                    _step = 0;
                                                    _p2Pebble = null;
                                                  }),
                                                  child: Text(
                                                    s.chooseStoneP1First,
                                                    style: SudaneseTheme
                                                        .caption
                                                        .copyWith(
                                                      color: SudaneseTheme
                                                          .tabaqRed,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // فاصل ثابت بدل Spacer: العمود داخل تمرير
                            // عمودي فلا يقبل أبناء flex.
                            const SizedBox(height: 24),
                            // ---- زر يلا على شريط منسوج ----
                            SizedBox(
                              height: 104,
                              width: double.infinity,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const _WeaveBand(),
                                  _YallaButton(
                                    ready: _ready,
                                    pulse: _pulse,
                                    spin: _spin,
                                    onTap: _start,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// عنوان قسم في وسط الشاشة كما في الصورة المرجعية.
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: SudaneseTheme.heading.copyWith(fontSize: 19),
      textAlign: TextAlign.center,
    );
  }
}

/// شريط منسوج أحمر/أسود بعرض الشاشة.
class _WeaveBand extends StatelessWidget {
  const _WeaveBand();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      DesignKit.bandWeave,
      width: double.infinity,
      height: 22,
      fit: BoxFit.cover,
    );
  }
}

/// زر دائري من صورة (رجوع ونحوه): منطقة لمس 48dp.
class _TokenButton extends StatelessWidget {
  final String asset;
  final String label;
  final bool flipInRtl;
  final VoidCallback onTap;

  const _TokenButton({
    required this.asset,
    required this.label,
    this.flipInRtl = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final flip = flipInRtl &&
        Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Transform.flip(
          flipX: flip,
          child: Image.asset(
            asset,
            width: 48,
            height: 48,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}

/// لوحة مصغرة: صورة اللوحة من الحزمة، وحلقة حمراء
/// حول المختارة، والتسمية نصاً تحتها.
class _BoardMini extends StatelessWidget {
  final int size;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  const _BoardMini({
    required this.size,
    required this.caption,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (selected)
                  Image.asset(
                    DesignKit.selectionRingRed,
                    width: 132,
                    height: 132,
                  ),
                Image.asset(
                  size == 7
                      ? DesignKit.boardSize7
                      : DesignKit.boardSize5,
                  width: 118,
                  height: 118,
                  semanticLabel: caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              caption,
              style: SudaneseTheme.bodyBold.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

/// صينية الحجارة: صورة الصينية الفارغة، و7 حصوات
/// في مواقعها المقاسة من الصورة الكاملة (أول مركز
/// x=0.1095 وخطوة 0.1269، ومركز y=0.4035).
/// المختارة بحلقة ذهبية، وحجر الطرف الآخر مقفل ومعتم.
class _PebbleTray extends StatelessWidget {
  final int? selected;
  final int? locked;
  final ValueChanged<int> onPick;

  static const double _firstX = 0.1095;
  static const double _pitchX = 0.1269;
  static const double _centreY = 0.4035;
  static const double _pebbleW = 0.0985;

  const _PebbleTray({
    super.key,
    required this.selected,
    required this.locked,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trayW = constraints.maxWidth;
        final trayH = trayW * 400 / 1340;
        final pitch = _pitchX * trayW;
        final pebblePx = _pebbleW * trayW;
        return SizedBox(
          width: trayW,
          height: trayH,
          child: Stack(
            children: [
              Image.asset(
                DesignKit.trayEmpty,
                width: trayW,
                height: trayH,
                fit: BoxFit.fill,
              ),
              // في الصورة المرجعية الترتيب من اليسار:
              // فحمي … نيلي؛ أي أن الفهرس i يقف في
              // الموضع (6-i).
              for (var i = 0;
                  i < SudaneseTheme.pebbles.length;
                  i++)
                Positioned(
                  left: (_firstX + (6 - i) * _pitchX) * trayW -
                      pitch / 2,
                  top: _centreY * trayH - pitch / 2,
                  width: pitch,
                  height: pitch,
                  child: _TrayPebble(
                    index: i,
                    size: pebblePx,
                    selected: selected == i,
                    locked: locked == i,
                    onPick: onPick,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TrayPebble extends StatelessWidget {
  final int index;
  final double size;
  final bool selected;
  final bool locked;
  final ValueChanged<int> onPick;

  const _TrayPebble({
    required this.index,
    required this.size,
    required this.selected,
    required this.locked,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final def = SudaneseTheme.pebbles[index];
    return GestureDetector(
      onTap: locked ? null : () => onPick(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: selected ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Opacity(
          opacity: locked ? 0.35 : 1.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (selected)
                Container(
                  width: size * 1.3,
                  height: size * 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SudaneseTheme.sunGold,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SudaneseTheme.sunGold
                            .withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              Image.asset(
                DesignKit.pebbleAsset(index),
                width: size,
                height: size,
                semanticLabel: def.nameAr,
              ),
              if (locked)
                const Icon(
                  Icons.lock,
                  size: 16,
                  color: SudaneseTheme.cream,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر "يلا": صورة الطبق الدائري من الحزمة.
/// جاهز: ينبض. عند النقر: يدور مرة واحدة.
class _YallaButton extends StatelessWidget {
  final bool ready;
  final Animation<double> pulse;
  final Animation<double> spin;
  final VoidCallback onTap;

  const _YallaButton({
    required this.ready,
    required this.pulse,
    required this.spin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = Strings(AppSettings.instance.isArabic);
    return GestureDetector(
      onTap: ready ? onTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([pulse, spin]),
        builder: (context, child) {
          final scale = ready ? 1.0 + pulse.value * 0.05 : 1.0;
          return Transform.scale(
            scale: scale,
            child: RotationTransition(
              turns: spin,
              child: Opacity(
                opacity: ready ? 1.0 : 0.45,
                child: child,
              ),
            ),
          );
        },
        child: Image.asset(
          DesignKit.btnYalla,
          width: 92,
          semanticLabel: s.letsGo,
        ),
      ),
    );
  }
}
