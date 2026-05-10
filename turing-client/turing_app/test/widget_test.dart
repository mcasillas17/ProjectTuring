import 'package:flutter_test/flutter_test.dart';

import 'package:turing_flutter_app/app.dart';

void main() {
  testWidgets('Turing app renders the current app shell', (tester) async {
    await tester.pumpWidget(const TuringApp());

    expect(find.text('Project Turing'), findsOneWidget);
  });
}
