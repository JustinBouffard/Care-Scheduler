import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:care_scheduler/main.dart';

void main() {
  testWidgets('doctor can search patients and open a patient calendar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Patients'), findsOneWidget);
    expect(find.text('Margaret Wilson'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'robert');
    await tester.pumpAndSettle();
    expect(find.text('Robert Chen'), findsOneWidget);
    expect(find.text('Margaret Wilson'), findsNothing);

    await tester.enterText(find.byType(TextField), 'margaret');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Margaret Wilson'));
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Margaret Wilson'), findsOneWidget);
    expect(find.text('Add activity'), findsOneWidget);
  });

  testWidgets('doctor can add an activity to the selected patient calendar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Margaret Wilson'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add activity'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Blood pressure check');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Blood pressure check'), findsOneWidget);
  });
}
