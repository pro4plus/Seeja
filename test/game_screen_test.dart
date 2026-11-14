// اختبارات شاشة اللعب (شاشات الحزمة الجديدة + لوحة الرمل الأصلية):
//  * عطل التجمد عبر الواجهة: بعد انتهاء التوزيع والدور للكمبيوتر،
//    يجب أن يتحرك الكمبيوتر وتظهر لافتة "دورك" (لا تجمد).
//  * قانون التمرير عبر الواجهة: لاعب بلا حركة يُمرَّر دوره.
//  * شاشة النتيجة: أكل آخر حجر للخصم يعرض الفوز و"العب تاني".
//  * الاختيار يظهر فوراً: حلقة ذهبية حول الحجر المحدد وحلقات
//    وجهات خضراء، ثم النقر على وجهة قانونية ينفذ الحركة.
//  * عدادات «أكلت» و«باقي» تعكس الأكل بعد الحركة.
// النقر على الخانات بموضعها في اللوحة (centreOf) كما في الأصل،
// لأن تسميات SandBoard تتضمن حالة الخانة (فاضية/حجرك/حجر الخصم).

import 'package:alseeja/game/seega_ai.dart';
import 'package:alseeja/game/turn_controller.dart';
import 'package:alseeja/screens/game_screen.dart';
import 'package:alseeja/theme/sudanese_theme.dart';
import 'package:alseeja/ui/sand_board.dart';
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

/// مركز حفرة (r,c) في لوحة الرمل: اللوحة مربعة (alsijaBoardSize
/// بوحدات التصميم) داخل FittedBox، بحشوة 8px في إحداثيات
/// اللوحة نفسها — فيُحسب مركز الحفرة من مستطيل SandBoard
/// الفعلي مباشرة، بلا أي حجم مثبّت.
Offset centreOf(WidgetTester tester, int r, int c) {
  final boardRect = tester.getRect(find.byType(SandBoard));
  final cell = (boardRect.width - 16) / 5;
  return boardRect.topLeft +
      Offset(8 + (c + 0.5) * cell, 8 + (r + 0.5) * cell);
}

/// هل ترسم اللوحة حلقة ذهبية حول حجر محدد؟
bool _hasGoldRing() {
  return find
      .descendant(
        of: find.byType(SandBoard),
        matching: find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).border is Border &&
            ((w.decoration as BoxDecoration).border as Border)
                    .top
                    .color ==
                SudaneseTheme.sunGold),
      )
      .evaluate()
      .isNotEmpty;
}

