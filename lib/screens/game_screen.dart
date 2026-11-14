// شاشة اللعب: شاشات الحزمة الجديدة (AlsijaGame + AlsijaResult)
// موصولة بمحرّك اللعبة الحقيقي عبر TurnController — القواعد
// والذكاء الاصطناعي والأصوات كما هي، بلا أي تغيير.
//
// اللوحة هي لوحة الرمل الأصلية (SandBoard) كما كانت تماماً:
// الانزلاق 240ms، الأكل 320ms، السقوط، الاهتزاز، الموجة،
// التلميح، الأثر — وأحداث TurnController ترفع عدّادات BoardFx،
// وSandBoard تستدعي onFxDone فينادي finishAnimation، فلا يتحرك
// الذكاء الاصطناعي ولا يستقر الدور إلا بعد انتهاء الحركة.
// شكل اللوحة والحجارة فقط من الحزمة الجديدة (BoardPainter
// وPebblePainter أُعيد رسمهما على شكل الحزمة).
import 'dart:async';

import 'package:flutter/material.dart';

import '../game/seega_ai.dart';
import '../game/sound_manager.dart';
import '../game/turn_controller.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/alsija_pebbles.dart';
import '../ui/alsija_screens.dart';
import '../ui/sand_board.dart';
import '../ui/sheets.dart';
import '../ui/widgets/arched_sheet.dart';

class GameConfig {
  final int boardSize;
  final bool vsComputer;
  final Difficulty difficulty;
  final int p1Pebble;
  final int p2Pebble;

  const GameConfig({
    required this.boardSize,
    required this.vsComputer,
    this.difficulty = Difficulty.medium,
    required this.p1Pebble,
    required this.p2Pebble,
  });
}

class GameScreen extends StatefulWidget {
  final GameConfig config;

  /// وحدة تحكم جاهزة (للاختبارات فقط — لإعداد لوحة محددة).
  final TurnController? debugController;

  const GameScreen({super.key, required this.config, this.debugController});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final TurnController _controller;
  late final Listenable _rebuilder;
  int _seenNonce = 0;

  /// إشارات الحركات إلى SandBoard (انزلاق/أكل/سقوط/اهتزاز/
  /// موجة/تلميح) — BoardFx الأصلية من اللوحة الأصلية.
  final _fx = BoardFx();

  String? _pill;
  Timer? _pillTimer;

  Strings get s => Strings(AppSettings.instance.isArabic);

  @override
  void initState() {
    super.initState();
    _controller = widget.debugController ??
        TurnController(
          boardSize: widget.config.boardSize,
          vsComputer: widget.config.vsComputer,
          difficulty: widget.config.difficulty,
        );
    _rebuilder = Listenable.merge([_controller, AppSettings.instance]);
    _controller.addListener(_onControllerEvent);
  }

  @override
  void dispose() {
    _pillTimer?.cancel();
    _controller.removeListener(_onControllerEvent);
    if (widget.debugController == null) _controller.dispose();
    super.dispose();
  }

  void _onControllerEvent() {
    if (_controller.eventNonce == _seenNonce) return;
    _seenNonce = _controller.eventNonce;
    final event = _controller.lastEvent;
    if (!mounted) return;
    setState(() {
      switch (event) {
        case ControllerEvent.placed:
          _fx.placedNonce++;
          _fx.placedSquare = _controller.lastPlaced;
          break;
        case ControllerEvent.moved:
          _fx.moveNonce++;
          _fx.move = _controller.lastMoveResult;
          break;
        case ControllerEvent.invalid:
          _fx.shakeNonce++;
          _fx.shakeSquare = _controller.lastInvalidSquare;
          break;
        case ControllerEvent.placementEnded:
          _fx.waveNonce++;
          _showPill(s.letsPlay);
          break;
        case ControllerEvent.pass:
          _showPill(s.passTurn);
          break;
        case ControllerEvent.gameOver:
        case ControllerEvent.undo:
        case ControllerEvent.selected:
        case ControllerEvent.turnChanged:
        case null:
          break;
      }
    });
  }

