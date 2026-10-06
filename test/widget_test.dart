import 'package:flutter_test/flutter_test.dart';
import 'package:uangquapp/main.dart';

void main() {
  testWidgets('UangQuApp dapat berjalan', (WidgetTester tester) async {
    await tester.pumpWidget(const UangQuApp());

    expect(find.text('UangQu'), findsOneWidget);
  });
}