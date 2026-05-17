//
//  Generated code. Do not modify.
//  source: turing/v1/mcp.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/struct.pb.dart' as $6;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class McpRequest extends $pb.GeneratedMessage {
  factory McpRequest({
    $core.String? serverName,
    $core.String? method,
    $6.Struct? params,
  }) {
    final $result = create();
    if (serverName != null) {
      $result.serverName = serverName;
    }
    if (method != null) {
      $result.method = method;
    }
    if (params != null) {
      $result.params = params;
    }
    return $result;
  }
  McpRequest._() : super();
  factory McpRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory McpRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'McpRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'serverName')
    ..aOS(2, _omitFieldNames ? '' : 'method')
    ..aOM<$6.Struct>(3, _omitFieldNames ? '' : 'params',
        subBuilder: $6.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpRequest clone() => McpRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpRequest copyWith(void Function(McpRequest) updates) =>
      super.copyWith((message) => updates(message as McpRequest)) as McpRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpRequest create() => McpRequest._();
  McpRequest createEmptyInstance() => create();
  static $pb.PbList<McpRequest> createRepeated() => $pb.PbList<McpRequest>();
  @$core.pragma('dart2js:noInline')
  static McpRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<McpRequest>(create);
  static McpRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serverName => $_getSZ(0);
  @$pb.TagNumber(1)
  set serverName($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasServerName() => $_has(0);
  @$pb.TagNumber(1)
  void clearServerName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get method => $_getSZ(1);
  @$pb.TagNumber(2)
  set method($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMethod() => $_has(1);
  @$pb.TagNumber(2)
  void clearMethod() => $_clearField(2);

  @$pb.TagNumber(3)
  $6.Struct get params => $_getN(2);
  @$pb.TagNumber(3)
  set params($6.Struct v) {
    $_setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasParams() => $_has(2);
  @$pb.TagNumber(3)
  void clearParams() => $_clearField(3);
  @$pb.TagNumber(3)
  $6.Struct ensureParams() => $_ensure(2);
}

class McpResult extends $pb.GeneratedMessage {
  factory McpResult({
    $6.Struct? result,
  }) {
    final $result = create();
    if (result != null) {
      $result.result = result;
    }
    return $result;
  }
  McpResult._() : super();
  factory McpResult.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory McpResult.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'McpResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOM<$6.Struct>(1, _omitFieldNames ? '' : 'result',
        subBuilder: $6.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpResult clone() => McpResult()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpResult copyWith(void Function(McpResult) updates) =>
      super.copyWith((message) => updates(message as McpResult)) as McpResult;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpResult create() => McpResult._();
  McpResult createEmptyInstance() => create();
  static $pb.PbList<McpResult> createRepeated() => $pb.PbList<McpResult>();
  @$core.pragma('dart2js:noInline')
  static McpResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<McpResult>(create);
  static McpResult? _defaultInstance;

  @$pb.TagNumber(1)
  $6.Struct get result => $_getN(0);
  @$pb.TagNumber(1)
  set result($6.Struct v) {
    $_setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => $_clearField(1);
  @$pb.TagNumber(1)
  $6.Struct ensureResult() => $_ensure(0);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