  void _showPill(String message) {
    _pillTimer?.cancel();
    _pill = message;
    _pillTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _pill = null);
    });
    if (mounted) setState(() {});
  }

  void _onCellTap(int r, int c) {
    if (_controller.isPlacing) {
      _controller.placeStone(r, c);
    } else {
      _controller.tapTile(r, c);
    }
  }

  void _onHint() {
    final move = _controller.hint();
    if (move != null) {
      setState(() {
        _fx.hintNonce++;
        _fx.hintMove = move;
      });
    }
  }

  void _onUndo() {
    if (_controller.undo()) {
      setState(() {
        _fx.move = null;
        _fx.hintMove = null;
      });
    }
  }

  Future<void> _onSoundToggle() async {
    final settings = AppSettings.instance;
    final on = !settings.soundOn;
    await settings.setSoundOn(on);
    if (on) SoundManager.instance.tap();
  }

  String _nameFor(int player) {
    if (!widget.config.vsComputer) {
      return player == 1 ? s.player1 : s.player2;
    }
    return player == 1 ? s.you : s.computer;
  }

  /// سطر الدور كما في الشاشة الأصلية: يسمّي اللاعب الحالي،
  /// ويظهر حالة التوزيع (مع نقاط الأحجار الثلاثة في الواجهة).
  String _turnLine() {
    final controller = _controller;
    final engine = controller.engine;
    if (controller.phase == TurnPhase.gameOver) return '';
    if (engine.placingPhase) {
      if (widget.config.vsComputer && engine.currentPlayer == 2) {
        return s.computerPlacing;
      }
      if (widget.config.vsComputer) return s.yourTurnPlace;
      return '${s.turnOf(_nameFor(engine.currentPlayer))} — ${s.placeThree}';
    }
    if (controller.isAiThinking) return s.computerThinking;
    if (widget.config.vsComputer) return s.turnLineChoose;
    return s.turnOf(_nameFor(engine.currentPlayer));
  }

  int _capturedOf(int player) {
    final engine = _controller.engine;
    if (engine.placingPhase) return 0;
    return engine.stonesPerPlayer - engine.count(3 - player);
  }

  int _leftOf(int player) {
    final engine = _controller.engine;
    if (engine.placingPhase) return engine.remainingToPlace(player);
    return engine.count(player);
  }

  bool get _canHint =>
      widget.config.vsComputer &&
      _controller.isHumanTurn &&
      !_controller.isPlacing;

  // ---------------------------------------------------------- البناء

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmLeave();
      },
      child: AnimatedBuilder(
        animation: _rebuilder,
        builder: (context, child) {
          final isGameOver =
              _controller.phase == TurnPhase.gameOver;
          if (isGameOver) return _resultScreen();
          return Stack(
            fit: StackFit.expand,
            children: [
              _gameWidget(interactive: true),
              if (_pill != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.42,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: SudaneseTheme.earthBlack
                            .withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        _pill!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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

  /// لوحة اللعب الأصلية (SandBoard) داخل إطار الحزمة الجديدة:
  /// اللوحة مربعة 500×500 بوحدات التصميم، ممركزة في مساحة
  /// اللوحة 540×500. كل النقر على الخانات بيد SandBoard
  /// (onTapPit → المحرك)، وكل الحركات بيدها هي.
  Widget _gameWidget({required bool interactive}) {
    final controller = _controller;
    final engine = controller.engine;
    return AlsijaGame(
      playerColor: alsijaColorForPebble(widget.config.p1Pebble).value,
      opponentColor: alsijaColorForPebble(widget.config.p2Pebble).value,
      playerRemaining: _leftOf(1),
      opponentRemaining: _leftOf(2),
      playerCaptured: _capturedOf(1),
      opponentCaptured: _capturedOf(2),
      playerTurn: engine.currentPlayer == 1,
      soundEnabled: AppSettings.instance.soundOn,
      opponent: opponentForDifficulty(widget.config.difficulty),
      onPause: interactive ? _showPauseMenu : null,
      onSound: interactive ? _onSoundToggle : null,
      onHint: interactive && _canHint ? _onHint : null,
      onUndo: interactive && controller.canUndo ? _onUndo : null,
      vsComputer: widget.config.vsComputer,
      player1Name: _nameFor(1),
      player2Name: _nameFor(2),
      turnLabel: _turnLine(),
      isPlacing: engine.placingPhase,
      placedThisTurn: controller.placedThisTurn,
      isAiThinking: controller.isAiThinking,
      board: Center(
        child: SandBoard(
          engine: engine,
          controller: controller,
          fx: _fx,
          p1Pebble: widget.config.p1Pebble,
          p2Pebble: widget.config.p2Pebble,
          strings: s,
          onTapPit: interactive ? _onCellTap : (_r, _c) {},
          onFxDone: () => _controller.finishAnimation(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------- النتيجة

  Widget _resultScreen() {
    final controller = _controller;
    final winner = controller.winner;
    final isDraw = winner == 0;
    final AlsijaOutcome outcome;
    if (isDraw) {
      outcome = AlsijaOutcome.draw;
    } else if (widget.config.vsComputer) {
      outcome = winner == 1 ? AlsijaOutcome.win : AlsijaOutcome.loss;
    } else {
      // لاعبان: فوز أحدهما — عنوان الحزمة مثبّت («مبروووك!»)،
      // واسم الفائز يظهر في بطاقة النتيجة أدناه.
      outcome = AlsijaOutcome.win;
    }
    // لاعبان: بدلاً من بطاقات الجلسة (غير موجودة هنا) يظهر
    // اسم الفائز؛ التعادل بلا بطاقة.
    Widget? scoreCards;
    if (!widget.config.vsComputer) {
      scoreCards = isDraw
          ? const SizedBox.shrink()
          : Center(
              child: Text(
                s.playerWon(_nameFor(winner!)),
                style: SudaneseTheme.title.copyWith(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            );
    }
    return AlsijaResult(
      outcome: outcome,
      wins: controller.sessionWins,
      losses: controller.sessionLosses,
      draws: controller.sessionDraws,
      onReplay: () {
        _fx.move = null;
        _fx.hintMove = null;
        _controller.restart();
      },
      onHome: () => Navigator.of(context).popUntil((r) => r.isFirst),
      background: _gameWidget(interactive: false),
      scoreCards: scoreCards,
    );
  }

  // ---------------------------------------------------------- القائمة

  void _showPauseMenu() {
    showArchedSheet<void>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MenuRow(
            icon: Icons.play_arrow,
            label: s.resume,
            onTap: () => Navigator.of(context).pop(),
          ),
          _MenuRow(
            icon: Icons.refresh,
            label: s.restart,
            onTap: () {
              Navigator.of(context).pop();
              _controller.restart();
              setState(() {
                _fx.move = null;
                _fx.hintMove = null;
              });
            },
          ),
          _MenuRow(
            icon: Icons.settings,
            label: s.settings,
            onTap: () {
              Navigator.of(context).pop();
              showSettingsSheet(context, s);
            },
          ),
          _MenuRow(
            icon: Icons.help_outline,
            label: s.howToPlay,
            onTap: () {
              Navigator.of(context).pop();
              showHowToPlaySheet(context, s);
            },
          ),
          _MenuRow(
            icon: Icons.exit_to_app,
            label: s.leaveGame,
            onTap: () async {
              Navigator.of(context).pop();
              await _confirmLeave();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLeave() async {
    final leave = await showArchedSheet<bool>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.exitQuestion,
            style: SudaneseTheme.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ConfirmButton(
                  label: s.yes,
                  red: true,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ConfirmButton(
                  label: s.no,
                  red: false,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: SudaneseTheme.ink, size: 24),
            const SizedBox(width: 12),
            Text(label, style: SudaneseTheme.bodyBold),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final String label;
  final bool red;
  final VoidCallback onTap;

  const _ConfirmButton({
    required this.label,
    required this.red,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              red ? SudaneseTheme.tabaqRed : SudaneseTheme.woodDark,
          borderRadius: BorderRadius.circular(12),
          boxShadow: SudaneseTheme.hardShadow(),
        ),
        child: Text(
          label,
          style: SudaneseTheme.bodyBold.copyWith(
            color: SudaneseTheme.cream,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
