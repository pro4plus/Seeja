// اختبارات شاشة اللعب (شاشات الحزمة الجديدة):
//  * عطل التجمد عبر الواجهة: بعد انتهاء التوزيع والدور للكمبيوتر،
//    يجب أن يتحرك الكمبيوتر وتظهر لافتة "دورك" (لا تجمد).
//  * قانون التمرير عبر الواجهة: لاعب بلا حركة يُمرَّر دوره.
//  * شاشة النتيجة: أكل آخر حجر للخصم يعرض الفوز و"العب تاني".
//  * الاختيار يظهر فوراً: الحجر المحدد (علامة semantics) ثم
//    النقر على وجهة قانونية ينفذ الحركة.
//  * عدادات «أكلت» و«باقي» تعكس الأكل بعد الحركة.
// النقر على الخانات عبر تسمياتها: «الصف R، العمود C»
// (تسمية _press في شاشة الحزمة).

import 'package:alseeja/game/seega_ai.dart';
import 'package:alseeja/game/turn_controller.dart';
import 'package:alseeja/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'turn_controller_test.dart' show deadlockPlacements;

const _configVsComputer = GameConfig(
  boardSize: 5,
  vsComputer: true,
  difficulty: Difficulty.easy,
  p1Pebble: 0,
  p2Pebble: 1,
);

const _configTwoPlayer = GameConfig(
  boardSize: 5,
  vsComputer: false,
  p1Pebble: 0,
  p2Pebble: 1,
);

/// النقر على خانة (r,c) عبر تسميتها في شاشة الحزمة.
Future<void> tapCell(WidgetTester tester, int r, int c) =>
    tester.tap(
      find.bySemanticsLabel('الصف ${r + 1}، العمود ${c + 1}'),
    );

