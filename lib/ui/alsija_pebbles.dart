// ربط ألوان الحجارة ومستويات الصعوبة بين مشروع السيجا
// (SudaneseTheme.pebbles السبعة + Difficulty) وحزمة الشاشات
// الجديدة (AlsijaColor + AlsijaOpponent).
//
// الترتيب في المشروع: نيلي، طيني، أخضر، أحمر، فيروزي، كهرماني، فحمي.
// أقرب مقابل في الحزمة لكل لون: نيلي ← أزرق، طيني ← نحاسي،
// أخضر ← أخضر، أحمر ← أحمر، فيروزي ← فيروزي، كهرماني ← ذهبي،
// فحمي ← رمادي.
import '../game/seega_ai.dart';
import 'alsija_screens.dart';

/// لون الحزمة المقابل لحجر المشروع (فهرس SudaneseTheme.pebbles).
AlsijaColor alsijaColorForPebble(int index) {
  switch (index) {
    case 0:
      return AlsijaColor.blue; // نيلي
    case 1:
      return AlsijaColor.copper; // طيني
    case 2:
      return AlsijaColor.green; // أخضر
    case 3:
      return AlsijaColor.red; // أحمر
    case 4:
      return AlsijaColor.turquoise; // فيروزي
    case 5:
      return AlsijaColor.gold; // كهرماني
    case 6:
      return AlsijaColor.charcoal; // فحمي
    default:
      return AlsijaColor.charcoal;
  }
}

/// فهرس حجر المشروع المقابل للون الحزمة.
int pebbleForAlsijaColor(AlsijaColor color) {
  switch (color) {
    case AlsijaColor.blue:
      return 0;
    case AlsijaColor.copper:
      return 1;
    case AlsijaColor.green:
      return 2;
    case AlsijaColor.red:
      return 3;
    case AlsijaColor.turquoise:
      return 4;
    case AlsijaColor.gold:
      return 5;
    case AlsijaColor.charcoal:
      return 6;
  }
}

/// مستوى الكمبيوتر في المشروع مقابل خصم الحزمة.
Difficulty difficultyForOpponent(AlsijaOpponent opponent) {
  switch (opponent) {
    case AlsijaOpponent.easy:
      return Difficulty.easy;
    case AlsijaOpponent.medium:
      return Difficulty.medium;
    case AlsijaOpponent.hard:
      return Difficulty.hard;
  }
}

/// خصم الحزمة مقابل مستوى الكمبيوتر في المشروع.
AlsijaOpponent opponentForDifficulty(Difficulty difficulty) {
  switch (difficulty) {
    case Difficulty.easy:
      return AlsijaOpponent.easy;
    case Difficulty.medium:
      return AlsijaOpponent.medium;
    case Difficulty.hard:
      return AlsijaOpponent.hard;
  }
}
