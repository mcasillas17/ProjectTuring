import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:turing_flutter_app/networking/api_client.dart';

void main() {
  test('fetches config with bearer auth', () async {
    final client = TuringApiClient(
      baseUrl: 'http://localhost:3000',
      apiKey: 'tk_test',
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://localhost:3000/api/config');
        expect(request.headers['authorization'], 'Bearer tk_test');
        return http.Response(
          jsonEncode({
            'defaultModel': 'llama3.2',
            'enabledProviders': ['ollama'],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final config = await client.getConfig();

    expect(config['defaultModel'], 'llama3.2');
  });

  test('creates session through REST', () async {
    final client = TuringApiClient(
      baseUrl: 'http://localhost:3000/',
      apiKey: 'tk_test',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'http://localhost:3000/api/sessions');
        expect(request.headers['authorization'], 'Bearer tk_test');
        expect(jsonDecode(request.body), {'title': 'Smoke'});
        return http.Response(
          jsonEncode({
            'sessionId': 'sess_1',
            'createdAt': '2026-05-10T00:00:00.000Z',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result = await client.createSession(title: 'Smoke');

    expect(result['sessionId'], 'sess_1');
  });

  test('sends messages with the selected model provider', () async {
    final client = TuringApiClient(
      baseUrl: 'http://localhost:3000',
      apiKey: 'tk_test',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'http://localhost:3000/api/sessions/sess_1/messages',
        );
        expect(jsonDecode(request.body), {
          'content': 'hello',
          'modelProvider': 'openai_compatible',
        });
        return http.Response(
          jsonEncode({
            'sessionId': 'sess_1',
            'userMessageId': 'msg_user',
            'assistantMessageId': 'msg_asst',
            'runId': 'run_1',
            'jobId': 'job_1',
            'traceId': 'trace_1',
            'status': 'queued',
          }),
          202,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result = await client.sendMessage(
      sessionId: 'sess_1',
      content: 'hello',
      modelProvider: 'openai_compatible',
    );

    expect(result['status'], 'queued');
  });

  test('throws API error messages from typed error responses', () async {
    final client = TuringApiClient(
      baseUrl: 'http://localhost:3000',
      apiKey: 'tk_test',
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {
              'code': 'unauthorized',
              'message': 'Bad API key',
              'requestId': 'req_1',
            },
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    expect(client.getConfig, throwsA(isA<TuringApiException>()));
  });
}
