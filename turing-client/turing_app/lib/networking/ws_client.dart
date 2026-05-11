import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/turing_event.dart';

abstract class TuringEventSource {
  Stream<TuringEvent> connect({required String sessionId, int? lastSequence});

  void close();
}

class TuringWsClient implements TuringEventSource {
  TuringWsClient({
    required this.baseUrl,
    required this.apiKey,
    WebSocketChannel Function(Uri uri)? connect,
  }) : _connect = connect ?? WebSocketChannel.connect;

  final String baseUrl;
  final String apiKey;
  final WebSocketChannel Function(Uri uri) _connect;
  WebSocketChannel? _channel;

  @override
  Stream<TuringEvent> connect({required String sessionId, int? lastSequence}) {
    _channel = _connect(_wsUri());
    _channel!.sink.add(
      jsonEncode({
        'type': 'hello',
        'sessionId': sessionId,
        if (lastSequence != null) 'lastSequence': lastSequence,
      }),
    );
    return _channel!.stream.expand((raw) {
      final message = jsonDecode(raw as String) as Map<String, dynamic>;
      if (message['type'] == 'hello_ack') {
        return (message['replayedEvents'] as List? ?? const []).map(
          (item) =>
              TuringEvent.fromJson(Map<String, dynamic>.from(item as Map)),
        );
      }
      if (message['type'] == 'event') {
        return [
          TuringEvent.fromJson(
            Map<String, dynamic>.from(message['event'] as Map),
          ),
        ];
      }
      if (message['type'] == 'resync_required') {
        throw const TuringWebSocketException(
          'WebSocket replay gap is too large; refetch session state.',
        );
      }
      if (message['type'] == 'error') {
        throw TuringWebSocketException(
          message['message'] as String? ?? 'WebSocket error',
        );
      }
      return const <TuringEvent>[];
    });
  }

  @override
  void close() => _channel?.sink.close();

  Uri _wsUri() {
    final base = Uri.parse(baseUrl.replaceFirst(RegExp(r'/+$'), ''));
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    return base.replace(
      scheme: scheme,
      path: '${base.path}/ws',
      queryParameters: {'token': apiKey},
    );
  }
}

class TuringWebSocketException implements Exception {
  const TuringWebSocketException(this.message);

  final String message;

  @override
  String toString() => 'TuringWebSocketException: $message';
}
