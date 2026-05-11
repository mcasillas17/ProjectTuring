// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:turing_flutter_app/app.dart';

void main() {
  testWidgets('Turing app renders chat shell', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TuringApp());

    // Verify that the current app shell renders instead of the old counter app.
    expect(find.text('Project Turing'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
