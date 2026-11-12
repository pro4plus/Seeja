// لقطات v5 الذهبية (اختبار ودجت عادي في test/ — يعمل على
// flutter_tester بدون جهاز، فلا يحتاج -d ولا بناء سطح مكتب).
// أربع لقطات على سطح 390×844: الرئيسية، الإعداد ضد الكمبيوتر،
// لعبة جديدة 5×5 ضد الكمبيوتر (وسط)، وشاشة النتيجة.
// ضخّات يدوية متكررة بدل pumpAndSettle: مؤقت لوحة العرض (6 ثوانٍ)
// والمؤقتات المتكررة تمنع الاستقرار.
// طبعات STEP لتحديد مكان التعليق بدقة في سجل CI.
import 'package:alseeja/game/seega_ai.dart';
import 'package:alseeja/game/turn_controller.dart';
import 'package:alseeja/main.dart';
import 'package:alseeja/screens/game_screen.dart';
import 'package:alseeja/screens/home_screen.dart';
import 'package:alseeja/screens/setup_screen.dart';
import 'package:alseeja/ui/sand_board.dart';
import 'package:alseeja/ui/widgets/game_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _gameVsComputer = GameConfig(
  boardSize: 5,
  vsComputer: true,
  difficulty: Difficulty.medium,
  p1Pebble: 0,
  p2Pebble: 1,
);

const _gameTwoPlayer = GameConfig(
  boardSize: 5,
  vsComputer: false,
  p1Pebble: 0,
  p2Pebble: 1,
);

Future<void> _setPhone(WidgetTester tester) async {
  // 390×844 بكسل منطقي @2x.
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

Future<void> _precache(
    WidgetTester tester, List<String> assets) async {
  final context = tester.element(find.byType(MaterialApp));
  for (final asset in assets) {
    await precacheImage(AssetImage(asset), context);
  }
}

Future<void> _pumpTimes(
    WidgetTester tester, int times, int milliseconds) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(Duration(milliseconds: milliseconds));
  }
}

/// مركز حفرة (r,c) في لوحة الرمل (كما في test/game_screen_test.dart).
Offset _centreOf(WidgetTester tester, int r, int c) {
  final boardRect = tester.getRect(find.byType(SandBoard));
  final cell = (boardRect.width - 16) / 5;
  return boardRect.topLeft +
      Offset(8 + (c + 0.5) * cell, 8 + (r + 0.5) * cell);
}