void main() {
  testWidgets('التجمد عبر الواجهة: الكمبيوتر يتحرك بعد التوزيع',
      (WidgetTester tester) async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: true,
      difficulty: Difficulty.easy,
      aiDelayMs: 0,
      placementDelayMs: 0,
      debugAiSeed: 1,
    );
    addTearDown(controller.dispose);

    for (final p in deadlockPlacements) {
      controller.engine.placeStone(p[0], p[1]);
    }
    expect(controller.engine.placingPhase, isFalse);
    expect(controller.engine.currentPlayer, 2);

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          config: _configVsComputer,
          debugController: controller,
        ),
      ),
    );
    controller.debugSyncAfterExternalSetup();
    await tester.pump();

    // دع الذكاء يتحرك عدة دورات حتى يعود الدور للاعب البشري.
    var yourTurnShown = false;
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 400));
      if (find.textContaining('دورك').evaluate().isNotEmpty) {
        yourTurnShown = true;
        break;
      }
    }
    expect(controller.engine.lastMove, isNotNull,
        reason: 'الكمبيوتر لم يحرّك إطلاقاً — اللعبة تجمدت');
    expect(yourTurnShown, isTrue,
        reason: 'لافتة "دورك" لم تظهر — الدور لم يعد للاعب البشري');
  });

  testWidgets('قانون التمرير عبر الواجهة: لاعب بلا حركة يُمرَّر دوره',
      (WidgetTester tester) async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: false,
    );
    addTearDown(controller.dispose);

    // اللاعب 2 في (0,0) محصور بين حجري اللاعب 1 في (0,1) و(1,0).
    // اللاعب 1 لديه حجر في (2,2) يستطيع التحرك إلى (2,3).
    final engine = controller.engine;
    engine.board[0][0] = 2;
    engine.board[0][1] = 1;
    engine.board[1][0] = 1;
    engine.board[2][2] = 1;
    engine.placingPhase = false;
    engine.currentPlayer = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          config: _configTwoPlayer,
          debugController: controller,
        ),
      ),
    );
    controller.debugSyncAfterExternalSetup();
    await tester.pump();
    expect(find.text('دورك: اختر حجراً ثم وجهته'), findsOneWidget);

    await tapCell(tester, 2, 2);
    await tester.pump();
    await tapCell(tester, 2, 3);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // الدور رجع للاعب 1 لأن اللاعب 2 بلا حركة.
    expect(engine.currentPlayer, 1);
    expect(controller.phase, TurnPhase.awaitingHuman);
    expect(controller.lastEvent, ControllerEvent.pass);
    expect(controller.passPlayer, 2);
    expect(find.text('دورك: اختر حجراً ثم وجهته'), findsOneWidget);
  });

  testWidgets('شاشة النتيجة: أكل آخر حجر يعرض الفوز',
      (WidgetTester tester) async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: false,
    );
    addTearDown(controller.dispose);

    // اللاعب 1 في (1,1) و(1,4)، واللاعب 2 بحجر وحيد في (1,2).
    // حركة (1,4) ← (1,3) تحصر (1,2) بين (1,1) و(1,3) فتأكله.
    final engine = controller.engine;
    engine.board[1][1] = 1;
    engine.board[1][4] = 1;
    engine.board[1][2] = 2;
    engine.placingPhase = false;
    engine.currentPlayer = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          config: _configTwoPlayer,
          debugController: controller,
        ),
      ),
    );
    controller.debugSyncAfterExternalSetup();
    await tester.pump();
    expect(find.text('دورك: اختر حجراً ثم وجهته'), findsOneWidget);

    await tapCell(tester, 1, 4);
    await tester.pump();
    await tapCell(tester, 1, 3);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('مبروووك!'), findsOneWidget);
    expect(find.bySemanticsLabel('العب تاني'), findsOneWidget);
    expect(find.bySemanticsLabel('العودة للرئيسية'), findsOneWidget);
  });

  testWidgets('الاختيار يظهر فوراً: الحجر المحدد ثم الحركة',
      (WidgetTester tester) async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: false,
    );
    addTearDown(controller.dispose);

    final engine = controller.engine;
    engine.board[1][1] = 1;
    engine.board[1][4] = 1;
    engine.board[1][2] = 2;
    engine.placingPhase = false;
    engine.currentPlayer = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          config: _configTwoPlayer,
          debugController: controller,
        ),
      ),
    );
    controller.debugSyncAfterExternalSetup();
    await tester.pump();

    expect(controller.selectedTile, isNull);

    // النقر على الحجر يختاره (علامة isSelected في semantics —
    // وهي نفس الحالة التي ترسم الحلقة الذهبية حوله).
    await tapCell(tester, 1, 4);
    await tester.pump();
    expect(controller.selectedTile, [1, 4]);
    final node = tester.getSemantics(
      find.bySemanticsLabel('الصف 2، العمود 5'),
    );
    expect(node.getSemanticsData().flagsCollection.isSelected, isTrue,
        reason: 'النقر على الحجر لم يحدده');

    // النقر على الحجر المحدد نفسه يلغي الاختيار.
    await tapCell(tester, 1, 4);
    await tester.pump();
    expect(controller.selectedTile, isNull);

    // إعادة الاختيار ثم النقر على وجهة قانونية ينفذ الحركة.
    await tapCell(tester, 1, 4);
    await tester.pump();
    await tapCell(tester, 1, 3);
    await tester.pump();
    expect(controller.selectedTile, isNull);
    expect(engine.board[1][4], 0);
    expect(engine.board[1][3], 1);
  });

  testWidgets('عدادات «أكلت» و«باقي» تعكس الأكل بعد الحركة',
      (WidgetTester tester) async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: false,
    );
    addTearDown(controller.dispose);

    // اللاعب 1 في (1,1) و(1,4)، واللاعب 2 في (1,2) و(4,4).
    // حركة (1,4) ← (1,3) تأكل (1,2) دون أن تنهي اللعبة
    // (يبقى للاعب 2 حجر في (4,4)).
    final engine = controller.engine;
    engine.board[1][1] = 1;
    engine.board[1][4] = 1;
    engine.board[1][2] = 2;
    engine.board[4][4] = 2;
    engine.placingPhase = false;
    engine.currentPlayer = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          config: _configTwoPlayer,
          debugController: controller,
        ),
      ),
    );
    controller.debugSyncAfterExternalSetup();
    await tester.pump();

    await tapCell(tester, 1, 4);
    await tester.pump();
    await tapCell(tester, 1, 3);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(controller.engine.count(2), 1);
    expect(find.text('دور الخصم'), findsOneWidget);

    // اللوحة المزروعة ناقصة: للاعب 2 حجران فقط، فبعد الأكل
    // يبقى له حجر واحد فيعرض العداد «أكلت 11»، وللاعب 1
    // حجران على اللوحة فيعرض «أكلت 10».
    expect(find.text('أكلت 11'), findsOneWidget);
    expect(find.text('أكلت 10'), findsOneWidget);
    expect(find.text('باقي 2'), findsOneWidget);
    expect(find.text('باقي 1'), findsOneWidget);
  });
}
