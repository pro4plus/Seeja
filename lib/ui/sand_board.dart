// لوحة الرمل التفاعلية: صورة اللوحة من حزمة التصميم،
// والحصى صور، مع كل الحركات (§7): سقوط، انزلاق، أكل،
// اهتزاز، موجة، تلميح، أثر.
// هندسة الثقوب مقاسة من PNG (1040×1040): مركز الخلية
// (r,c) = DesignKit.holeCenter — لا حشوة 8px بعد اليوم.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/seega_engine.dart';
import '../game/turn_controller.dart';
import '../l10n/strings.dart';
import '../theme/sudanese_theme.dart';
import 'design_kit.dart';

/// إشارات حركات ترسلها الشاشة إلى اللوحة (أرقام متسلسلة).
class BoardFx {
  int placedNonce = 0;
  List<int>? placedSquare;
  int moveNonce = 0;
  MoveResult? move;
  int shakeNonce = 0;
  List<int>? shakeSquare;
  int waveNonce = 0;
  int hintNonce = 0;
  SeegaMove? hintMove;
}

class SandBoard extends StatefulWidget {
  final SeegaEngine engine;
  final TurnController controller;
  final BoardFx fx;
  final int p1Pebble;
  final int p2Pebble;
  final Strings strings;
  final void Function(int row, int col) onTapPit;
  final VoidCallback onFxDone;

  const SandBoard({
    super.key,
    required this.engine,
    required this.controller,
    required this.fx,
    required this.p1Pebble,
    required this.p2Pebble,
    required this.strings,
    required this.onTapPit,
    required this.onFxDone,
  });

  @override
  State<SandBoard> createState() => _SandBoardState();
}

