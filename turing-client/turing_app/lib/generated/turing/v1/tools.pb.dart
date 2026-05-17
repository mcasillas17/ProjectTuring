//
//  Generated code. Do not modify.
//  source: turing/v1/tools.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/struct.pb.dart' as $6;
import 'common.pbenum.dart' as $7;
import 'tools.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'tools.pbenum.dart';

class ToolCallError extends $pb.GeneratedMessage {
  factory ToolCallError({
    $core.String? code,
    $core.String? message,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  ToolCallError._() : super();
  factory ToolCallError.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ToolCallError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ToolCallError',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToolCallError clone() => ToolCallError()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToolCallError copyWith(void Function(ToolCallError) updates) =>
      super.copyWith((message) => updates(message as ToolCallError))
          as ToolCallError;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ToolCallError create() => ToolCallError._();
  ToolCallError createEmptyInstance() => create();
  static $pb.PbList<ToolCallError> createRepeated() =>
      $pb.PbList<ToolCallError>();
  @$core.pragma('dart2js:noInline')
  static ToolCallError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ToolCallError>(create);
  static ToolCallError? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class ToolCallBeacon extends $pb.GeneratedMessage {
  factory ToolCallBeacon({
    ToolCallPhase? phase,
    $core.String? toolCallId,
    $7.AgentId? agentId,
    $core.String? serverName,
    $core.String? toolName,
    $6.Struct? args,
    ToolCallStatus? status,
    $core.String? resultSummary,
    $fixnum.Int64? durationMs,
    ToolCallError? error,
    $core.String? runId,
    $core.String? traceId,
  }) {
    final $result = create();
    if (phase != null) {
      $result.phase = phase;
    }
    if (toolCallId != null) {
      $result.toolCallId = toolCallId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (serverName != null) {
      $result.serverName = serverName;
    }
    if (toolName != null) {
      $result.toolName = toolName;
    }
    if (args != null) {
      $result.args = args;
    }
    if (status != null) {
      $result.status = status;
    }
    if (resultSummary != null) {
      $result.resultSummary = resultSummary;
    }
    if (durationMs != null) {
      $result.durationMs = durationMs;
    }
    if (error != null) {
      $result.error = error;
    }
    if (runId != null) {
      $result.runId = runId;
    }
    if (traceId != null) {
      $result.traceId = traceId;
    }
    return $result;
  }
  ToolCallBeacon._() : super();
  factory ToolCallBeacon.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ToolCallBeacon.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ToolCallBeacon',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..e<ToolCallPhase>(1, _omitFieldNames ? '' : 'phase', $pb.PbFieldType.OE,
        defaultOrMaker: ToolCallPhase.TOOL_CALL_PHASE_UNSPECIFIED,
        valueOf: ToolCallPhase.valueOf,
        enumValues: ToolCallPhase.values)
    ..aOS(2, _omitFieldNames ? '' : 'toolCallId')
    ..e<$7.AgentId>(3, _omitFieldNames ? '' : 'agentId', $pb.PbFieldType.OE,
        defaultOrMaker: $7.AgentId.AGENT_ID_UNSPECIFIED,
        valueOf: $7.AgentId.valueOf,
        enumValues: $7.AgentId.values)
    ..aOS(4, _omitFieldNames ? '' : 'serverName')
    ..aOS(5, _omitFieldNames ? '' : 'toolName')
    ..aOM<$6.Struct>(6, _omitFieldNames ? '' : 'args',
        subBuilder: $6.Struct.create)
    ..e<ToolCallStatus>(7, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE,
        defaultOrMaker: ToolCallStatus.TOOL_CALL_STATUS_UNSPECIFIED,
        valueOf: ToolCallStatus.valueOf,
        enumValues: ToolCallStatus.values)
    ..aOS(8, _omitFieldNames ? '' : 'resultSummary')
    ..aInt64(9, _omitFieldNames ? '' : 'durationMs')
    ..aOM<ToolCallError>(10, _omitFieldNames ? '' : 'error',
        subBuilder: ToolCallError.create)
    ..aOS(11, _omitFieldNames ? '' : 'runId')
    ..aOS(12, _omitFieldNames ? '' : 'traceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToolCallBeacon clone() => ToolCallBeacon()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToolCallBeacon copyWith(void Function(ToolCallBeacon) updates) =>
      super.copyWith((message) => updates(message as ToolCallBeacon))
          as ToolCallBeacon;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ToolCallBeacon create() => ToolCallBeacon._();
  ToolCallBeacon createEmptyInstance() => create();
  static $pb.PbList<ToolCallBeacon> createRepeated() =>
      $pb.PbList<ToolCallBeacon>();
  @$core.pragma('dart2js:noInline')
  static ToolCallBeacon getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ToolCallBeacon>(create);
  static ToolCallBeacon? _defaultInstance;

  @$pb.TagNumber(1)
  ToolCallPhase get phase => $_getN(0);
  @$pb.TagNumber(1)
  set phase(ToolCallPhase v) {
    $_setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPhase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhase() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toolCallId => $_getSZ(1);
  @$pb.TagNumber(2)
  set toolCallId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasToolCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearToolCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  $7.AgentId get agentId => $_getN(2);
  @$pb.TagNumber(3)
  set agentId($7.AgentId v) {
    $_setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get serverName => $_getSZ(3);
  @$pb.TagNumber(4)
  set serverName($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasServerName() => $_has(3);
  @$pb.TagNumber(4)
  void clearServerName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get toolName => $_getSZ(4);
  @$pb.TagNumber(5)
  set toolName($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasToolName() => $_has(4);
  @$pb.TagNumber(5)
  void clearToolName() => $_clearField(5);

  @$pb.TagNumber(6)
  $6.Struct get args => $_getN(5);
  @$pb.TagNumber(6)
  set args($6.Struct v) {
    $_setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasArgs() => $_has(5);
  @$pb.TagNumber(6)
  void clearArgs() => $_clearField(6);
  @$pb.TagNumber(6)
  $6.Struct ensureArgs() => $_ensure(5);

  @$pb.TagNumber(7)
  ToolCallStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(ToolCallStatus v) {
    $_setField(7, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get resultSummary => $_getSZ(7);
  @$pb.TagNumber(8)
  set resultSummary($core.String v) {
    $_setString(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasResultSummary() => $_has(7);
  @$pb.TagNumber(8)
  void clearResultSummary() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get durationMs => $_getI64(8);
  @$pb.TagNumber(9)
  set durationMs($fixnum.Int64 v) {
    $_setInt64(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasDurationMs() => $_has(8);
  @$pb.TagNumber(9)
  void clearDurationMs() => $_clearField(9);

  @$pb.TagNumber(10)
  ToolCallError get error => $_getN(9);
  @$pb.TagNumber(10)
  set error(ToolCallError v) {
    $_setField(10, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasError() => $_has(9);
  @$pb.TagNumber(10)
  void clearError() => $_clearField(10);
  @$pb.TagNumber(10)
  ToolCallError ensureError() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.String get runId => $_getSZ(10);
  @$pb.TagNumber(11)
  set runId($core.String v) {
    $_setString(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasRunId() => $_has(10);
  @$pb.TagNumber(11)
  void clearRunId() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get traceId => $_getSZ(11);
  @$pb.TagNumber(12)
  set traceId($core.String v) {
    $_setString(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasTraceId() => $_has(11);
  @$pb.TagNumber(12)
  void clearTraceId() => $_clearField(12);
}

class ToolPolicyDecision extends $pb.GeneratedMessage {
  factory ToolPolicyDecision({
    ToolPolicyDecision_Decision? decision,
    $core.String? toolCallId,
    $core.String? approvalId,
    $core.String? reason,
  }) {
    final $result = create();
    if (decision != null) {
      $result.decision = decision;
    }
    if (toolCallId != null) {
      $result.toolCallId = toolCallId;
    }
    if (approvalId != null) {
      $result.approvalId = approvalId;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  ToolPolicyDecision._() : super();
  factory ToolPolicyDecision.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ToolPolicyDecision.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ToolPolicyDecision',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..e<ToolPolicyDecision_Decision>(
        1, _omitFieldNames ? '' : 'decision', $pb.PbFieldType.OE,
        defaultOrMaker: ToolPolicyDecision_Decision.DECISION_UNSPECIFIED,
        valueOf: ToolPolicyDecision_Decision.valueOf,
        enumValues: ToolPolicyDecision_Decision.values)
    ..aOS(2, _omitFieldNames ? '' : 'toolCallId')
    ..aOS(3, _omitFieldNames ? '' : 'approvalId')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToolPolicyDecision clone() => ToolPolicyDecision()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToolPolicyDecision copyWith(void Function(ToolPolicyDecision) updates) =>
      super.copyWith((message) => updates(message as ToolPolicyDecision))
          as ToolPolicyDecision;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ToolPolicyDecision create() => ToolPolicyDecision._();
  ToolPolicyDecision createEmptyInstance() => create();
  static $pb.PbList<ToolPolicyDecision> createRepeated() =>
      $pb.PbList<ToolPolicyDecision>();
  @$core.pragma('dart2js:noInline')
  static ToolPolicyDecision getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ToolPolicyDecision>(create);
  static ToolPolicyDecision? _defaultInstance;

  @$pb.TagNumber(1)
  ToolPolicyDecision_Decision get decision => $_getN(0);
  @$pb.TagNumber(1)
  set decision(ToolPolicyDecision_Decision v) {
    $_setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasDecision() => $_has(0);
  @$pb.TagNumber(1)
  void clearDecision() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toolCallId => $_getSZ(1);
  @$pb.TagNumber(2)
  set toolCallId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasToolCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearToolCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get approvalId => $_getSZ(2);
  @$pb.TagNumber(3)
  set approvalId($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasApprovalId() => $_has(2);
  @$pb.TagNumber(3)
  void clearApprovalId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
