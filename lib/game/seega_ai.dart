import 'dart:math';
import 'seega_engine.dart';

enum AIDifficulty { easy, medium, hard }

class SeegaAI {
  static final Random _rng = Random();

  static Point<int> choosePlacement(SeegaEngine engine, Player aiPlayer) {
    int center = engine.size ~/ 2;
    Player opp = aiPlayer == Player.p1 ? Player.p2 : Player.p1;
    Point<int>? bestPt;
    double bestScore = -1e9;

    for (int r = 0; r < engine.size; r++) {
      for (int c = 0; c < engine.size; c++) {
        if (engine.isCenter(r, c) || engine.board[r][c] != null) continue;
        double score = (engine.size - ((r - center).abs() + (c - center).abs())) * 3.0;
        const dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
        for (var d in dirs) {
          int nr = r + d[0], nc = c + d[1];
          if (engine.isValid(nr, nc)) {
            if (engine.board[nr][nc] == opp) score += 4.0;
            if (engine.board[nr][nc] == aiPlayer) score += 2.0;
          }
        }
        score += _rng.nextDouble() * 2.5;
        if (score > bestScore) {
          bestScore = score;
          bestPt = Point(r, c);
        }
      }
    }
    return bestPt ?? const Point(0, 0);
  }

  static MoveStep? chooseMove(SeegaEngine engine, Player aiPlayer, AIDifficulty difficulty) {
    final moves = engine.getLegalMoves(aiPlayer);
    if (moves.isEmpty) return null;

    if (difficulty == AIDifficulty.easy) {
      if (_rng.nextDouble() < 0.3) {
        for (var m in moves) {
          final sim = engine.clone();
          final res = sim.moveStone(m.fromR, m.fromC, m.toR, m.toC, recordHistory: false);
          if (res != null && res.captured.isNotEmpty) return m;
        }
      }
      return moves[_rng.nextInt(moves.length)];
    }

    if (difficulty == AIDifficulty.medium) {
      int center = engine.size ~/ 2;
      MoveStep best = moves.first;
      double bestScore = -1e9;
      for (var m in moves) {
        final sim = engine.clone();
        final res = sim.moveStone(m.fromR, m.fromC, m.toR, m.toC, recordHistory: false);
        double score = (res?.captured.length ?? 0) * 100.0 + ((m.toR == center && m.toC == center) ? 15.0 : 0.0) + _rng.nextDouble() * 3.0;
        if (score > bestScore) {
          bestScore = score;
          best = m;
        }
      }
      return best;
    }

    int depth = engine.size == 5 ? 4 : 3;
    MoveStep bestMove = moves.first;
    double bestVal = -1e9;
    for (var m in moves) {
      final sim = engine.clone();
      sim.moveStone(m.fromR, m.fromC, m.toR, m.toC, recordHistory: false);
      double val = _minimax(sim, depth - 1, -1e9, 1e9, false, aiPlayer);
      if (val > bestVal) {
        bestVal = val;
        bestMove = m;
      }
    }
    return bestMove;
  }

  static double _minimax(SeegaEngine state, int depth, double alpha, double beta, bool maximizing, Player aiPlayer) {
    if (depth == 0 || state.phase == GamePhase.gameOver) return _evaluate(state, aiPlayer);
    final moves = state.getLegalMoves(state.currentTurn);
    if (moves.isEmpty) return _evaluate(state, aiPlayer);

    if (maximizing) {
      double maxEval = -1e9;
      for (var m in moves) {
        final sim = state.clone();
        sim.moveStone(m.fromR, m.fromC, m.toR, m.toC, recordHistory: false);
        double ev = _minimax(sim, depth - 1, alpha, beta, sim.currentTurn == aiPlayer, aiPlayer);
        maxEval = max(maxEval, ev);
        alpha = max(alpha, ev);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      double minEval = 1e9;
      for (var m in moves) {
        final sim = state.clone();
        sim.moveStone(m.fromR, m.fromC, m.toR, m.toC, recordHistory: false);
        double ev = _minimax(sim, depth - 1, alpha, beta, sim.currentTurn == aiPlayer, aiPlayer);
        minEval = min(minEval, ev);
        beta = min(beta, ev);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  static double _evaluate(SeegaEngine state, Player aiPlayer) {
    if (state.phase == GamePhase.gameOver) {
      if (state.outcome == GameOutcome.draw) return 0;
      bool aiWon = (aiPlayer == Player.p1 && state.outcome == GameOutcome.p1Win) || (aiPlayer == Player.p2 && state.outcome == GameOutcome.p2Win);
      return aiWon ? 10000.0 : -10000.0;
    }
    int myStones = aiPlayer == Player.p1 ? state.p1OnBoard : state.p2OnBoard;
    int oppStones = aiPlayer == Player.p1 ? state.p2OnBoard : state.p1OnBoard;
    int center = state.size ~/ 2;
    return (myStones - oppStones) * 100.0 + (state.board[center][center] == aiPlayer ? 12.0 : 0.0) + _rng.nextDouble() * 2.0;
  }
}
