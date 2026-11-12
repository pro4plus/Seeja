// ignore_for_file: avoid_print
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
import 'package:flutter/services.dart';
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

/// تحميل الخطوط يدوياً داخل runAsync (مرة واحدة لكل عملية اختبار):
/// مثل الصور، تحميل الخطوط من المحرك يتعطّل داخل اختبار الودجت،
/// فتظهر النصوص والأيقونات مربعات فارغة في اللقطات الذهبية.
var _fontsLoaded = false;

Future<void> _loadFonts(WidgetTester tester) async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  await tester.runAsync(() async {
    final reem = FontLoader('ReemKufi')
      ..addFont(rootBundle.load('assets/fonts/ReemKufi-700.ttf'));
    await reem.load();
    print('STEP fonts: ReemKufi loaded');
    final tajawal = FontLoader('Tajawal')
      ..addFont(rootBundle.load('assets/fonts/Tajawal-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Tajawal-Bold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Tajawal-ExtraBold.ttf'));
    await tajawal.load();
    print('STEP fonts: Tajawal loaded');
    try {
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle
            .load('packages/flutter/fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      print('STEP fonts: MaterialIcons loaded');
    } catch (e) {
      print('STEP fonts: MaterialIcons failed: $e');
    }
  });
}

Future<void> _precache(
    WidgetTester tester, List<String> assets) async {
  final context = tester.element(find.byType(MaterialApp));
  for (final asset in assets) {
    print('STEP precache: loading $asset');
    // تحميل حقيقي خارج FakeAsync: بدونه يعلّق فك ترميز الصورة
    // ولا يكتمل أبداً داخل اختبار الودجت.
    await tester.runAsync(() => precacheImage(AssetImage(asset), context));
    print('STEP precache: loaded $asset');
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
  // تشخيص أ: هل تحميل bgWall وحدها (أول استدعاء) يعلّق؟
  testWidgets('تشخيص أ: تحميل bgWall وحدها',
      (WidgetTester tester) async {
    await _loadFonts(tester);
    await _setPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    print('STEP diag-a: pumped');
    await tester.pump();
    print('STEP diag-a: pump done');
    await _precache(tester, [bgWall]);
    print('STEP diag-a: precache done');
    expect(true, isTrue);
    print('STEP diag-a: done');
  }, timeout: const Timeout(Duration(minutes: 1)));

  // تشخيص ب: هل تحميل صورة شخصية PNG وحدها يعلّق؟
  testWidgets('تشخيص ب: تحميل صورة شخصية وحدها',
      (WidgetTester tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    print('STEP diag-b: pumped');
    await tester.pump();
    print('STEP diag-b: pump done');
    await _precache(tester, [portraitTeacher]);
    print('STEP diag-b: precache done');
    expect(true, isTrue);
    print('STEP diag-b: done');
  }, timeout: const Timeout(Duration(minutes: 1)));

  testWidgets('لقطة الرئيسية', (WidgetTester tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(const SeegaGame());
    print('STEP home: pumped');
    await tester.pump(const Duration(milliseconds: 500));
    print('STEP home: pump done');
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
    print('STEP setup: pump done');
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
    print('STEP game: pump done');
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
    print('STEP result: pump done');
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
