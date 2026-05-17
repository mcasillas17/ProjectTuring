//
//  Generated code. Do not modify.
//  source: turing/v1/runtime.proto
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

import 'runtime.pb.dart' as $4;

export 'runtime.pb.dart';

@$pb.GrpcServiceName('turing.v1.RuntimeService')
class RuntimeServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  static final _$connectWorker =
      $grpc.ClientMethod<$4.RuntimeUpdate, $4.RuntimeCommand>(
          '/turing.v1.RuntimeService/ConnectWorker',
          ($4.RuntimeUpdate value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $4.RuntimeCommand.fromBuffer(value));

  RuntimeServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$4.RuntimeCommand> connectWorker(
      $async.Stream<$4.RuntimeUpdate> request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$connectWorker, request, options: options);
  }
}

@$pb.GrpcServiceName('turing.v1.RuntimeService')
abstract class RuntimeServiceBase extends $grpc.Service {
  $core.String get $name => 'turing.v1.RuntimeService';

  RuntimeServiceBase() {
    $addMethod($grpc.ServiceMethod<$4.RuntimeUpdate, $4.RuntimeCommand>(
        'ConnectWorker',
        connectWorker,
        true,
        true,
        ($core.List<$core.int> value) => $4.RuntimeUpdate.fromBuffer(value),
        ($4.RuntimeCommand value) => value.writeToBuffer()));
  }

  $async.Stream<$4.RuntimeCommand> connectWorker(
      $grpc.ServiceCall call, $async.Stream<$4.RuntimeUpdate> request);
}
