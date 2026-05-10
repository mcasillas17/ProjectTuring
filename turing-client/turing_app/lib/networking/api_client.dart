import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/message.dart';
import '../models/session.dart';
import '../models/turing_event.dart';

class TuringApiClient {
  TuringApiClient({
    required this.baseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final http.Client _httpClient;

  Map<String, String> get _headers => {
    'authorization': 'Bearer $apiKey',
    'content-type': 'application/json',
  };

  Future<Map<String, dynamic>> getConfig() async {
    final response = await _httpClient.get(
      _uri('/api/config'),
      headers: _headers,
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> createSession({String? title}) async {
    final response = await _httpClient.post(
      _uri('/api/sessions'),
      headers: _headers,
      body: jsonEncode({if (title != null) 'title': title}),
    );
    return _decodeMap(response);
  }

  Future<List<Session>> listSessions({int limit = 50, String? after}) async {
    final response = await _httpClient.get(
      _uri('/api/sessions', {
        'limit': '$limit',
        if (after != null) 'after': after,
      }),
      headers: _headers,
    );
    final body = _decodeMap(response);
    return (body['sessions'] as List? ?? const [])
        .map((item) => Session.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<Message>> listMessages({
    required String sessionId,
    int limit = 50,
    String? before,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/sessions/$sessionId/messages', {
        'limit': '$limit',
        if (before != null) 'before': before,
      }),
      headers: _headers,
    );
    final body = _decodeMap(response);
    return (body['messages'] as List? ?? const [])
        .map((item) => Message.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<TuringEvent>> listEvents({
    required String sessionId,
    int? after,
    int limit = 500,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/sessions/$sessionId/events', {
        if (after != null) 'after': '$after',
        'limit': '$limit',
      }),
      headers: _headers,
    );
    final body = _decodeMap(response);
    return (body['events'] as List? ?? const [])
        .map(
          (item) =>
              TuringEvent.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<Map<String, dynamic>> sendMessage({
    required String sessionId,
    required String content,
    String modelProvider = 'ollama',
  }) async {
    final response = await _httpClient.post(
      _uri('/api/sessions/$sessionId/messages'),
      headers: _headers,
      body: jsonEncode({'content': content, 'modelProvider': modelProvider}),
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> approveApproval(
    String approvalId, {
    String? comment,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/approvals/$approvalId/approve'),
      headers: _headers,
      body: jsonEncode({if (comment != null) 'comment': comment}),
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> denyApproval(
    String approvalId, {
    String? reason,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/approvals/$approvalId/deny'),
      headers: _headers,
      body: jsonEncode({if (reason != null) 'reason': reason}),
    );
    return _decodeMap(response);
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final normalizedBaseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.parse('$normalizedBaseUrl$path');
    return uri.replace(queryParameters: queryParameters);
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      final error = body['error'];
      if (error is Map) {
        throw TuringApiException(
          code: error['code'] as String? ?? 'request_failed',
          message: error['message'] as String? ?? 'Request failed',
          requestId: error['requestId'] as String?,
        );
      }
      throw TuringApiException(
        code: 'request_failed',
        message: 'Request failed with HTTP ${response.statusCode}',
      );
    }
    return body;
  }
}

class TuringApiException implements Exception {
  const TuringApiException({
    required this.code,
    required this.message,
    this.requestId,
  });

  final String code;
  final String message;
  final String? requestId;

  @override
  String toString() {
    final suffix = requestId == null ? '' : ' ($requestId)';
    return 'TuringApiException: $message$suffix';
  }
}
