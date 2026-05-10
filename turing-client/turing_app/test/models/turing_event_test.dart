import 'package:flutter_test/flutter_test.dart';
import 'package:turing_flutter_app/models/turing_event.dart';

void main() {
  test('parses event envelope', () {
    final event = TuringEvent.fromJson({
      'eventId': 'evt_1',
      'sessionId': 'sess_1',
      'runId': 'run_1',
      'traceId': 'trace_1',
      'sequence': 1,
      'type': 'message.delta',
      'createdAt': '2026-05-10T00:00:00.000Z',
      'payload': {'delta': 'hi'},
    });

    expect(event.type, 'message.delta');
    expect(event.payload['delta'], 'hi');
  });
}