void main() {
  // تشخيص: هل تحميل صور PNG مسبقاً يعلّق؟ شاشة فارغة
  // + precache للصور الثلاث فقط، بلا لقطة.
  testWidgets('تشخيص: تحميل صور PNG مسبقاً',
      (WidgetTester tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    print('STEP diag-precache: pumped');
    await _precache(
        tester, [portraitYoung, portraitTeacher, portraitElder]);
    print('STEP diag-precache: precache done');
    expect(true, isTrue);
    print('STEP diag-precache: done');
  }, timeout: const Timeout(Duration(minutes: 1)));

  // تشخيص: هل التقاط لقطة ذهبية لصورة PNG وحدها يعلّق؟
  testWidgets('تشخيص: لقطة ذهبية لصورة PNG فقط',
      (WidgetTester tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: OpponentPortrait(
              kind: ElderKind.teacher,
              width: 92,
              height: 118,
            ),
          ),
        ),
      ),
    );
    print('STEP diag-portrait-golden: pumped');
    await tester.pump();
    await _precache(tester, [portraitTeacher]);
    print('STEP diag-portrait-golden: precache done');
    await _pumpTimes(tester, 2, 500);
    print('STEP diag-portrait-golden: pumps done');
    await expectLater(
      find.byType(OpponentPortrait),
      matchesGoldenFile('goldens/diag_portrait.png'),
    );
    print('STEP diag-portrait-golden: golden done');
  }, timeout: const Timeout(Duration(minutes: 1)));

  // تشخيص: ضابط — لقطة ذهبية لخلفية webp معروفة أنها تعمل.
  testWidgets('تشخيص: لقطة ذهبية لخلفية فقط',
      (WidgetTester tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Image.asset(bgWall, fit: BoxFit.cover),
        ),
      ),
    );
    print('STEP diag-bgwall-golden: pumped');
    await tester.pump();
    await _precache(tester, [bgWall]);
    print('STEP diag-bgwall-golden: precache done');
    await _pumpTimes(tester, 2, 500);
    print('STEP diag-bgwall-golden: pumps done');
    await expectLater(
      find.byType(Image),
      matchesGoldenFile('goldens/diag_bgwall.png'),
    );
    print('STEP diag-bgwall-golden: golden done');
  }, timeout: const Timeout(Duration(minutes: 1)));

  testWidgets('لقطة الرئيسية', (WidgetTester tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(const SeegaGame());
    print('STEP home: pumped');
    await tester.pump(const Duration(milliseconds: 500));
    await _precache(tester, [bgHome, portraitElder, reedMat]);
    print('STEP home: precache done');
    // شاشة البداية 2.2 ث ثم الانتقال إلى الرئيسية.
    await tester.pump(const Duration(milliseconds: 2600));
    await _pumpTimes(tester, 2, 500);
    print('STEP home: pumps done');
    expect(find.text('العب ضد الكمبيوتر'), findsOneWidget);
    print('STEP home: expect done');
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home.png'),
    );
    print('STEP home: golden done');
  }, timeout: const Timeout(Duration(minutes: 2)));

  testWidgets('لقطة الإعداد ضد الكمبيوتر',
      (WidgetTester tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(
      const MaterialApp(home: SetupScreen(vsComputer: true)),
    );
    print('STEP setup: pumped');
    await tester.pump();
    await _precache(
        tester, [bgWall, portraitYoung, portraitTeacher, portraitElder]);
    print('STEP setup: precache done');
    await _pumpTimes(tester, 2, 500);
    print('STEP setup: pumps done');
    expect(find.text('اجلس للعب'), findsOneWidget);
    print('STEP setup: expect done');
    await expectLater(
      find.byType(SetupScreen),
      matchesGoldenFile('goldens/setup.png'),
    );
    print('STEP setup: golden done');
  }, timeout: const Timeout(Duration(minutes: 2)));

  testWidgets('لقطة لعبة جديدة 5×5 ضد الكمبيوتر',
      (WidgetTester tester) async {
    await _setPhone(tester);
    final controller = TurnController(
      boardSize: 5,
      vsComputer: true,
      difficulty: Difficulty.medium,
      aiDelayMs: 0,
      placementDelayMs: 0,
      debugAiSeed: 1,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          config: _gameVsComputer,
          debugController: controller,
        ),
      ),
    );
    print('STEP game: pumped');
    await tester.pump();
    await _precache(tester, [bgWall, sandTexture, portraitTeacher]);
    print('STEP game: precache done');
    await _pumpTimes(tester, 2, 500);
    print('STEP game: pumps done');
    expect(find.textContaining('ضع 3 أحجار'), findsOneWidget);
    print('STEP game: expect done');
    await expectLater(
      find.byType(GameScreen),
      matchesGoldenFile('goldens/game.png'),
    );
    print('STEP game: golden done');
  }, timeout: const Timeout(Duration(minutes: 2)));

  testWidgets('لقطة شاشة النتيجة', (WidgetTester tester) async {
    await _setPhone(tester);
    final controller = TurnController(
      boardSize: 5,
      vsComputer: false,
    );
    addTearDown(controller.dispose);

    // اللاعب 1 في (1,1) و(1,4)، واللاعب 2 بحجر وحيد في (1,2).
    // حركة (1,4) ← (1,3) تحصر (1,2) بين (1,1) و(1,3) فتأكله
    // وتنهي اللعبة (كما في test/game_screen_test.dart).
    final engine = controller.engine;
    engine.board[1][1] = 1;
    engine.board[1][4] = 1;
    engine.board[1][2] = 2;
    engine.placingPhase = false;
    engine.currentPlayer = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          config: _gameTwoPlayer,
          debugController: controller,
        ),
      ),
    );
    print('STEP result: pumped');
    controller.debugSyncAfterExternalSetup();
    await tester.pump();
    await _precache(tester, [bgWall, sandTexture]);
    print('STEP result: precache done');
    await tester.tapAt(_centreOf(tester, 1, 4));
    await tester.pump();
    await tester.tapAt(_centreOf(tester, 1, 3));
    await tester.pump();
    // انزلاق (240ms) + أكل (320ms) + استقرار.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    print('STEP result: pumps done');
    expect(find.text('اللاعب 1 فاز!'), findsOneWidget);
    print('STEP result: expect done');
    await expectLater(
      find.byType(GameScreen),
      matchesGoldenFile('goldens/result.png'),
    );
    print('STEP result: golden done');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
