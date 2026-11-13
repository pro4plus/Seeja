import 'package:alseeja/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('التطبيق يفتح على شاشة البداية ثم الرئيسية',
      (WidgetTester tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    await tester.pumpWidget(const SeegaGame());
    // شاشة البداية: عنوان "السيجا السودانية" بظل أحمر صلب.
    expect(find.text('السيجا السودانية'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    // بعد البداية تظهر أزرار اللعب (صور بتسميات نصية).
    expect(find.bySemanticsLabel('العب ضد الكمبيوتر'),
        findsOneWidget);
    expect(find.bySemanticsLabel('لاعبان على جهاز واحد'),
        findsOneWidget);
  });
}
