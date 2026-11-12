import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/sudanese_theme.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../game/seega_engine.dart';
import '../game/seega_ai.dart';
import '../game/sound_manager.dart';
import '../services/settings_store.dart';
import '../ui/painters/mat_painter.dart';
import '../ui/painters/board_painter.dart';
import '../ui/painters/elder_painter.dart';
import '../ui/painters/lantern_painter.dart';
import '../ui/painters/tabaq_painter.dart';
import '../ui/widgets/wood_token.dart';
import '../ui/widgets/arched_sheet.dart';
import '../ui/widgets/plank_button.dart';
import 'home_screen.dart';

class GameScreen extends StatefulWidget {
  final int boardSize;
  final bool isTwoPlayer;
  final AIDifficulty difficulty;
  final Color p1Color;
  final Color p2Color;

  const GameScreen({
    super.key,
    required this.boardSize,
    required this.isTwoPlayer,
    required this.difficulty,
    required this.p1Color,
    required this.p2Color,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SeegaEngine engine;
  Point<int>? selectedPit;
  List<Point<int>> legalTargets = [];
  Point<int>? hintFrom;
  Point<int>? hintTo;
  bool aiBusy = false;

  @override
  void initState() {
    super.initState();
    engine = SeegaEngine(size: widget.boardSize);
  }

  void _handlePitTap(int r, int c) {
    if (aiBusy || engine.phase == GamePhase.gameOver) return;
    if (!widget.isTwoPlayer && engine.currentTurn == Player.p2) return;

    setState(() {
      hintFrom = null;
      hintTo = null;

      if (engine.phase == GamePhase.placement) {
        if (engine.placeStone(r, c)) {
          SoundManager.place();
          _checkAndRunAI();
        } else {
          SoundManager.invalid();
        }
      } else if (engine.phase == GamePhase.movement) {
        if (engine.board[r][c] == engine.currentTurn) {
          if (selectedPit == Point(r, c)) {
            selectedPit = null;
            legalTargets = [];
          } else {
            selectedPit = Point(r, c);
            legalTargets = engine.getLegalTargets(r, c);
            SoundManager.select();
          }
        } else if (selectedPit != null && legalTargets.contains(Point(r, c))) {
          final res = engine.moveStone(selectedPit!.x, selectedPit!.y, r, c);
          selectedPit = null;
          legalTargets = [];
          if (res != null) {
            SoundManager.moveLand();
            if (res.captured.isNotEmpty) SoundManager.capture(res.captured.length);
            if (engine.phase == GamePhase.gameOver) {
              _onGameOver();
            } else {
              _checkAndRunAI();
            }
          }
        } else {
          SoundManager.invalid();
        }
      }
    });
  }

  void _checkAndRunAI() {
    if (widget.isTwoPlayer || engine.phase == GamePhase.gameOver || engine.currentTurn != Player.p2) return;
    setState(() => aiBusy = true);
    Timer(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      if (engine.phase == GamePhase.placement) {
        final pt = SeegaAI.choosePlacement(engine, Player.p2);
        setState(() {
          engine.placeStone(pt.x, pt.y);
          SoundManager.place();
          aiBusy = false;
        });
        if (engine.currentTurn == Player.p2 && engine.phase != GamePhase.gameOver) _checkAndRunAI();
      } else if (engine.phase == GamePhase.movement) {
        final move = SeegaAI.chooseMove(engine, Player.p2, widget.difficulty);
        setState(() {
          if (move != null) {
            final res = engine.moveStone(move.fromR, move.fromC, move.toR, move.toC);
            SoundManager.moveLand();
            if (res != null && res.captured.isNotEmpty) SoundManager.capture(res.captured.length);
          }
          aiBusy = false;
        });
        if (engine.phase == GamePhase.gameOver) {
          _onGameOver();
        } else if (engine.currentTurn == Player.p2) {
          _checkAndRunAI();
        }
      }
    });
  }

  void _showHint() {
    if (aiBusy || engine.phase != GamePhase.movement || engine.currentTurn != Player.p1) return;
    final suggestion = SeegaAI.chooseMove(engine, Player.p1, AIDifficulty.medium);
    if (suggestion != null) {
      SoundManager.play('hint.wav');
      setState(() {
        hintFrom = Point(suggestion.fromR, suggestion.fromC);
        hintTo = Point(suggestion.toR, suggestion.toC);
      });
    }
  }

  void _undoMove() {
    if (aiBusy || !engine.canUndo()) return;
    SoundManager.play('undo.wav');
    setState(() {
      engine.undo();
      selectedPit = null;
      legalTargets = [];
    });
  }

  void _onGameOver() async {
    bool isAr = AlseejaApp.of(context)?.isArabic ?? true;
    String title, subtitle;
    bool isWin = false;

    if (engine.outcome == GameOutcome.draw) {
      title = AppStrings.get('drawTitle', isArabic: isAr);
      subtitle = AppStrings.get('drawMsg', isArabic: isAr);
      SoundManager.draw();
      if (!widget.isTwoPlayer) await SettingsStore.recordDraw();
    } else if (widget.isTwoPlayer) {
      isWin = true;
      title = AppStrings.get('victoryTitle', isArabic: isAr);
      subtitle = engine.outcome == GameOutcome.p1Win ? AppStrings.get('p1Wins', isArabic: isAr) : AppStrings.get('p2Wins', isArabic: isAr);
      SoundManager.win();
    } else if (engine.outcome == GameOutcome.p1Win) {
      isWin = true;
      title = AppStrings.get('victoryTitle', isArabic: isAr);
      subtitle = AppStrings.get('victoryMsg', isArabic: isAr);
      SoundManager.win();
      await SettingsStore.recordWin();
    } else {
      title = AppStrings.get('lossTitle', isArabic: isAr);
      subtitle = AppStrings.get('lossMsg', isArabic: isAr);
      SoundManager.lose();
      await SettingsStore.recordLoss();
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => ArchedSheet(
        topBadge: CustomPaint(size: const Size(88, 88), painter: TabaqPainter()),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontFamily: 'ReemKufi', fontSize: 38, color: isWin ? SudaneseTheme.tabaqRed : SudaneseTheme.earthBlack)),
            Text(subtitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SudaneseTheme.earthBlack)),
            if (!widget.isTwoPlayer) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statChip(AppStrings.get('win', isArabic: isAr), SettingsStore.wins),
                  _statChip(AppStrings.get('loss', isArabic: isAr), SettingsStore.losses),
                  _statChip(AppStrings.get('draw', isArabic: isAr), SettingsStore.draws),
                ],
              ),
            ],
            const SizedBox(height: 20),
            PlankButton(
              title: AppStrings.get('playAgain', isArabic: isAr),
              subtitle: AppStrings.get('sameSettings', isArabic: isAr),
              color: SudaneseTheme.tabaqRed,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  engine = SeegaEngine(size: widget.boardSize);
                  selectedPit = null;
                  legalTargets = [];
                });
              },
            ),
            const SizedBox(height: 12),
            PlankButton(
              title: AppStrings.get('backToHome', isArabic: isAr),
              color: SudaneseTheme.mudBrickDark,
              onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, int val) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(color: SudaneseTheme.straw.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text('$val', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SudaneseTheme.earthBlack)),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SudaneseTheme.earthBlack)),
          ],
        ),
      );

  Widget _buildBowl(String label, int count, Color stoneColor) => Column(
        children: [
          Container(
            width: 68,
            height: 36,
            decoration: BoxDecoration(
              color: SudaneseTheme.mudBrickLight,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
              border: Border.all(color: SudaneseTheme.earthBlack, width: 2),
            ),
            child: Center(
              child: Wrap(
                spacing: 2,
                children: List.generate(min(count, 5), (_) => Container(width: 9, height: 9, decoration: BoxDecoration(color: stoneColor, shape: BoxShape.circle))),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('$label $count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SudaneseTheme.earthBlack)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    bool isAr = AlseejaApp.of(context)?.isArabic ?? true;
    int p1Left = engine.phase == GamePhase.placement ? engine.totalStonesPerPlayer - engine.p1Placed : engine.p1OnBoard;
    int p2Left = engine.phase == GamePhase.placement ? engine.totalStonesPerPlayer - engine.p2Placed : engine.p2OnBoard;

    String statusLine = aiBusy
        ? AppStrings.get('aiThinking', isArabic: isAr)
        : (engine.phase == GamePhase.placement
            ? AppStrings.get('placeStones', isArabic: isAr)
            : (widget.isTwoPlayer
                ? (engine.currentTurn == Player.p1 ? AppStrings.get('p1Turn', isArabic: isAr) : AppStrings.get('p2Turn', isArabic: isAr))
                : AppStrings.get('turnPrompt', isArabic: isAr)));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: MatPainter()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WoodToken(
                        icon: Icons.pause,
                        size: 44,
                        onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
                      ),
                      _buildBowl(AppStrings.get('captured', isArabic: isAr), engine.p2Captured, widget.p1Color),
                      Column(
                        children: [
                          if (!widget.isTwoPlayer) CustomPaint(size: const Size(66, 68), painter: ElderPainter(difficulty: widget.difficulty)),
                          Text(
                            widget.isTwoPlayer ? AppStrings.get('p2', isArabic: isAr) : AppStrings.get('${widget.difficulty.name}Name', isArabic: isAr),
                            style: const TextStyle(fontFamily: 'ReemKufi', fontSize: 16, color: SudaneseTheme.earthBlack),
                          ),
                        ],
                      ),
                      _buildBowl(AppStrings.get('remaining', isArabic: isAr), p2Left, widget.p2Color),
                      CustomPaint(size: const Size(38, 48), painter: LanternPainter(isLit: engine.currentTurn == Player.p2)),
                    ],
                  ),
                  const Spacer(),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double boardDim = min(constraints.maxWidth, 366.0);
                      return GestureDetector(
                        onTapDown: (details) {
                          double pad = 14.0;
                          double cell = (boardDim - pad * 2) / widget.boardSize;
                          int c = ((details.localPosition.dx - pad) / cell).floor();
                          int r = ((details.localPosition.dy - pad) / cell).floor();
                          if (r >= 0 && r < widget.boardSize && c >= 0 && c < widget.boardSize) _handlePitTap(r, c);
                        },
                        child: CustomPaint(
                          size: Size(boardDim, boardDim),
                          painter: BoardPainter(
                            size: widget.boardSize,
                            board: engine.board,
                            p1Color: widget.p1Color,
                            p2Color: widget.p2Color,
                            selectedPit: selectedPit,
                            legalTargets: legalTargets,
                            hintFrom: hintFrom,
                            hintTo: hintTo,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(statusLine, style: const TextStyle(fontFamily: 'ReemKufi', fontSize: 18, color: SudaneseTheme.earthBlack)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBowl(AppStrings.get('captured', isArabic: isAr), engine.p1Captured, widget.p2Color),
                      if (!widget.isTwoPlayer) ...[
                        WoodToken(icon: Icons.lightbulb_outline, label: AppStrings.get('hint', isArabic: isAr), onTap: _showHint),
                        WoodToken(icon: Icons.undo, label: AppStrings.get('undo', isArabic: isAr), onTap: _undoMove),
                      ],
                      _buildBowl(AppStrings.get('remaining', isArabic: isAr), p1Left, widget.p1Color),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 18, height: 18, decoration: BoxDecoration(color: widget.p1Color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(widget.isTwoPlayer ? AppStrings.get('p1', isArabic: isAr) : AppStrings.get('you', isArabic: isAr), style: const TextStyle(fontFamily: 'ReemKufi', fontSize: 20, color: SudaneseTheme.earthBlack)),
                      const SizedBox(width: 10),
                      CustomPaint(size: const Size(34, 42), painter: LanternPainter(isLit: engine.currentTurn == Player.p1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
