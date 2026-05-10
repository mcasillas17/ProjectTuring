import 'package:flutter_test/flutter_test.dart';

import 'package:turing_flutter_app/app.dart';
import 'package:turing_flutter_app/networking/auth_storage.dart';

void main() {
  testWidgets('Turing app renders settings when credentials are missing', (
    tester,
  ) async {
    await tester.pumpWidget(TuringApp(authStorage: _FakeAuthStorage()));
    await tester.pumpAndSettle();

    expect(find.text('Project Turing Settings'), findsOneWidget);
  });
}

class _FakeAuthStorage implements ClientAuthStorage {
  @override
  Future<String?> readApiKey() async => null;

  @override
  Future<String?> readBackendUrl() async => null;

  @override
  Future<void> save({
    required String backendUrl,
    required String apiKey,
  }) async {}
}
