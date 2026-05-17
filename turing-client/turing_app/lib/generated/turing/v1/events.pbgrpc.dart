//
//  Generated code. Do not modify.
//  source: turing/v1/events.proto
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

import 'events.pb.dart' as $2;

export 'events.pb.dart';

@$pb.GrpcServiceName('turing.v1.EventService')
class EventServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  static final _$listEvents =
      $grpc.ClientMethod<$2.ListEventsRequest, $2.ListEventsResponse>(
          '/turing.v1.EventService/ListEvents',
          ($2.ListEventsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $2.ListEventsResponse.fromBuffer(value));
  static final _$subscribeSessionEvents =
      $grpc.ClientMethod<$2.SubscribeSessionEventsRequest, $2.TuringEvent>(
          '/turing.v1.EventService/SubscribeSessionEvents',
          ($2.SubscribeSessionEventsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $2.TuringEvent.fromBuffer(value));

  EventServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$2.ListEventsResponse> listEvents(
      $2.ListEventsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listEvents, request, options: options);
  }

  $grpc.ResponseStream<$2.TuringEvent> subscribeSessionEvents(
      $2.SubscribeSessionEventsRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$subscribeSessionEvents, $async.Stream.fromIterable([request]),
        options: options);
  }
}

@$pb.GrpcServiceName('turing.v1.EventService')
abstract class EventServiceBase extends $grpc.Service {
  $core.String get $name => 'turing.v1.EventService';

  EventServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.ListEventsRequest, $2.ListEventsResponse>(
        'ListEvents',
        listEvents_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.ListEventsRequest.fromBuffer(value),
        ($2.ListEventsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$2.SubscribeSessionEventsRequest, $2.TuringEvent>(
            'SubscribeSessionEvents',
            subscribeSessionEvents_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $2.SubscribeSessionEventsRequest.fromBuffer(value),
            ($2.TuringEvent value) => value.writeToBuffer()));
  }

  $async.Future<$2.ListEventsResponse> listEvents_Pre($grpc.ServiceCall $call,
      $async.Future<$2.ListEventsRequest> $request) async {
    return listEvents($call, await $request);
  }

  $async.Stream<$2.TuringEvent> subscribeSessionEvents_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$2.SubscribeSessionEventsRequest> $request) async* {
    yield* subscribeSessionEvents($call, await $request);
  }

  $async.Future<$2.ListEventsResponse> listEvents(
      $grpc.ServiceCall call, $2.ListEventsRequest request);
  $async.Stream<$2.TuringEvent> subscribeSessionEvents(
      $grpc.ServiceCall call, $2.SubscribeSessionEventsRequest request);
}
