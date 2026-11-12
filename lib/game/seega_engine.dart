import 'dart:math';

enum GamePhase { placement, movement, gameOver }
enum Player { p1, p2 }
enum GameOutcome { p1Win, p2Win, draw }

class MoveStep {
  final int fromR, fromC, toR, toC;
  final List<Point<int>> captured;
  MoveStep(this.fromR, this.fromC, this.toR, this.toC, this.captured);
}

class SeegaEngine {
  final int size;
  late final int totalStonesPerPlayer;
  late List<List<Player?>> board;

  Player currentTurn = Player.p1;
  GamePhase phase = GamePhase.placement;
  GameOutcome? outcome;

  int placedThisTurn = 0;
  int p1Placed = 0;
  int p2Placed = 0;
  int p1OnBoard = 0;
  int p2OnBoard = 0;
  int p1Captured = 0;
  int p2Captured = 0;
  int movesWithoutCapture = 0;

  final List<String> _history = [];

  SeegaEngine({this.size = 5}) {
    totalStonesPerPlayer = size == 5 ? 12 : 24;
    board = List.generate(size, (_) => List.filled(size, null));
  }

  SeegaEngine clone() {
    final copy = SeegaEngine(size: size);
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        copy.board[r][c] = board[r][c];
      }
    }
    copy.currentTurn = currentTurn;
    copy.phase = phase;
    copy.outcome = outcome;
    copy.placedThisTurn = placedThisTurn;
    copy.p1Placed = p1Placed;
    copy.p2Placed = p2Placed;
    copy.p1OnBoard = p1OnBoard;
    copy.p2OnBoard = p2OnBoard;
    copy.p1Captured = p1Captured;
    copy.p2Captured = p2Captured;
    copy.movesWithoutCapture = movesWithoutCapture;
    return copy;
  }

  void saveSnapshot() {
    String b = board.map((row) => row.map((p) => p == null ? '.' : (p == Player.p1 ? '1' : '2')).join()).join('/');
    _history.add('$b|${currentTurn.index}|${phase.index}|$placedThisTurn|$p1Placed|$p2Placed|$p1OnBoard|$p2OnBoard|$p1Captured|$p2Captured');
  }

  bool canUndo() => _history.isNotEmpty && phase != GamePhase.gameOver;

  bool undo() {
    if (!canUndo()) return false;
    final snap = _history.removeLast().split('|');
    final rows = snap[0].split('/');
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final ch = rows[r][c];
        board[r][c] = ch == '.' ? null : (ch == '1' ? Player.p1 : Player.p2);
      }
    }
    currentTurn = Player.values[int.parse(snap[1])];
    phase = GamePhase.values[int.parse(snap[2])];
    placedThisTurn = int.parse(snap[3]);
    p1Placed = int.parse(snap[4]);
    p2Placed = int.parse(snap[5]);
    p1OnBoard = int.parse(snap[6]);
    p2OnBoard = int.parse(snap[7]);
    p1Captured = int.parse(snap[8]);
    p2Captured = int.parse(snap[9]);
    outcome = null;
    return true;
  }

  bool isCenter(int r, int c) => r == size ~/ 2 && c == size ~/ 2;
  bool isValid(int r, int c) => r >= 0 && r < size && c >= 0 && c < size;

  bool placeStone(int r, int c) {
    if (phase != GamePhase.placement) return false;
    if (!isValid(r, c) || isCenter(r, c) || board[r][c] != null) return false;

    if (placedThisTurn == 0) saveSnapshot();

    board[r][c] = currentTurn;
    if (currentTurn == Player.p1) {
      p1Placed++;
      p1OnBoard++;
    } else {
      p2Placed++;
      p2OnBoard++;
    }
    placedThisTurn++;

    int maxForCurrent = currentTurn == Player.p1 ? totalStonesPerPlayer - p1Placed : totalStonesPerPlayer - p2Placed;

    if (p1Placed >= totalStonesPerPlayer && p2Placed >= totalStonesPerPlayer) {
      phase = GamePhase.movement;
      placedThisTurn = 0;
      if (getLegalMoves(Player.p1).isNotEmpty) {
        currentTurn = Player.p1;
      } else if (getLegalMoves(Player.p2).isNotEmpty) {
        currentTurn = Player.p2;
      } else {
        _resolveStuckGame();
      }
    } else if (placedThisTurn >= 3 || maxForCurrent == 0) {
      placedThisTurn = 0;
      currentTurn = currentTurn == Player.p1 ? Player.p2 : Player.p1;
    }
    return true;
  }

  List<Point<int>> getLegalTargets(int r, int c) {
    if (phase != GamePhase.movement || board[r][c] != currentTurn) return [];
    const dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    List<Point<int>> targets = [];
    for (var d in dirs) {
      int nr = r + d[0];
      int nc = c + d[1];
      if (isValid(nr, nc) && board[nr][nc] == null) targets.add(Point(nr, nc));
    }
    return targets;
  }

  List<MoveStep> getLegalMoves(Player player) {
    List<MoveStep> moves = [];
    const dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] == player) {
          for (var d in dirs) {
            int nr = r + d[0];
            int nc = c + d[1];
            if (isValid(nr, nc) && board[nr][nc] == null) moves.add(MoveStep(r, c, nr, nc, []));
          }
        }
      }
    }
    return moves;
  }

  MoveStep? moveStone(int fromR, int fromC, int toR, int toC, {bool recordHistory = true}) {
    if (phase != GamePhase.movement) return null;
    if (!isValid(fromR, fromC) || !isValid(toR, toC)) return null;
    if (board[fromR][fromC] != currentTurn || board[toR][toC] != null) return null;

    int dr = (fromR - toR).abs();
    int dc = (fromC - toC).abs();
    if (!((dr == 1 && dc == 0) || (dr == 0 && dc == 1))) return null;

    if (recordHistory) saveSnapshot();

    board[toR][toC] = currentTurn;
    board[fromR][fromC] = null;

    final captured = _applyCaptures(toR, toC);
    movesWithoutCapture = captured.isEmpty ? movesWithoutCapture + 1 : 0;

    if (p2OnBoard == 0) {
      phase = GamePhase.gameOver;
      outcome = GameOutcome.p1Win;
      return MoveStep(fromR, fromC, toR, toC, captured);
    }
    if (p1OnBoard == 0) {
      phase = GamePhase.gameOver;
      outcome = GameOutcome.p2Win;
      return MoveStep(fromR, fromC, toR, toC, captured);
    }
    if (movesWithoutCapture >= 60) {
      phase = GamePhase.gameOver;
      outcome = GameOutcome.draw;
      return MoveStep(fromR, fromC, toR, toC, captured);
    }

    Player nextPlayer = currentTurn == Player.p1 ? Player.p2 : Player.p1;
    if (getLegalMoves(nextPlayer).isNotEmpty) {
      currentTurn = nextPlayer;
    } else if (getLegalMoves(currentTurn).isEmpty) {
      _resolveStuckGame();
    }
    return MoveStep(fromR, fromC, toR, toC, captured);
  }

  List<Point<int>> _applyCaptures(int r, int c) {
    Player opponent = currentTurn == Player.p1 ? Player.p2 : Player.p1;
    const dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    List<Point<int>> eaten = [];
    for (var d in dirs) {
      int r1 = r + d[0], c1 = c + d[1], r2 = r + d[0] * 2, c2 = c + d[1] * 2;
      if (isValid(r1, c1) && isValid(r2, c2)) {
        if (board[r1][c1] == opponent && board[r2][c2] == currentTurn) {
          board[r1][c1] = null;
          eaten.add(Point(r1, c1));
          if (currentTurn == Player.p1) {
            p1Captured++;
            p2OnBoard--;
          } else {
            p2Captured++;
            p1OnBoard--;
          }
        }
      }
    }
    return eaten;
  }

  void _resolveStuckGame() {
    phase = GamePhase.gameOver;
    outcome = p1OnBoard > p2OnBoard ? GameOutcome.p1Win : (p2OnBoard > p1OnBoard ? GameOutcome.p2Win : GameOutcome.draw);
  }
}
