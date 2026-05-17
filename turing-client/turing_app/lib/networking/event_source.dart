import 'dart:async';

import '../models/turing_event.dart';

abstract class TuringEventSource {
  Stream<TuringEvent> connect({required String sessionId, int? lastSequence});

  void close();
}
