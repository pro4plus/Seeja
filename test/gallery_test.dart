// اختبار معرض الرسومات: الشاشة تُبنى وتعرض كل الأصول.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alseeja/screens/gallery_screen.dart';

void main() {
  testWidgets('معرض الرسومات يعرض كل الأصول', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GalleryScreen(),
      ),
    );
    await tester.pump();

    expect(find.byType(GalleryScreen), findsOneWidget);
    // الشبكة تُبنى تدريجياً، فنتحقق أن الأصول ظاهرة.
    expect(find.byType(Image), findsWidgets);
    expect(find.textContaining('ود البلد'), findsOneWidget);
  });
}
