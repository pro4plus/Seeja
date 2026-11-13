import 'package:alseeja/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('التطبيق يفتح على شاشة البداية ثم الرئيسية',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SeegaGame());
    // شاشة البداية: عنوان "السيجا السودانية" بظل أحمر صلب.
    // v5: العنوان مرسوم بـ CartoonText في 3 طبقات (ظل + حد + تعبئة).
    expect(find.text('السيجا السودانية'), findsNWidgets(3));
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    // بعد البداية تظهر أزرار اللعب.
    expect(find.text('العب ضد الكمبيوتر'), findsOneWidget);
    expect(find.text('لاعبان على جهاز واحد'), findsOneWidget);
  });
}
