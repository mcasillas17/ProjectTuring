//
//  Generated code. Do not modify.
//  source: turing/v1/chat.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'chat.pb.dart' as $1;

export 'chat.pb.dart';

@$pb.GrpcServiceName('turing.v1.ChatService')
class ChatServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  static final _$sendMessage =
      $grpc.ClientMethod<$1.SendMessageRequest, $1.ChatStreamEvent>(
          '/turing.v1.ChatService/SendMessage',
          ($1.SendMessageRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.ChatStreamEvent.fromBuffer(value));

  ChatServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$1.ChatStreamEvent> sendMessage(
      $1.SendMessageRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$sendMessage, $async.Stream.fromIterable([request]),
        options: options);
  }
}

@$pb.GrpcServiceName('turing.v1.ChatService')
abstract class ChatServiceBase extends $grpc.Service {
  $core.String get $name => 'turing.v1.ChatService';

  ChatServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.SendMessageRequest, $1.ChatStreamEvent>(
        'SendMessage',
        sendMessage_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $1.SendMessageRequest.fromBuffer(value),
        ($1.ChatStreamEvent value) => value.writeToBuffer()));
  }

  $async.Stream<$1.ChatStreamEvent> sendMessage_Pre($grpc.ServiceCall $call,
      $async.Future<$1.SendMessageRequest> $request) async* {
    yield* sendMessage($call, await $request);
  }

  $async.Stream<$1.ChatStreamEvent> sendMessage(
      $grpc.ServiceCall call, $1.SendMessageRequest request);
}
