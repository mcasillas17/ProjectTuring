//
//  Generated code. Do not modify.
//  source: turing/v1/sessions.proto
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

import 'sessions.pb.dart' as $5;

export 'sessions.pb.dart';

@$pb.GrpcServiceName('turing.v1.SessionService')
class SessionServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  static final _$createSession =
      $grpc.ClientMethod<$5.CreateSessionRequest, $5.CreateSessionResponse>(
          '/turing.v1.SessionService/CreateSession',
          ($5.CreateSessionRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $5.CreateSessionResponse.fromBuffer(value));
  static final _$listSessions =
      $grpc.ClientMethod<$5.ListSessionsRequest, $5.ListSessionsResponse>(
          '/turing.v1.SessionService/ListSessions',
          ($5.ListSessionsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $5.ListSessionsResponse.fromBuffer(value));
  static final _$getSession =
      $grpc.ClientMethod<$5.GetSessionRequest, $5.Session>(
          '/turing.v1.SessionService/GetSession',
          ($5.GetSessionRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $5.Session.fromBuffer(value));
  static final _$listMessages =
      $grpc.ClientMethod<$5.ListMessagesRequest, $5.ListMessagesResponse>(
          '/turing.v1.SessionService/ListMessages',
          ($5.ListMessagesRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $5.ListMessagesResponse.fromBuffer(value));
  static final _$getConfig =
      $grpc.ClientMethod<$5.GetConfigRequest, $5.GetConfigResponse>(
          '/turing.v1.SessionService/GetConfig',
          ($5.GetConfigRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $5.GetConfigResponse.fromBuffer(value));
  static final _$listAgents =
      $grpc.ClientMethod<$5.ListAgentsRequest, $5.ListAgentsResponse>(
          '/turing.v1.SessionService/ListAgents',
          ($5.ListAgentsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $5.ListAgentsResponse.fromBuffer(value));
  static final _$listTools =
      $grpc.ClientMethod<$5.ListToolsRequest, $5.ListToolsResponse>(
          '/turing.v1.SessionService/ListTools',
          ($5.ListToolsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $5.ListToolsResponse.fromBuffer(value));

  SessionServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$5.CreateSessionResponse> createSession(
      $5.CreateSessionRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createSession, request, options: options);
  }

  $grpc.ResponseFuture<$5.ListSessionsResponse> listSessions(
      $5.ListSessionsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listSessions, request, options: options);
  }

  $grpc.ResponseFuture<$5.Session> getSession($5.GetSessionRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getSession, request, options: options);
  }

  $grpc.ResponseFuture<$5.ListMessagesResponse> listMessages(
      $5.ListMessagesRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listMessages, request, options: options);
  }

  $grpc.ResponseFuture<$5.GetConfigResponse> getConfig(
      $5.GetConfigRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getConfig, request, options: options);
  }

  $grpc.ResponseFuture<$5.ListAgentsResponse> listAgents(
      $5.ListAgentsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listAgents, request, options: options);
  }

  $grpc.ResponseFuture<$5.ListToolsResponse> listTools(
      $5.ListToolsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listTools, request, options: options);
  }
}

@$pb.GrpcServiceName('turing.v1.SessionService')
abstract class SessionServiceBase extends $grpc.Service {
  $core.String get $name => 'turing.v1.SessionService';

  SessionServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$5.CreateSessionRequest, $5.CreateSessionResponse>(
            'CreateSession',
            createSession_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $5.CreateSessionRequest.fromBuffer(value),
            ($5.CreateSessionResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$5.ListSessionsRequest, $5.ListSessionsResponse>(
            'ListSessions',
            listSessions_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $5.ListSessionsRequest.fromBuffer(value),
            ($5.ListSessionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$5.GetSessionRequest, $5.Session>(
        'GetSession',
        getSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $5.GetSessionRequest.fromBuffer(value),
        ($5.Session value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$5.ListMessagesRequest, $5.ListMessagesResponse>(
            'ListMessages',
            listMessages_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $5.ListMessagesRequest.fromBuffer(value),
            ($5.ListMessagesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$5.GetConfigRequest, $5.GetConfigResponse>(
        'GetConfig',
        getConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $5.GetConfigRequest.fromBuffer(value),
        ($5.GetConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$5.ListAgentsRequest, $5.ListAgentsResponse>(
        'ListAgents',
        listAgents_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $5.ListAgentsRequest.fromBuffer(value),
        ($5.ListAgentsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$5.ListToolsRequest, $5.ListToolsResponse>(
        'ListTools',
        listTools_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $5.ListToolsRequest.fromBuffer(value),
        ($5.ListToolsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$5.CreateSessionResponse> createSession_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$5.CreateSessionRequest> $request) async {
    return createSession($call, await $request);
  }

  $async.Future<$5.ListSessionsResponse> listSessions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$5.ListSessionsRequest> $request) async {
    return listSessions($call, await $request);
  }

  $async.Future<$5.Session> getSession_Pre($grpc.ServiceCall $call,
      $async.Future<$5.GetSessionRequest> $request) async {
    return getSession($call, await $request);
  }

  $async.Future<$5.ListMessagesResponse> listMessages_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$5.ListMessagesRequest> $request) async {
    return listMessages($call, await $request);
  }

  $async.Future<$5.GetConfigResponse> getConfig_Pre($grpc.ServiceCall $call,
      $async.Future<$5.GetConfigRequest> $request) async {
    return getConfig($call, await $request);
  }

  $async.Future<$5.ListAgentsResponse> listAgents_Pre($grpc.ServiceCall $call,
      $async.Future<$5.ListAgentsRequest> $request) async {
    return listAgents($call, await $request);
  }

  $async.Future<$5.ListToolsResponse> listTools_Pre($grpc.ServiceCall $call,
      $async.Future<$5.ListToolsRequest> $request) async {
    return listTools($call, await $request);
  }

  $async.Future<$5.CreateSessionResponse> createSession(
      $grpc.ServiceCall call, $5.CreateSessionRequest request);
  $async.Future<$5.ListSessionsResponse> listSessions(
      $grpc.ServiceCall call, $5.ListSessionsRequest request);
  $async.Future<$5.Session> getSession(
      $grpc.ServiceCall call, $5.GetSessionRequest request);
  $async.Future<$5.ListMessagesResponse> listMessages(
      $grpc.ServiceCall call, $5.ListMessagesRequest request);
  $async.Future<$5.GetConfigResponse> getConfig(
      $grpc.ServiceCall call, $5.GetConfigRequest request);
  $async.Future<$5.ListAgentsResponse> listAgents(
      $grpc.ServiceCall call, $5.ListAgentsRequest request);
  $async.Future<$5.ListToolsResponse> listTools(
      $grpc.ServiceCall call, $5.ListToolsRequest request);
}