/// هل ترسم اللوحة حلقات وجهات قانونية؟
bool _hasDestRings() {
  return find
      .descendant(
        of: find.byType(SandBoard),
        matching: find.byWidgetPredicate((w) =>
            w is CustomPaint &&
            w.painter != null &&
            w.painter.runtimeType.toString().contains('DestRing')),
      )
      .evaluate()
      .isNotEmpty;
}

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
    expect(find.text('الدور: اللاعب 1'), findsOneWidget);

    await tester.tapAt(centreOf(tester, 2, 2));
    await tester.pump();
    await tester.tapAt(centreOf(tester, 2, 3));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // الدور رجع للاعب 1 لأن اللاعب 2 بلا حركة.
    expect(engine.currentPlayer, 1);
    expect(controller.phase, TurnPhase.awaitingHuman);
    expect(controller.lastEvent, ControllerEvent.pass);
    expect(controller.passPlayer, 2);
    expect(find.text('الدور: اللاعب 1'), findsOneWidget);
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
    expect(find.text('الدور: اللاعب 1'), findsOneWidget);

    await tester.tapAt(centreOf(tester, 1, 4));
    await tester.pump();
    await tester.tapAt(centreOf(tester, 1, 3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('مبروووك!'), findsOneWidget);
    expect(find.bySemanticsLabel('العب تاني'), findsOneWidget);
    expect(find.bySemanticsLabel('العودة للرئيسية'), findsOneWidget);
  });

  testWidgets('الاختيار يظهر فوراً: حلقة ذهبية وحلقات وجهات',
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
    expect(_hasGoldRing(), isFalse);
    expect(_hasDestRings(), isFalse);

    // النقر على الحجر نفسه (وسط صورته) يختاره ويظهر الحلقة.
    await tester.tapAt(centreOf(tester, 1, 4));
    await tester.pump();
    expect(controller.selectedTile, [1, 4]);
    expect(_hasGoldRing(), isTrue,
        reason: 'النقر على الحجر لم يرسم الحلقة الذهبية حوله');
    expect(_hasDestRings(), isTrue,
        reason: 'لم تظهر حلقات الوجهات القانونية بعد الاختيار');

    // النقر على الحجر المحدد نفسه يلغي الاختيار ويخفي الحلقة.
    await tester.tapAt(centreOf(tester, 1, 4));
    await tester.pump();
    expect(controller.selectedTile, isNull);
    expect(_hasGoldRing(), isFalse);
    expect(_hasDestRings(), isFalse);

    // إعادة الاختيار ثم النقر على وجهة قانونية ينفذ الحركة.
    await tester.tapAt(centreOf(tester, 1, 4));
    await tester.pump();
    await tester.tapAt(centreOf(tester, 1, 3));
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

    await tester.tapAt(centreOf(tester, 1, 4));
    await tester.pump();
    await tester.tapAt(centreOf(tester, 1, 3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(controller.engine.count(2), 1);
    expect(find.text('الدور: اللاعب 2'), findsOneWidget);

    // اللوحة المزروعة ناقصة: للاعب 2 حجران فقط، فبعد الأكل
    // يبقى له حجر واحد فيعرض العداد «أكلت 11»، وللاعب 1
    // حجران على اللوحة فيعرض «أكلت 10».
    expect(find.text('أكلت 11'), findsOneWidget);
    expect(find.text('أكلت 10'), findsOneWidget);
    expect(find.text('باقي 2'), findsOneWidget);
    expect(find.text('باقي 1'), findsOneWidget);
  });

  testWidgets('لاعبان: مقعد اللاعب 2 أعلى ولا زر تراجع',
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

    // المقعد العلوي للاعب 2 (وليس شخصية الكمبيوتر).
    expect(find.text('اللاعب 2'), findsOneWidget);
    // زر التراجع مخفي في اللعب بين لاعبين (ضد الكمبيوتر فقط).
    expect(find.bySemanticsLabel('تراجع'), findsNothing);
    // سطر الدور يسمّي اللاعب الحالي.
    expect(find.text('الدور: اللاعب 1'), findsOneWidget);
  });

  testWidgets('الحركة تنزلق قبل الاستقرار: finishAnimation بعد الانزلاق',
      (WidgetTester tester) async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: false,
    );
    addTearDown(controller.dispose);

    // نفس إعداد عدادات الأكل: الحركة تأكل (1,2) دون إنهاء اللعبة.
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

    await tester.tapAt(centreOf(tester, 1, 4));
    await tester.pump();
    await tester.tapAt(centreOf(tester, 1, 3));
    await tester.pump();
    // الحركة طُبّقت على المحرك، لكن الدور لم يستقر بعد:
    // الانزلاق (240ms) ثم الأكل (320ms) ما زالا يعملان.
    expect(controller.phase, TurnPhase.animating);
    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.phase, TurnPhase.animating);
    // الانزلاق 240ms ثم الأكل 320ms = 560ms، لكن الأكل لا يبدأ إلا
    // بعد إطار اكتمال الانزلاق، فيلزم ضخ 700ms إجمالاً.
    await tester.pump(const Duration(milliseconds: 400));
    expect(controller.phase, TurnPhase.awaitingHuman);
    expect(engine.currentPlayer, 2);
    expect(find.text('الدور: اللاعب 2'), findsOneWidget);
  });
}
