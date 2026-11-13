// شاشة اللعب v4 + حزمة التصميم: البرش كامل الشاشة.
// مقعد الخصم أعلى، لوحة الرمل في الوسط، سطر الدور نصاً
// بلا صندوق، صحون الطين والفوانيس، وصفحة النتيجة المقوّسة.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/seega_ai.dart';
import '../game/sound_manager.dart';
import '../game/turn_controller.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/design_kit.dart';
import '../ui/painters/confetti.dart';
import '../ui/sand_board.dart';
import '../ui/sheets.dart';
import '../ui/widgets/arched_sheet.dart';
import '../ui/widgets/bowl_counter.dart';

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

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late final TurnController _controller;
  final BoardFx _fx = BoardFx();
  int _seenNonce = 0;

  late final AnimationController _tilt;
  late final AnimationController _bow;
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
    _controller.addListener(_onControllerEvent);
    _tilt = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _bow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _pillTimer?.cancel();
    _tilt.dispose();
    _bow.dispose();
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
          if (_controller.winner == 1) {
            _bow.forward(from: 0);
          }
          break;
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
  }

  void _onPitTap(int r, int c) {
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

  String _nameFor(int player) {
    if (!widget.config.vsComputer) {
      return player == 1 ? s.player1 : s.player2;
    }
    return player == 1 ? s.you : s.computer;
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmLeave();
      },
      child: AnimatedBuilder(
        animation: AppSettings.instance,
        builder: (context, child) {
          final controller = _controller;
          final engine = controller.engine;
          final isGameOver = controller.phase == TurnPhase.gameOver;

          final content = Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  DesignKit.bgStraw,
                  fit: BoxFit.cover,
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _topTokens(),
                      const SizedBox(height: 2),
                      // شريط منسوج تحت الأزرار العلوية.
                      SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          DesignKit.bandWeave,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _opponentBlock(),
                      const SizedBox(height: 4),
                      // ---- اللوحة ----
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 366,
                              maxHeight: 366,
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: SandBoard(
                                engine: engine,
                                controller: controller,
                                fx: _fx,
                                p1Pebble: widget.config.p1Pebble,
                                p2Pebble: widget.config.p2Pebble,
                                strings: s,
                                onTapPit: _onPitTap,
                                onFxDone: () =>
                                    controller.finishAnimation(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _turnLineWidget(),
                      const SizedBox(height: 6),
                      _playerZone(),
                      const SizedBox(height: 4),
                      _nameRow(),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                // رسالة عائمة.
                if (_pill != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.of(context).size.height * 0.42,
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
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
                  ),
                // شاشة النتيجة.
                if (isGameOver) _resultOverlay(),
              ],
            ),
          );
          return content;
        },
      ),
    );
  }

  // ---------------------------------------------------------- الأزرار العلوية

  Widget _topTokens() {
    final settings = AppSettings.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الترتيب RTL: الأول يميناً — الصوت يميناً والإيقاف يساراً
          // كما في اللوحة.
          _TokenButton(
            asset: settings.soundOn
                ? DesignKit.tokenSound
                : DesignKit.tokenSoundOff,
            label: settings.soundOn ? s.soundOn : s.soundOff,
            onTap: () async {
              final on = !settings.soundOn;
              await settings.setSoundOn(on);
              if (on) SoundManager.instance.tap();
              setState(() {});
            },
          ),
          _TokenButton(
            asset: DesignKit.tokenPause,
            label: s.menu,
            onTap: _showPauseMenu,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- مقعد الخصم

  Widget _opponentBlock() {
    final controller = _controller;
    final engine = controller.engine;
    final oppTurn = engine.currentPlayer == 2 &&
        controller.phase != TurnPhase.gameOver;
    final figure = widget.config.vsComputer
        ? _OpponentFigure(
            difficulty: widget.config.difficulty,
            tilt: _tilt,
            thinking: controller.isAiThinking,
            bow: _bow,
            bowing: controller.phase == TurnPhase.gameOver &&
                controller.winner == 1,
          )
        : _P2Seat(
            pebble: SudaneseTheme.pebbles[widget.config.p2Pebble],
            name: s.player2,
          );
    final block = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الفانوس بجانب الشخصية: مضيء عند دور الخصم،
              // مع وميض خفيف.
              AnimatedBuilder(
                animation: _tilt,
                builder: (context, child) {
                  final flicker = oppTurn
                      ? 0.82 +
                          0.18 *
                              (0.5 +
                                  0.5 *
                                      math.sin(
                                          _tilt.value * 2 * math.pi * 3))
                      : 1.0;
                  return Opacity(opacity: flicker, child: child);
                },
                child: Image.asset(
                  oppTurn ? DesignKit.lanternLit : DesignKit.lantern,
                  width: 36,
                ),
              ),
              const SizedBox(width: 10),
              figure,
            ],
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الترتيب RTL: الأول يميناً — «باقي» يميناً و«أكلت» يساراً
              // كما في اللوحة.
              BowlCounter(
                pebble: SudaneseTheme.pebbles[widget.config.p2Pebble],
                count: _leftOf(2),
                label: s.remaining,
              ),
              BowlCounter(
                // صحن «أكلت» فيه حجارة الخصم المأكولة — أي حجر
                // اللاعب 1، لا حجر صاحب الصحن.
                pebble: SudaneseTheme.pebbles[widget.config.p1Pebble],
                count: _capturedOf(2),
                label: s.captured,
              ),
            ],
          ),
        ),
      ],
    );
    if (widget.config.vsComputer) return block;
    return RotatedBox(quarterTurns: 2, child: block);
  }

  // ---------------------------------------------------------- سطر الدور

  Widget _turnLineWidget() {
    final controller = _controller;
    final engine = controller.engine;
    final text = _turnLine();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: SudaneseTheme.heading.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (engine.placingPhase) ...[
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final filled = i < controller.placedThisTurn;
              final def = SudaneseTheme.pebbles[
                  engine.currentPlayer == 1
                      ? widget.config.p1Pebble
                      : widget.config.p2Pebble];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? def.base : SudaneseTheme.sandDark,
                  border: Border.all(
                      color: SudaneseTheme.earthBlack, width: 1),
                ),
              );
            }),
          ),
        ],
        if (controller.isAiThinking) ...[
          const SizedBox(width: 8),
          const _ThinkingDots(),
        ],
      ],
    );
  }

  // ---------------------------------------------------------- منطقة اللاعب

  Widget _playerZone() {
    final controller = _controller;
    final canHint = controller.isHumanTurn && !controller.isPlacing;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الترتيب RTL: الأول يميناً — «باقي» يميناً و«أكلت» يساراً
          // كما في اللوحة؛ زرّا التراجع والتلميح بينهما.
          BowlCounter(
            pebble: SudaneseTheme.pebbles[widget.config.p1Pebble],
            count: _leftOf(1),
            label: s.remaining,
          ),
          if (widget.config.vsComputer) ...[
            _TokenButton(
              asset: DesignKit.tokenUndo,
              label: s.undo,
              size: 52,
              enabled: controller.canUndo,
              onTap: () {
                controller.undo();
                setState(() {
                  _fx.move = null;
                  _fx.hintMove = null;
                });
              },
            ),
            _TokenButton(
              asset: DesignKit.tokenHint,
              label: s.hint,
              size: 52,
              enabled: canHint,
              onTap: _onHint,
            ),
          ],
          BowlCounter(
            // صحن «أكلت» فيه حجارة الخصم المأكولة — أي حجر
            // اللاعب 2، لا حجر صاحب الصحن.
            pebble: SudaneseTheme.pebbles[widget.config.p2Pebble],
            count: _capturedOf(1),
            label: s.captured,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- صف الاسم

  Widget _nameRow() {
    final engine = _controller.engine;
    final myTurn = engine.currentPlayer == 1 &&
        _controller.phase != TurnPhase.gameOver;
    final name = widget.config.vsComputer ? s.you : s.player1;
    final isYouBanner =
        widget.config.vsComputer && myTurn;
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            isYouBanner
                ? DesignKit.turnBannerYou
                : DesignKit.turnBanner,
            height: 44,
            semanticLabel: widget.config.vsComputer ? name : null,
          ),
          if (!widget.config.vsComputer)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  DesignKit.pebbleAsset(widget.config.p1Pebble),
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: SudaneseTheme.heading.copyWith(fontSize: 18),
                ),
              ],
            ),
          Positioned(
            left: 0,
            child: Image.asset(
              DesignKit.turnLantern,
              width: 34,
              height: 34,
            ),
          ),
        ],
      ),
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

  // ---------------------------------------------------------- النتيجة

  Widget _resultOverlay() {
    final controller = _controller;
    final winner = controller.winner;
    final isDraw = winner == 0;
    final isWin = winner == 1 ||
        (!widget.config.vsComputer && winner != null && winner != 0);
    final isLoss = widget.config.vsComputer && winner == 2;

    String title;
    String subtitle;
    if (isDraw) {
      title = s.draw;
      subtitle = s.drawLine;
    } else if (widget.config.vsComputer) {
      if (winner == 1) {
        title = s.victory;
        subtitle = s.youWon;
      } else {
        title = s.computerWon;
        subtitle = s.tryAgainLine;
      }
    } else {
      title = s.playerWon(_nameFor(winner!));
      subtitle = s.youWon;
    }

    final btnW = math.min(
      MediaQuery.of(context).size.width * 0.72,
      300.0,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        // تعتيم اللوحة خلف الصفحة.
        Container(color: Colors.black.withValues(alpha: 0.55)),
        if (isWin) const ConfettiOverlay(),
        // أعلام صغيرة أعلى الصفحة.
        Positioned(
          top: 48,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final flag in DesignKit.confettiFlags)
                Image.asset(flag, width: 56),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ميدالية الطبق على حافة الصفحة العلوية.
              Opacity(
                opacity: isLoss ? 0.55 : 1.0,
                child: Image.asset(
                  DesignKit.plateRainbow,
                  width: 118,
                  height: 118,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -46),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(DesignKit.resultSheet),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  padding:
                      const EdgeInsets.fromLTRB(24, 78, 24, 26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isWin)
                        Image.asset(
                          DesignKit.resultTitle,
                          width: btnW,
                          semanticLabel: title,
                        )
                      else
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            style: SudaneseTheme.display.copyWith(
                              fontSize: 40,
                              color: SudaneseTheme.ink,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: SudaneseTheme.bodyBold,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.config.vsComputer) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _SessionChip(
                              count: controller.sessionWins,
                              label: s.wins,
                            ),
                            const SizedBox(width: 10),
                            _SessionChip(
                              count: controller.sessionLosses,
                              label: s.losses,
                            ),
                            const SizedBox(width: 10),
                            _SessionChip(
                              count: controller.sessionDraws,
                              label: s.draws,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Center(
                        child: KitImageButton(
                          asset: DesignKit.btnRectRed,
                          semanticLabel: s.playAgain,
                          width: btnW,
                          onPressed: () {
                            _controller.restart();
                            setState(() {
                              _fx.move = null;
                              _fx.hintMove = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: KitImageButton(
                          asset: DesignKit.btnRectBrown,
                          semanticLabel: s.backHome,
                          width: btnW,
                          onPressed: () => Navigator.of(context)
                              .popUntil((r) => r.isFirst),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// زر دائري من صورة (إيقاف/صوت/تراجع/تلميح): منطقة لمس 48dp.
/// المعطّل يظهر معتماً ولا يستجيب.
class _TokenButton extends StatelessWidget {
  final String asset;
  final String label;
  final double size;
  final bool enabled;
  final VoidCallback onTap;

  const _TokenButton({
    required this.asset,
    required this.label,
    this.size = 48,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.45,
          child: Image.asset(
            asset,
            width: size,
            height: size,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}

/// شخصية الخصم (ضد الكمبيوتر): صورة صدرية من الحزمة،
/// تميل رأسها أثناء التفكير وتنحني عند فوز اللاعب.
class _OpponentFigure extends StatelessWidget {
  final Difficulty difficulty;
  final Animation<double> tilt;
  final bool thinking;
  final Animation<double> bow;
  final bool bowing;

  const _OpponentFigure({
    required this.difficulty,
    required this.tilt,
    required this.thinking,
    required this.bow,
    required this.bowing,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([tilt, bow]),
      builder: (context, child) {
        // تنفّس هادئ طوال اللعب، وميل أوضح عندما يفكر الخصم.
        final breath = math.sin(tilt.value * 2 * math.pi) * 0.018;
        final tiltValue = breath +
            (thinking ? math.sin(tilt.value * 2 * math.pi) * 0.085 : 0.0);
        final bowDy = bowing ? bow.value * 10 : 0.0;
        return Transform.translate(
          offset: Offset(0, bowDy),
          child: Transform.rotate(
            angle: tiltValue,
            child: child,
          ),
        );
      },
      child: Image.asset(
        DesignKit.portraitFor(difficulty),
        height: 132,
      ),
    );
  }
}

/// مقعد اللاعب 2 (لاعبان): لوح قش فيه حجره واسمه.
class _P2Seat extends StatelessWidget {
  final PebbleDef pebble;
  final String name;

  const _P2Seat({required this.pebble, required this.name});

  @override
  Widget build(BuildContext context) {
    final index = SudaneseTheme.pebbles.indexOf(pebble);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: SudaneseTheme.straw.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SudaneseTheme.earthBlack, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            DesignKit.pebbleAsset(index < 0 ? 0 : index),
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: SudaneseTheme.heading.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

/// نقاط التفكير الثلاث.
class _ThinkingDots extends StatefulWidget {
  const _ThinkingDots();

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_c.value * 3 - i).clamp(0.0, 1.0));
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SudaneseTheme.ink.withValues(
                    alpha: 0.3 + 0.7 * (1 - phase)),
              ),
            );
          }),
        );
      },
    );
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
          color: red
              ? SudaneseTheme.tabaqRed
              : SudaneseTheme.woodDark,
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

/// بطاقة إحصاء في صفحة النتيجة: صورة البطاقة من الحزمة
/// وتحتها العدد والتسمية نصاً.
class _SessionChip extends StatelessWidget {
  final int count;
  final String label;

  const _SessionChip({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(DesignKit.statCard),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: SudaneseTheme.display.copyWith(fontSize: 26),
            ),
            Text(
              label,
              style: SudaneseTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}
