// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:scan_penyakit_daun_jagung/main.dart';

void main() {
  testWidgets('Daun jagung home page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const RempahinApp());

    expect(find.text('Scan Daun Jagung'), findsOneWidget);
    expect(find.text('Hasil Deteksi Daun Jagung'), findsOneWidget);
  });
}