class _SandBoardState extends State<SandBoard>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _captureController;
  late final AnimationController _placeController;
  late final AnimationController _shakeController;
  late final AnimationController _waveController;
  late final AnimationController _hintController;
  late final AnimationController _trailController;
  late final AnimationController _pulseController;
  late final AnimationController _breathController;
  late final AnimationController _boardShakeController;

  int _seenPlaced = 0;
  int _seenMove = 0;
  int _seenShake = 0;
  int _seenWave = 0;
  int _seenHint = 0;

  MoveResult? _slidingMove;
  MoveResult? _capturingMove;
  List<int>? _placingSquare;
  List<int>? _shakingSquare;
  SeegaMove? _hintMove;
  bool _waveActive = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240));
    _captureController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _placeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240));
    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _hintController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));
    _trailController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _breathController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _boardShakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
  }

  @override
  void dispose() {
    for (final c in [
      _slideController,
      _captureController,
      _placeController,
      _shakeController,
      _waveController,
      _hintController,
      _trailController,
      _pulseController,
      _breathController,
      _boardShakeController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SandBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.engine != widget.engine) {
      _slidingMove = null;
      _capturingMove = null;
      _placingSquare = null;
      _shakingSquare = null;
      _hintMove = null;
      _waveActive = false;
    }
    final fx = widget.fx;
    if (fx.placedNonce != _seenPlaced) {
      _seenPlaced = fx.placedNonce;
      _placingSquare = fx.placedSquare;
      _placeController.forward(from: 0);
    }
    if (fx.moveNonce != _seenMove) {
      _seenMove = fx.moveNonce;
      _startMoveAnimation(fx.move);
    }
    if (fx.shakeNonce != _seenShake) {
      _seenShake = fx.shakeNonce;
      _shakingSquare = fx.shakeSquare;
      _shakeController.forward(from: 0);
    }
    if (fx.waveNonce != _seenWave) {
      _seenWave = fx.waveNonce;
      _waveActive = true;
      _waveController.forward(from: 0).then((_) {
        if (mounted) setState(() => _waveActive = false);
      });
    }
    if (fx.hintNonce != _seenHint) {
      _seenHint = fx.hintNonce;
      _hintMove = fx.hintMove;
      _hintController.forward(from: 0);
    }
  }

  Future<void> _startMoveAnimation(MoveResult? move) async {
    if (move == null) return;
    _slidingMove = move;
    _capturingMove = null;
    await _slideController.forward(from: 0);
    if (!mounted) return;
    setState(() => _slidingMove = null);
    _trailController.forward(from: 0);
    if (move.captured.isNotEmpty) {
      _capturingMove = move;
      if (move.captured.length > 1) {
        _boardShakeController.forward(from: 0);
      }
      await _captureController.forward(from: 0);
      if (!mounted) return;
      setState(() => _capturingMove = null);
    }
    widget.onFxDone();
  }

  int _pebbleIndex(int player) =>
      player == 1 ? widget.p1Pebble : widget.p2Pebble;

  List<List<int>> _destinations() {
    final sel = widget.controller.selectedTile;
    if (sel == null) return [];
    final out = <List<int>>[];
    for (final d in SeegaEngine.dirs) {
      final r = sel[0] + d[0];
      final c = sel[1] + d[1];
      if (widget.engine.inBounds(r, c) &&
          widget.engine.board[r][c] == 0) {
        out.add([r, c]);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final size = engine.size;
    final centre = size ~/ 2;
    final isCentreEmpty = engine.board[centre][centre] == 0;
    final destinations = _destinations();

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardPx =
              math.min(constraints.maxWidth, constraints.maxHeight);
          // خطوة الشبكة بالبكسلات (مقاسة من PNG).
          final pitch = DesignKit.holePitchPx(size, boardPx);
          // مركز خلية (r,c) داخل مربع اللوحة.
          Offset hole(int r, int c) =>
              DesignKit.holeCenter(size, boardPx, r, c);
          final sel = widget.controller.selectedTile;
          final lastMove = engine.lastMove;

          return AnimatedBuilder(
            animation: _boardShakeController,
            builder: (context, child) {
              final t = _boardShakeController.value;
              final dx = t > 0
                  ? math.sin(t * math.pi * 4) * 4 * (1 - t)
                  : 0.0;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: child,
              );
            },
            child: SizedBox(
              width: boardPx,
              height: boardPx,
              child: Stack(
                children: [
                  // ---- صورة اللوحة ----
                  Image.asset(
                    DesignKit.boardAsset(size),
                    width: boardPx,
                    height: boardPx,
                    fit: BoxFit.fill,
                  ),
                  // ---- نجمة الوسط (عندما تكون الحفرة فارغة) ----
                  if (isCentreEmpty)
                    Positioned(
                      left: hole(centre, centre).dx - pitch * 0.45,
                      top: hole(centre, centre).dy - pitch * 0.45,
                      width: pitch * 0.9,
                      height: pitch * 0.9,
                      child: IgnorePointer(
                        child: Image.asset(DesignKit.markerCentre),
                      ),
                    ),
                  // ---- مناطق النقر على الحُفَر (الخلية كاملة) ----
                  ..._buildPitTargets(size, pitch, hole),
                  // ---- علامات الوجهات القانونية ----
                  ..._buildDestinationRings(destinations, pitch, hole),
                  // ---- أثر الحركة الأخيرة (1.2 ث) ----
                  if (lastMove != null)
                    AnimatedBuilder(
                      animation: _trailController,
                      builder: (context, child) {
                        final t = _trailController.value;
                        if (t >= 1 && _trailController.isCompleted) {
                          return const SizedBox.shrink();
                        }
                        final dest = hole(
                            lastMove.toRow, lastMove.toCol);
                        final markerPx = pitch * 0.8;
                        return IgnorePointer(
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: Size(boardPx, boardPx),
                                painter: _TrailPainter(
                                  from: hole(
                                      lastMove.fromRow, lastMove.fromCol),
                                  to: dest,
                                  opacity: (1 - t) * 0.7,
                                ),
                              ),
                              Positioned(
                                left: dest.dx - markerPx / 2,
                                top: dest.dy - markerPx / 2,
                                width: markerPx,
                                height: markerPx,
                                child: Opacity(
                                  opacity: (1 - t) * 0.7,
                                  child: Image.asset(
                                    DesignKit.markerLastMove,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  // ---- الحصى ----
                  ..._buildPebbles(size, pitch, hole, sel),
                  // ---- حجر الانزلاق (فوق الحصى) ----
                  if (_slidingMove != null)
                    AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        final t = Curves.easeInOutCubic.transform(
                            _slideController.value);
                        final m = _slidingMove!.move;
                        final from =
                            hole(m.fromRow, m.fromCol);
                        final to = hole(m.toRow, m.toCol);
                        final pos = Offset.lerp(from, to, t)!;
                        final pebblePx = pitch * 0.88;
                        return Positioned(
                          left: pos.dx - pebblePx / 2,
                          top: pos.dy - pebblePx / 2,
                          child: Transform.scale(
                            scale: 1 + 0.08 * math.sin(t * math.pi),
                            child: _pebbleImage(
                                _pebbleIndex(_slidingMove!.mover),
                                pebblePx),
                          ),
                        );
                      },
                    ),
                  // ---- الحصى المأكولة ----
                  if (_capturingMove != null)
                    AnimatedBuilder(
                      animation: _captureController,
                      builder: (context, child) {
                        final t = _captureController.value;
                        final captured = _capturingMove!.captured;
                        final pebblePx = pitch * 0.88;
                        final widgets = <Widget>[];
                        for (var i = 0; i < captured.length; i++) {
                          final sq = captured[i];
                          final interval = Interval(
                            (i * 0.07).clamp(0.0, 0.8),
                            1.0,
                            curve: Curves.easeIn,
                          );
                          final lt = interval.transform(t);
                          final scale = 1 - lt;
                          final opacity = 1 - lt;
                          final rotation = lt * 0.44; // ~25°
                          final c = hole(sq[0], sq[1]);
                          widgets.add(Positioned(
                            left: c.dx - pebblePx / 2,
                            top: c.dy - pebblePx / 2,
                            child: Opacity(
                              opacity: opacity.clamp(0.0, 1.0),
                              child: Transform.rotate(
                                angle: rotation,
                                child: Transform.scale(
                                  scale: scale.clamp(0.0, 1.0),
                                  child: _pebbleImage(
                                    _pebbleIndex(
                                        3 - _capturingMove!.mover),
                                    pebblePx,
                                  ),
                                ),
                              ),
                            ),
                          ));
                          // شظايا قش/ذهب.
                          widgets.add(Positioned.fill(
                            child: _Fragments(
                              origin: c,
                              progress: lt,
                            ),
                          ));
                          // موجة صدمة من حجر الهبوط.
                          widgets.add(Positioned.fill(
                            child: _Shockwave(
                              origin: hole(
                                _capturingMove!.move.toRow,
                                _capturingMove!.move.toCol,
                              ),
                              progress: t,
                              maxRadius: pitch * 0.9,
                            ),
                          ));
                        }
                        if (captured.length > 1) {
                          final m = _capturingMove!.move;
                          final dx =
                              math.sin(t * math.pi * 4) * 2 * (1 - t);
                          final dest = hole(m.toRow, m.toCol);
                          widgets.add(Positioned(
                            left: dest.dx - 14 + dx,
                            top: dest.dy - pitch * 0.55,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: SudaneseTheme.sunGold,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                                boxShadow:
                                    SudaneseTheme.hardShadow(),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'x${captured.length}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ));
                        }
                        // الشظايا والموجة زخرفية فقط (أثناء الحركة
                        // المتحركة يُتجاهل الإدخال أصلاً).
                        return IgnorePointer(
                          child: Stack(children: widgets),
                        );
                      },
                    ),
                  // ---- سهم التلميح (3 ثوانٍ) ----
                  if (_hintMove != null && _hintController.isAnimating)
                    AnimatedBuilder(
                      animation: _hintController,
                      builder: (context, child) {
                        final pulse = 0.6 +
                            0.4 *
                                math.sin(
                                    _hintController.value * math.pi * 6);
                        return IgnorePointer(
                          child: CustomPaint(
                            size: Size(boardPx, boardPx),
                            painter: _HintPainter(
                              from: hole(_hintMove!.fromRow,
                                  _hintMove!.fromCol),
                              to: hole(_hintMove!.toRow,
                                  _hintMove!.toCol),
                              alpha: pulse,
                            ),
                          ),
                        );
                      },
                    ),
                  // ---- موجة نهاية التوزيع (500ms من الوسط) ----
                  if (_waveActive)
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        final t = Curves.easeOutCubic.transform(
                            _waveController.value);
                        return IgnorePointer(
                          child: CustomPaint(
                            size: Size(boardPx, boardPx),
                            painter: _WavePainter(
                              centre: hole(centre, centre),
                              radius: t * boardPx * 0.7,
                              alpha: (1 - t) * 0.6,
                            ),
                          ),
                        );
                      },
                    ),
                  // ---- وميض أحمر خفيف على الحفرة غير القانونية ----
                  if (_shakingSquare != null &&
                      _shakeController.isAnimating)
                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final t = _shakeController.value;
                        final r = _shakingSquare![0];
                        final c = _shakingSquare![1];
                        final centrePx = hole(r, c);
                        return Positioned(
                          left: centrePx.dx - pitch / 2,
                          top: centrePx.dy - pitch / 2,
                          child: Container(
                            width: pitch,
                            height: pitch,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SudaneseTheme.tabaqRed
                                  .withValues(alpha: 0.25 * (1 - t)),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPitTargets(
    int size,
    double pitch,
    Offset Function(int r, int c) hole,
  ) {
    final widgets = <Widget>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final centrePx = hole(r, c);
        widgets.add(Positioned(
          left: centrePx.dx - pitch / 2,
          top: centrePx.dy - pitch / 2,
          width: pitch,
          height: pitch,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onTapPit(r, c),
            child: Semantics(
              button: true,
              label: _pitLabel(r, c),
              child: const SizedBox.expand(),
            ),
          ),
        ));
      }
    }
    return widgets;
  }

  List<Widget> _buildDestinationRings(
    List<List<int>> destinations,
    double pitch,
    Offset Function(int r, int c) hole,
  ) {
    final widgets = <Widget>[];
    for (final d in destinations) {
      final r = d[0];
      final c = d[1];
      final centrePx = hole(r, c);
      final markerPx = pitch * 0.9;
      widgets.add(Positioned(
        left: centrePx.dx - markerPx / 2,
        top: centrePx.dy - markerPx / 2,
        width: markerPx,
        height: markerPx,
        // العلامة زخرفية فقط: يجب ألا تبتلع النقر على الحفرة.
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final s = 0.92 + _pulseController.value * 0.16;
              return Transform.scale(
                scale: s,
                child: Image.asset(DesignKit.markerDestination),
              );
            },
          ),
        ),
      ));
    }
    return widgets;
  }

  List<Widget> _buildPebbles(
    int size,
    double pitch,
    Offset Function(int r, int c) hole,
    List<int>? sel,
  ) {
    final engine = widget.engine;
    final widgets = <Widget>[];
    final pebblePx = pitch * 0.88;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final value = engine.board[r][c];
        if (value == 0) continue;
        if (_slidingMove != null &&
            _slidingMove!.move.toRow == r &&
            _slidingMove!.move.toCol == c) {
          continue;
        }
        if (_capturingMove != null &&
            _capturingMove!.captured
                .any((sq) => sq[0] == r && sq[1] == c)) {
          continue;
        }
        final isSelected = sel != null && sel[0] == r && sel[1] == c;
        final isPlacing = _placingSquare != null &&
            _placingSquare![0] == r &&
            _placingSquare![1] == c;
        final isShaking = _shakingSquare != null &&
            _shakingSquare![0] == r &&
            _shakingSquare![1] == c;
        final centrePx = hole(r, c);

        Widget pebble = _pebbleImage(
            value == 1 ? widget.p1Pebble : widget.p2Pebble, pebblePx);

        // الحصاة المحددة: حلقة ذهبية من الحزمة + رفع 12%.
        if (isSelected) {
          pebble = AnimatedBuilder(
            animation: _breathController,
            builder: (context, child) {
              final breath = 0.5 + _breathController.value * 0.5;
              return SizedBox(
                width: pebblePx,
                height: pebblePx,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Opacity(
                      opacity: 0.65 + breath * 0.35,
                      child: Image.asset(
                        DesignKit.markerSelected,
                        width: pebblePx * 1.3,
                        height: pebblePx * 1.3,
                      ),
                    ),
                    child!,
                  ],
                ),
              );
            },
            child: pebble,
          );
        }

        pebble = AnimatedScale(
          scale: isSelected ? 1.12 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedSlide(
            offset: isSelected ? const Offset(0, -0.10) : Offset.zero,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: pebble,
          ),
        );

        if (isPlacing) {
          pebble = AnimatedBuilder(
            animation: _placeController,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(
                  _placeController.value);
              final drop = (1 - t) * -28.0;
              final squash = t < 0.85 ? 1.0 : 1.0 - (t - 0.85) * 0.6;
              return SizedBox(
                width: pebblePx,
                height: pebblePx,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Opacity(
                      opacity: (1 - t) * 0.6,
                      child: Container(
                        width: pebblePx * (0.8 + t * 0.7),
                        height: pebblePx * (0.8 + t * 0.7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: SudaneseTheme.sunGold
                                .withValues(alpha: 0.8),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, drop),
                      child: Transform.scale(
                        scaleY: squash,
                        scaleX: 1 + (1 - squash) * 0.5,
                        child: child,
                      ),
                    ),
                  ],
                ),
              );
            },
            child: pebble,
          );
        }

        if (isShaking) {
          pebble = AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final t = _shakeController.value;
              final dx = math.sin(t * math.pi * 6) * 3 * (1 - t);
              return Transform.translate(
                offset: Offset(dx, 0),
                child: Opacity(
                  opacity: 1 - t * 0.2,
                  child: child,
                ),
              );
            },
            child: pebble,
          );
        }

        widgets.add(Positioned(
          left: centrePx.dx - pebblePx / 2,
          top: centrePx.dy - pebblePx / 2,
          // النقر على الحصاة نفسها يختارها (درس v3.1).
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => widget.onTapPit(r, c),
            child: pebble,
          ),
        ));
      }
    }
    return widgets;
  }

  Widget _pebbleImage(int pebbleIndex, double px) {
    return SizedBox(
      width: px,
      height: px,
      child: Image.asset(DesignKit.pebbleAsset(pebbleIndex)),
    );
  }

  String _pitLabel(int r, int c) {
    final s = widget.strings;
    final value = widget.engine.board[r][c];
    final centre = widget.engine.size ~/ 2;
    final parts = <String>[s.tileLabel(r, c)];
    if (r == centre && c == centre) parts.add(s.tileCentre);
    if (value == 0) {
      parts.add(s.tileEmpty);
    } else if (value == widget.engine.currentPlayer &&
        widget.controller.isHumanTurn) {
      parts.add(s.tileYourStone);
    } else {
      parts.add(s.tileOpponentStone);
    }
    return parts.join('، ');
  }
}

