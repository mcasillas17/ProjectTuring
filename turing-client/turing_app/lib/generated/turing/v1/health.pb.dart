//
//  Generated code. Do not modify.
//  source: turing/v1/health.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class HealthCheckRequest extends $pb.GeneratedMessage {
  factory HealthCheckRequest() => create();
  HealthCheckRequest._() : super();
  factory HealthCheckRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory HealthCheckRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HealthCheckRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthCheckRequest clone() => HealthCheckRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthCheckRequest copyWith(void Function(HealthCheckRequest) updates) =>
      super.copyWith((message) => updates(message as HealthCheckRequest))
          as HealthCheckRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HealthCheckRequest create() => HealthCheckRequest._();
  HealthCheckRequest createEmptyInstance() => create();
  static $pb.PbList<HealthCheckRequest> createRepeated() =>
      $pb.PbList<HealthCheckRequest>();
  @$core.pragma('dart2js:noInline')
  static HealthCheckRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HealthCheckRequest>(create);
  static HealthCheckRequest? _defaultInstance;
}

class HealthCheckResponse extends $pb.GeneratedMessage {
  factory HealthCheckResponse({
    $core.bool? ok,
  }) {
    final $result = create();
    if (ok != null) {
      $result.ok = ok;
    }
    return $result;
  }
  HealthCheckResponse._() : super();
  factory HealthCheckResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory HealthCheckResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HealthCheckResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthCheckResponse clone() => HealthCheckResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthCheckResponse copyWith(void Function(HealthCheckResponse) updates) =>
      super.copyWith((message) => updates(message as HealthCheckResponse))
          as HealthCheckResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HealthCheckResponse create() => HealthCheckResponse._();
  HealthCheckResponse createEmptyInstance() => create();
  static $pb.PbList<HealthCheckResponse> createRepeated() =>
      $pb.PbList<HealthCheckResponse>();
  @$core.pragma('dart2js:noInline')
  static HealthCheckResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HealthCheckResponse>(create);
  static HealthCheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool v) {
    $_setBool(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);
}

class VersionRequest extends $pb.GeneratedMessage {
  factory VersionRequest() => create();
  VersionRequest._() : super();
  factory VersionRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory VersionRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VersionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VersionRequest clone() => VersionRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VersionRequest copyWith(void Function(VersionRequest) updates) =>
      super.copyWith((message) => updates(message as VersionRequest))
          as VersionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionRequest create() => VersionRequest._();
  VersionRequest createEmptyInstance() => create();
  static $pb.PbList<VersionRequest> createRepeated() =>
      $pb.PbList<VersionRequest>();
  @$core.pragma('dart2js:noInline')
  static VersionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VersionRequest>(create);
  static VersionRequest? _defaultInstance;
}

class VersionResponse extends $pb.GeneratedMessage {
  factory VersionResponse({
    $core.String? version,
    $core.String? schemaVersion,
  }) {
    final $result = create();
    if (version != null) {
      $result.version = version;
    }
    if (schemaVersion != null) {
      $result.schemaVersion = schemaVersion;
    }
    return $result;
  }
  VersionResponse._() : super();
  factory VersionResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory VersionResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VersionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..aOS(2, _omitFieldNames ? '' : 'schemaVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VersionResponse clone() => VersionResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VersionResponse copyWith(void Function(VersionResponse) updates) =>
      super.copyWith((message) => updates(message as VersionResponse))
          as VersionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionResponse create() => VersionResponse._();
  VersionResponse createEmptyInstance() => create();
  static $pb.PbList<VersionResponse> createRepeated() =>
      $pb.PbList<VersionResponse>();
  @$core.pragma('dart2js:noInline')
  static VersionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VersionResponse>(create);
  static VersionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get schemaVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set schemaVersion($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasSchemaVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearSchemaVersion() => $_clearField(2);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
