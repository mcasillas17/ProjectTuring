//
//  Generated code. Do not modify.
//  source: turing/v1/health.proto
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

import 'health.pb.dart' as $3;

export 'health.pb.dart';

@$pb.GrpcServiceName('turing.v1.HealthService')
class HealthServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  static final _$check =
      $grpc.ClientMethod<$3.HealthCheckRequest, $3.HealthCheckResponse>(
          '/turing.v1.HealthService/Check',
          ($3.HealthCheckRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $3.HealthCheckResponse.fromBuffer(value));
  static final _$version =
      $grpc.ClientMethod<$3.VersionRequest, $3.VersionResponse>(
          '/turing.v1.HealthService/Version',
          ($3.VersionRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $3.VersionResponse.fromBuffer(value));

  HealthServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$3.HealthCheckResponse> check(
      $3.HealthCheckRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$check, request, options: options);
  }

  $grpc.ResponseFuture<$3.VersionResponse> version($3.VersionRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$version, request, options: options);
  }
}

@$pb.GrpcServiceName('turing.v1.HealthService')
abstract class HealthServiceBase extends $grpc.Service {
  $core.String get $name => 'turing.v1.HealthService';

  HealthServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$3.HealthCheckRequest, $3.HealthCheckResponse>(
            'Check',
            check_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $3.HealthCheckRequest.fromBuffer(value),
            ($3.HealthCheckResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.VersionRequest, $3.VersionResponse>(
        'Version',
        version_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.VersionRequest.fromBuffer(value),
        ($3.VersionResponse value) => value.writeToBuffer()));
  }

  $async.Future<$3.HealthCheckResponse> check_Pre($grpc.ServiceCall $call,
      $async.Future<$3.HealthCheckRequest> $request) async {
    return check($call, await $request);
  }

  $async.Future<$3.VersionResponse> version_Pre($grpc.ServiceCall $call,
      $async.Future<$3.VersionRequest> $request) async {
    return version($call, await $request);
  }

  $async.Future<$3.HealthCheckResponse> check(
      $grpc.ServiceCall call, $3.HealthCheckRequest request);
  $async.Future<$3.VersionResponse> version(
      $grpc.ServiceCall call, $3.VersionRequest request);
}
