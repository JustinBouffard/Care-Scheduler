import 'package:flutter_test/flutter_test.dart';

import 'package:care_scheduler/main.dart';

void main() {
  testWidgets('app displays the patient schedule', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Patient X'), findsOneWidget);
    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('Medication'), findsWidgets);
  });
}