class _TrailPainter extends CustomPainter {
  final Offset from, to;
  final double opacity;

  _TrailPainter(
      {required this.from, required this.to, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SudaneseTheme.sandDark.withValues(alpha: opacity)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final middle = Offset.lerp(from, to, 0.5)!;
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(middle.dx + 5, middle.dy - 5, to.dx, to.dy);
    canvas.drawPath(path, paint);
    // حلقتان من الرمل المضغوط عند نقطة الانطلاق والهبوط، مع حبيبات متناثرة.
    for (var i = 0; i < 3; i++) {
      final t = i / 2;
      final p = Offset.lerp(from, to, t)!;
      canvas.drawCircle(p, 4 + i * 2.5, Paint()
        ..color = SudaneseTheme.sandDark.withValues(alpha: opacity * (0.65 - i * 0.15))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4);
    }
    for (var i = 0; i < 7; i++) {
      final t = (i + 1) / 8;
      final p = Offset.lerp(from, to, t)! + Offset(0, math.sin(t * math.pi) * -4);
      canvas.drawCircle(p, 1.2 + (i % 2), Paint()..color = SudaneseTheme.straw.withValues(alpha: opacity));
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class _HintPainter extends CustomPainter {
  final Offset from, to;
  final double alpha;

  _HintPainter(
      {required this.from, required this.to, required this.alpha});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SudaneseTheme.sunGold.withValues(alpha: alpha)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const head = 12.0;
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - head * math.cos(angle - 0.5),
          to.dy - head * math.sin(angle - 0.5))
      ..lineTo(to.dx - head * math.cos(angle + 0.5),
          to.dy - head * math.sin(angle + 0.5))
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _HintPainter oldDelegate) =>
      oldDelegate.alpha != alpha;
}

class _WavePainter extends CustomPainter {
  final Offset centre;
  final double radius;
  final double alpha;

  _WavePainter(
      {required this.centre, required this.radius, required this.alpha});

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0) return;
    final paint = Paint()
      ..color = SudaneseTheme.sunGold.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(centre, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.radius != radius;
}

/// شظايا قش/ذهب تتطاير من الحصاة المأكولة.
class _Fragments extends StatelessWidget {
  final Offset origin;
  final double progress;

  const _Fragments({required this.origin, required this.progress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FragmentsPainter(origin: origin, progress: progress),
    );
  }
}

class _FragmentsPainter extends CustomPainter {
  final Offset origin;
  final double progress;

  _FragmentsPainter({required this.origin, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(5);
    for (var i = 0; i < 7; i++) {
      final a = rng.nextDouble() * math.pi * 2;
      final d = progress * (14 + rng.nextDouble() * 18);
      final p = origin + Offset(math.cos(a) * d, math.sin(a) * d);
      canvas.drawCircle(
        p,
        2.5 * (1 - progress),
        Paint()
          ..color = (i.isEven
                  ? SudaneseTheme.sunGold
                  : SudaneseTheme.straw)
              .withValues(alpha: 1 - progress),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FragmentsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// موجة صدمة دائرية من حجر الهبوط.
class _Shockwave extends StatelessWidget {
  final Offset origin;
  final double progress;
  final double maxRadius;

  const _Shockwave({
    required this.origin,
    required this.progress,
    required this.maxRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShockwavePainter(
        origin: origin,
        progress: progress,
        maxRadius: maxRadius,
      ),
    );
  }
}

class _ShockwavePainter extends CustomPainter {
  final Offset origin;
  final double progress;
  final double maxRadius;

  _ShockwavePainter({
    required this.origin,
    required this.progress,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    canvas.drawCircle(
      origin,
      progress * maxRadius,
      Paint()
        ..color = SudaneseTheme.sunGold.withValues(alpha: (1 - progress) * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _ShockwavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
