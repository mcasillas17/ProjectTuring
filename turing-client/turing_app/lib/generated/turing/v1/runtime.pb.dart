//
//  Generated code. Do not modify.
//  source: turing/v1/runtime.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/struct.pb.dart' as $6;
import 'common.pbenum.dart' as $7;
import 'events.pb.dart' as $2;
import 'tools.pb.dart' as $9;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class AgentJob extends $pb.GeneratedMessage {
  factory AgentJob({
    $core.String? jobId,
    $core.String? runId,
    $core.String? sessionId,
    $core.String? userMessageId,
    $core.String? assistantMessageId,
    $7.AgentId? agentId,
    $core.String? traceId,
    $7.ModelProvider? modelProvider,
    $core.String? model,
    $core.String? userText,
    $core.Iterable<$core.String>? requestedTools,
    $core.int? attempt,
  }) {
    final $result = create();
    if (jobId != null) {
      $result.jobId = jobId;
    }
    if (runId != null) {
      $result.runId = runId;
    }
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (userMessageId != null) {
      $result.userMessageId = userMessageId;
    }
    if (assistantMessageId != null) {
      $result.assistantMessageId = assistantMessageId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (traceId != null) {
      $result.traceId = traceId;
    }
    if (modelProvider != null) {
      $result.modelProvider = modelProvider;
    }
    if (model != null) {
      $result.model = model;
    }
    if (userText != null) {
      $result.userText = userText;
    }
    if (requestedTools != null) {
      $result.requestedTools.addAll(requestedTools);
    }
    if (attempt != null) {
      $result.attempt = attempt;
    }
    return $result;
  }
  AgentJob._() : super();
  factory AgentJob.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AgentJob.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentJob',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'jobId')
    ..aOS(2, _omitFieldNames ? '' : 'runId')
    ..aOS(3, _omitFieldNames ? '' : 'sessionId')
    ..aOS(4, _omitFieldNames ? '' : 'userMessageId')
    ..aOS(5, _omitFieldNames ? '' : 'assistantMessageId')
    ..e<$7.AgentId>(6, _omitFieldNames ? '' : 'agentId', $pb.PbFieldType.OE,
        defaultOrMaker: $7.AgentId.AGENT_ID_UNSPECIFIED,
        valueOf: $7.AgentId.valueOf,
        enumValues: $7.AgentId.values)
    ..aOS(7, _omitFieldNames ? '' : 'traceId')
    ..e<$7.ModelProvider>(
        8, _omitFieldNames ? '' : 'modelProvider', $pb.PbFieldType.OE,
        defaultOrMaker: $7.ModelProvider.MODEL_PROVIDER_UNSPECIFIED,
        valueOf: $7.ModelProvider.valueOf,
        enumValues: $7.ModelProvider.values)
    ..aOS(9, _omitFieldNames ? '' : 'model')
    ..aOS(10, _omitFieldNames ? '' : 'userText')
    ..pPS(11, _omitFieldNames ? '' : 'requestedTools')
    ..a<$core.int>(12, _omitFieldNames ? '' : 'attempt', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentJob clone() => AgentJob()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentJob copyWith(void Function(AgentJob) updates) =>
      super.copyWith((message) => updates(message as AgentJob)) as AgentJob;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentJob create() => AgentJob._();
  AgentJob createEmptyInstance() => create();
  static $pb.PbList<AgentJob> createRepeated() => $pb.PbList<AgentJob>();
  @$core.pragma('dart2js:noInline')
  static AgentJob getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentJob>(create);
  static AgentJob? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get jobId => $_getSZ(0);
  @$pb.TagNumber(1)
  set jobId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasJobId() => $_has(0);
  @$pb.TagNumber(1)
  void clearJobId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get runId => $_getSZ(1);
  @$pb.TagNumber(2)
  set runId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasRunId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRunId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sessionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sessionId($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasSessionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSessionId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get userMessageId => $_getSZ(3);
  @$pb.TagNumber(4)
  set userMessageId($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasUserMessageId() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserMessageId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get assistantMessageId => $_getSZ(4);
  @$pb.TagNumber(5)
  set assistantMessageId($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasAssistantMessageId() => $_has(4);
  @$pb.TagNumber(5)
  void clearAssistantMessageId() => $_clearField(5);

  @$pb.TagNumber(6)
  $7.AgentId get agentId => $_getN(5);
  @$pb.TagNumber(6)
  set agentId($7.AgentId v) {
    $_setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasAgentId() => $_has(5);
  @$pb.TagNumber(6)
  void clearAgentId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get traceId => $_getSZ(6);
  @$pb.TagNumber(7)
  set traceId($core.String v) {
    $_setString(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasTraceId() => $_has(6);
  @$pb.TagNumber(7)
  void clearTraceId() => $_clearField(7);

  @$pb.TagNumber(8)
  $7.ModelProvider get modelProvider => $_getN(7);
  @$pb.TagNumber(8)
  set modelProvider($7.ModelProvider v) {
    $_setField(8, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasModelProvider() => $_has(7);
  @$pb.TagNumber(8)
  void clearModelProvider() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get model => $_getSZ(8);
  @$pb.TagNumber(9)
  set model($core.String v) {
    $_setString(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasModel() => $_has(8);
  @$pb.TagNumber(9)
  void clearModel() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get userText => $_getSZ(9);
  @$pb.TagNumber(10)
  set userText($core.String v) {
    $_setString(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasUserText() => $_has(9);
  @$pb.TagNumber(10)
  void clearUserText() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get requestedTools => $_getList(10);

  @$pb.TagNumber(12)
  $core.int get attempt => $_getIZ(11);
  @$pb.TagNumber(12)
  set attempt($core.int v) {
    $_setSignedInt32(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasAttempt() => $_has(11);
  @$pb.TagNumber(12)
  void clearAttempt() => $_clearField(12);
}

class RuntimeWorkerReady extends $pb.GeneratedMessage {
  factory RuntimeWorkerReady({
    $core.String? workerId,
    $7.AgentId? agentId,
    $core.int? maxConcurrentRuns,
  }) {
    final $result = create();
    if (workerId != null) {
      $result.workerId = workerId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (maxConcurrentRuns != null) {
      $result.maxConcurrentRuns = maxConcurrentRuns;
    }
    return $result;
  }
  RuntimeWorkerReady._() : super();
  factory RuntimeWorkerReady.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeWorkerReady.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeWorkerReady',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'workerId')
    ..e<$7.AgentId>(2, _omitFieldNames ? '' : 'agentId', $pb.PbFieldType.OE,
        defaultOrMaker: $7.AgentId.AGENT_ID_UNSPECIFIED,
        valueOf: $7.AgentId.valueOf,
        enumValues: $7.AgentId.values)
    ..a<$core.int>(
        3, _omitFieldNames ? '' : 'maxConcurrentRuns', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeWorkerReady clone() => RuntimeWorkerReady()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeWorkerReady copyWith(void Function(RuntimeWorkerReady) updates) =>
      super.copyWith((message) => updates(message as RuntimeWorkerReady))
          as RuntimeWorkerReady;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeWorkerReady create() => RuntimeWorkerReady._();
  RuntimeWorkerReady createEmptyInstance() => create();
  static $pb.PbList<RuntimeWorkerReady> createRepeated() =>
      $pb.PbList<RuntimeWorkerReady>();
  @$core.pragma('dart2js:noInline')
  static RuntimeWorkerReady getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeWorkerReady>(create);
  static RuntimeWorkerReady? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workerId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasWorkerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $7.AgentId get agentId => $_getN(1);
  @$pb.TagNumber(2)
  set agentId($7.AgentId v) {
    $_setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasAgentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAgentId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get maxConcurrentRuns => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxConcurrentRuns($core.int v) {
    $_setSignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasMaxConcurrentRuns() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxConcurrentRuns() => $_clearField(3);
}

class RuntimeHeartbeat extends $pb.GeneratedMessage {
  factory RuntimeHeartbeat({
    $core.String? workerId,
  }) {
    final $result = create();
    if (workerId != null) {
      $result.workerId = workerId;
    }
    return $result;
  }
  RuntimeHeartbeat._() : super();
  factory RuntimeHeartbeat.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeHeartbeat.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeHeartbeat',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'workerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeHeartbeat clone() => RuntimeHeartbeat()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeHeartbeat copyWith(void Function(RuntimeHeartbeat) updates) =>
      super.copyWith((message) => updates(message as RuntimeHeartbeat))
          as RuntimeHeartbeat;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeHeartbeat create() => RuntimeHeartbeat._();
  RuntimeHeartbeat createEmptyInstance() => create();
  static $pb.PbList<RuntimeHeartbeat> createRepeated() =>
      $pb.PbList<RuntimeHeartbeat>();
  @$core.pragma('dart2js:noInline')
  static RuntimeHeartbeat getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeHeartbeat>(create);
  static RuntimeHeartbeat? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workerId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasWorkerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkerId() => $_clearField(1);
}

class RuntimeRunCompleted extends $pb.GeneratedMessage {
  factory RuntimeRunCompleted({
    $core.String? runId,
    $core.String? assistantMessageId,
    $core.String? content,
    $6.Struct? usage,
  }) {
    final $result = create();
    if (runId != null) {
      $result.runId = runId;
    }
    if (assistantMessageId != null) {
      $result.assistantMessageId = assistantMessageId;
    }
    if (content != null) {
      $result.content = content;
    }
    if (usage != null) {
      $result.usage = usage;
    }
    return $result;
  }
  RuntimeRunCompleted._() : super();
  factory RuntimeRunCompleted.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeRunCompleted.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeRunCompleted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'runId')
    ..aOS(2, _omitFieldNames ? '' : 'assistantMessageId')
    ..aOS(3, _omitFieldNames ? '' : 'content')
    ..aOM<$6.Struct>(4, _omitFieldNames ? '' : 'usage',
        subBuilder: $6.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeRunCompleted clone() => RuntimeRunCompleted()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeRunCompleted copyWith(void Function(RuntimeRunCompleted) updates) =>
      super.copyWith((message) => updates(message as RuntimeRunCompleted))
          as RuntimeRunCompleted;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeRunCompleted create() => RuntimeRunCompleted._();
  RuntimeRunCompleted createEmptyInstance() => create();
  static $pb.PbList<RuntimeRunCompleted> createRepeated() =>
      $pb.PbList<RuntimeRunCompleted>();
  @$core.pragma('dart2js:noInline')
  static RuntimeRunCompleted getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeRunCompleted>(create);
  static RuntimeRunCompleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get runId => $_getSZ(0);
  @$pb.TagNumber(1)
  set runId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRunId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRunId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get assistantMessageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set assistantMessageId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasAssistantMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAssistantMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get content => $_getSZ(2);
  @$pb.TagNumber(3)
  set content($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => $_clearField(3);

  @$pb.TagNumber(4)
  $6.Struct get usage => $_getN(3);
  @$pb.TagNumber(4)
  set usage($6.Struct v) {
    $_setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasUsage() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsage() => $_clearField(4);
  @$pb.TagNumber(4)
  $6.Struct ensureUsage() => $_ensure(3);
}

class RuntimeRunFailed extends $pb.GeneratedMessage {
  factory RuntimeRunFailed({
    $core.String? runId,
    $core.String? code,
    $core.String? message,
    $core.bool? retryable,
  }) {
    final $result = create();
    if (runId != null) {
      $result.runId = runId;
    }
    if (code != null) {
      $result.code = code;
    }
    if (message != null) {
      $result.message = message;
    }
    if (retryable != null) {
      $result.retryable = retryable;
    }
    return $result;
  }
  RuntimeRunFailed._() : super();
  factory RuntimeRunFailed.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeRunFailed.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeRunFailed',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'runId')
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..aOB(4, _omitFieldNames ? '' : 'retryable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeRunFailed clone() => RuntimeRunFailed()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeRunFailed copyWith(void Function(RuntimeRunFailed) updates) =>
      super.copyWith((message) => updates(message as RuntimeRunFailed))
          as RuntimeRunFailed;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeRunFailed create() => RuntimeRunFailed._();
  RuntimeRunFailed createEmptyInstance() => create();
  static $pb.PbList<RuntimeRunFailed> createRepeated() =>
      $pb.PbList<RuntimeRunFailed>();
  @$core.pragma('dart2js:noInline')
  static RuntimeRunFailed getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeRunFailed>(create);
  static RuntimeRunFailed? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get runId => $_getSZ(0);
  @$pb.TagNumber(1)
  set runId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRunId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRunId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get retryable => $_getBF(3);
  @$pb.TagNumber(4)
  set retryable($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasRetryable() => $_has(3);
  @$pb.TagNumber(4)
  void clearRetryable() => $_clearField(4);
}

class RuntimeCancelledAck extends $pb.GeneratedMessage {
  factory RuntimeCancelledAck({
    $core.String? runId,
  }) {
    final $result = create();
    if (runId != null) {
      $result.runId = runId;
    }
    return $result;
  }
  RuntimeCancelledAck._() : super();
  factory RuntimeCancelledAck.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeCancelledAck.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeCancelledAck',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'runId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeCancelledAck clone() => RuntimeCancelledAck()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeCancelledAck copyWith(void Function(RuntimeCancelledAck) updates) =>
      super.copyWith((message) => updates(message as RuntimeCancelledAck))
          as RuntimeCancelledAck;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeCancelledAck create() => RuntimeCancelledAck._();
  RuntimeCancelledAck createEmptyInstance() => create();
  static $pb.PbList<RuntimeCancelledAck> createRepeated() =>
      $pb.PbList<RuntimeCancelledAck>();
  @$core.pragma('dart2js:noInline')
  static RuntimeCancelledAck getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeCancelledAck>(create);
  static RuntimeCancelledAck? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get runId => $_getSZ(0);
  @$pb.TagNumber(1)
  set runId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRunId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRunId() => $_clearField(1);
}

enum RuntimeUpdate_Update {
  workerReady,
  heartbeat,
  event,
  toolBeacon,
  runCompleted,
  runFailed,
  runCancelledAck,
  notSet
}

class RuntimeUpdate extends $pb.GeneratedMessage {
  factory RuntimeUpdate({
    RuntimeWorkerReady? workerReady,
    RuntimeHeartbeat? heartbeat,
    $2.TuringEvent? event,
    $9.ToolCallBeacon? toolBeacon,
    RuntimeRunCompleted? runCompleted,
    RuntimeRunFailed? runFailed,
    RuntimeCancelledAck? runCancelledAck,
  }) {
    final $result = create();
    if (workerReady != null) {
      $result.workerReady = workerReady;
    }
    if (heartbeat != null) {
      $result.heartbeat = heartbeat;
    }
    if (event != null) {
      $result.event = event;
    }
    if (toolBeacon != null) {
      $result.toolBeacon = toolBeacon;
    }
    if (runCompleted != null) {
      $result.runCompleted = runCompleted;
    }
    if (runFailed != null) {
      $result.runFailed = runFailed;
    }
    if (runCancelledAck != null) {
      $result.runCancelledAck = runCancelledAck;
    }
    return $result;
  }
  RuntimeUpdate._() : super();
  factory RuntimeUpdate.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeUpdate.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, RuntimeUpdate_Update>
      _RuntimeUpdate_UpdateByTag = {
    1: RuntimeUpdate_Update.workerReady,
    2: RuntimeUpdate_Update.heartbeat,
    3: RuntimeUpdate_Update.event,
    4: RuntimeUpdate_Update.toolBeacon,
    5: RuntimeUpdate_Update.runCompleted,
    6: RuntimeUpdate_Update.runFailed,
    7: RuntimeUpdate_Update.runCancelledAck,
    0: RuntimeUpdate_Update.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7])
    ..aOM<RuntimeWorkerReady>(1, _omitFieldNames ? '' : 'workerReady',
        subBuilder: RuntimeWorkerReady.create)
    ..aOM<RuntimeHeartbeat>(2, _omitFieldNames ? '' : 'heartbeat',
        subBuilder: RuntimeHeartbeat.create)
    ..aOM<$2.TuringEvent>(3, _omitFieldNames ? '' : 'event',
        subBuilder: $2.TuringEvent.create)
    ..aOM<$9.ToolCallBeacon>(4, _omitFieldNames ? '' : 'toolBeacon',
        subBuilder: $9.ToolCallBeacon.create)
    ..aOM<RuntimeRunCompleted>(5, _omitFieldNames ? '' : 'runCompleted',
        subBuilder: RuntimeRunCompleted.create)
    ..aOM<RuntimeRunFailed>(6, _omitFieldNames ? '' : 'runFailed',
        subBuilder: RuntimeRunFailed.create)
    ..aOM<RuntimeCancelledAck>(7, _omitFieldNames ? '' : 'runCancelledAck',
        subBuilder: RuntimeCancelledAck.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeUpdate clone() => RuntimeUpdate()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeUpdate copyWith(void Function(RuntimeUpdate) updates) =>
      super.copyWith((message) => updates(message as RuntimeUpdate))
          as RuntimeUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeUpdate create() => RuntimeUpdate._();
  RuntimeUpdate createEmptyInstance() => create();
  static $pb.PbList<RuntimeUpdate> createRepeated() =>
      $pb.PbList<RuntimeUpdate>();
  @$core.pragma('dart2js:noInline')
  static RuntimeUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeUpdate>(create);
  static RuntimeUpdate? _defaultInstance;

  RuntimeUpdate_Update whichUpdate() =>
      _RuntimeUpdate_UpdateByTag[$_whichOneof(0)]!;
  void clearUpdate() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  RuntimeWorkerReady get workerReady => $_getN(0);
  @$pb.TagNumber(1)
  set workerReady(RuntimeWorkerReady v) {
    $_setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasWorkerReady() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkerReady() => $_clearField(1);
  @$pb.TagNumber(1)
  RuntimeWorkerReady ensureWorkerReady() => $_ensure(0);

  @$pb.TagNumber(2)
  RuntimeHeartbeat get heartbeat => $_getN(1);
  @$pb.TagNumber(2)
  set heartbeat(RuntimeHeartbeat v) {
    $_setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasHeartbeat() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeartbeat() => $_clearField(2);
  @$pb.TagNumber(2)
  RuntimeHeartbeat ensureHeartbeat() => $_ensure(1);

  @$pb.TagNumber(3)
  $2.TuringEvent get event => $_getN(2);
  @$pb.TagNumber(3)
  set event($2.TuringEvent v) {
    $_setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasEvent() => $_has(2);
  @$pb.TagNumber(3)
  void clearEvent() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.TuringEvent ensureEvent() => $_ensure(2);

  @$pb.TagNumber(4)
  $9.ToolCallBeacon get toolBeacon => $_getN(3);
  @$pb.TagNumber(4)
  set toolBeacon($9.ToolCallBeacon v) {
    $_setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasToolBeacon() => $_has(3);
  @$pb.TagNumber(4)
  void clearToolBeacon() => $_clearField(4);
  @$pb.TagNumber(4)
  $9.ToolCallBeacon ensureToolBeacon() => $_ensure(3);

  @$pb.TagNumber(5)
  RuntimeRunCompleted get runCompleted => $_getN(4);
  @$pb.TagNumber(5)
  set runCompleted(RuntimeRunCompleted v) {
    $_setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasRunCompleted() => $_has(4);
  @$pb.TagNumber(5)
  void clearRunCompleted() => $_clearField(5);
  @$pb.TagNumber(5)
  RuntimeRunCompleted ensureRunCompleted() => $_ensure(4);

  @$pb.TagNumber(6)
  RuntimeRunFailed get runFailed => $_getN(5);
  @$pb.TagNumber(6)
  set runFailed(RuntimeRunFailed v) {
    $_setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasRunFailed() => $_has(5);
  @$pb.TagNumber(6)
  void clearRunFailed() => $_clearField(6);
  @$pb.TagNumber(6)
  RuntimeRunFailed ensureRunFailed() => $_ensure(5);

  @$pb.TagNumber(7)
  RuntimeCancelledAck get runCancelledAck => $_getN(6);
  @$pb.TagNumber(7)
  set runCancelledAck(RuntimeCancelledAck v) {
    $_setField(7, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasRunCancelledAck() => $_has(6);
  @$pb.TagNumber(7)
  void clearRunCancelledAck() => $_clearField(7);
  @$pb.TagNumber(7)
  RuntimeCancelledAck ensureRunCancelledAck() => $_ensure(6);
}

class RuntimeWorkerAccepted extends $pb.GeneratedMessage {
  factory RuntimeWorkerAccepted({
    $core.String? workerId,
  }) {
    final $result = create();
    if (workerId != null) {
      $result.workerId = workerId;
    }
    return $result;
  }
  RuntimeWorkerAccepted._() : super();
  factory RuntimeWorkerAccepted.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeWorkerAccepted.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeWorkerAccepted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'workerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeWorkerAccepted clone() =>
      RuntimeWorkerAccepted()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeWorkerAccepted copyWith(
          void Function(RuntimeWorkerAccepted) updates) =>
      super.copyWith((message) => updates(message as RuntimeWorkerAccepted))
          as RuntimeWorkerAccepted;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeWorkerAccepted create() => RuntimeWorkerAccepted._();
  RuntimeWorkerAccepted createEmptyInstance() => create();
  static $pb.PbList<RuntimeWorkerAccepted> createRepeated() =>
      $pb.PbList<RuntimeWorkerAccepted>();
  @$core.pragma('dart2js:noInline')
  static RuntimeWorkerAccepted getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeWorkerAccepted>(create);
  static RuntimeWorkerAccepted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workerId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasWorkerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkerId() => $_clearField(1);
}

class RuntimeRunCancelled extends $pb.GeneratedMessage {
  factory RuntimeRunCancelled({
    $core.String? runId,
    $core.String? reason,
  }) {
    final $result = create();
    if (runId != null) {
      $result.runId = runId;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  RuntimeRunCancelled._() : super();
  factory RuntimeRunCancelled.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeRunCancelled.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeRunCancelled',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'runId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeRunCancelled clone() => RuntimeRunCancelled()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeRunCancelled copyWith(void Function(RuntimeRunCancelled) updates) =>
      super.copyWith((message) => updates(message as RuntimeRunCancelled))
          as RuntimeRunCancelled;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeRunCancelled create() => RuntimeRunCancelled._();
  RuntimeRunCancelled createEmptyInstance() => create();
  static $pb.PbList<RuntimeRunCancelled> createRepeated() =>
      $pb.PbList<RuntimeRunCancelled>();
  @$core.pragma('dart2js:noInline')
  static RuntimeRunCancelled getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeRunCancelled>(create);
  static RuntimeRunCancelled? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get runId => $_getSZ(0);
  @$pb.TagNumber(1)
  set runId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRunId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRunId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class RuntimeApprovalUpdated extends $pb.GeneratedMessage {
  factory RuntimeApprovalUpdated({
    $core.String? approvalId,
    $core.String? approvalToken,
    $core.String? status,
  }) {
    final $result = create();
    if (approvalId != null) {
      $result.approvalId = approvalId;
    }
    if (approvalToken != null) {
      $result.approvalToken = approvalToken;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  RuntimeApprovalUpdated._() : super();
  factory RuntimeApprovalUpdated.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeApprovalUpdated.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeApprovalUpdated',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'approvalId')
    ..aOS(2, _omitFieldNames ? '' : 'approvalToken')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeApprovalUpdated clone() =>
      RuntimeApprovalUpdated()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeApprovalUpdated copyWith(
          void Function(RuntimeApprovalUpdated) updates) =>
      super.copyWith((message) => updates(message as RuntimeApprovalUpdated))
          as RuntimeApprovalUpdated;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeApprovalUpdated create() => RuntimeApprovalUpdated._();
  RuntimeApprovalUpdated createEmptyInstance() => create();
  static $pb.PbList<RuntimeApprovalUpdated> createRepeated() =>
      $pb.PbList<RuntimeApprovalUpdated>();
  @$core.pragma('dart2js:noInline')
  static RuntimeApprovalUpdated getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeApprovalUpdated>(create);
  static RuntimeApprovalUpdated? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get approvalId => $_getSZ(0);
  @$pb.TagNumber(1)
  set approvalId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasApprovalId() => $_has(0);
  @$pb.TagNumber(1)
  void clearApprovalId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get approvalToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set approvalToken($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasApprovalToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearApprovalToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);
}

class RuntimeShutdownRequested extends $pb.GeneratedMessage {
  factory RuntimeShutdownRequested({
    $core.String? reason,
  }) {
    final $result = create();
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  RuntimeShutdownRequested._() : super();
  factory RuntimeShutdownRequested.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeShutdownRequested.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeShutdownRequested',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeShutdownRequested clone() =>
      RuntimeShutdownRequested()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeShutdownRequested copyWith(
          void Function(RuntimeShutdownRequested) updates) =>
      super.copyWith((message) => updates(message as RuntimeShutdownRequested))
          as RuntimeShutdownRequested;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeShutdownRequested create() => RuntimeShutdownRequested._();
  RuntimeShutdownRequested createEmptyInstance() => create();
  static $pb.PbList<RuntimeShutdownRequested> createRepeated() =>
      $pb.PbList<RuntimeShutdownRequested>();
  @$core.pragma('dart2js:noInline')
  static RuntimeShutdownRequested getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeShutdownRequested>(create);
  static RuntimeShutdownRequested? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reason => $_getSZ(0);
  @$pb.TagNumber(1)
  set reason($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasReason() => $_has(0);
  @$pb.TagNumber(1)
  void clearReason() => $_clearField(1);
}

enum RuntimeCommand_Command {
  workerAccepted,
  runAssigned,
  runCancelled,
  approvalUpdated,
  shutdownRequested,
  toolPolicyDecision,
  notSet
}

class RuntimeCommand extends $pb.GeneratedMessage {
  factory RuntimeCommand({
    RuntimeWorkerAccepted? workerAccepted,
    AgentJob? runAssigned,
    RuntimeRunCancelled? runCancelled,
    RuntimeApprovalUpdated? approvalUpdated,
    RuntimeShutdownRequested? shutdownRequested,
    $9.ToolPolicyDecision? toolPolicyDecision,
  }) {
    final $result = create();
    if (workerAccepted != null) {
      $result.workerAccepted = workerAccepted;
    }
    if (runAssigned != null) {
      $result.runAssigned = runAssigned;
    }
    if (runCancelled != null) {
      $result.runCancelled = runCancelled;
    }
    if (approvalUpdated != null) {
      $result.approvalUpdated = approvalUpdated;
    }
    if (shutdownRequested != null) {
      $result.shutdownRequested = shutdownRequested;
    }
    if (toolPolicyDecision != null) {
      $result.toolPolicyDecision = toolPolicyDecision;
    }
    return $result;
  }
  RuntimeCommand._() : super();
  factory RuntimeCommand.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RuntimeCommand.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, RuntimeCommand_Command>
      _RuntimeCommand_CommandByTag = {
    1: RuntimeCommand_Command.workerAccepted,
    2: RuntimeCommand_Command.runAssigned,
    3: RuntimeCommand_Command.runCancelled,
    4: RuntimeCommand_Command.approvalUpdated,
    5: RuntimeCommand_Command.shutdownRequested,
    6: RuntimeCommand_Command.toolPolicyDecision,
    0: RuntimeCommand_Command.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuntimeCommand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6])
    ..aOM<RuntimeWorkerAccepted>(1, _omitFieldNames ? '' : 'workerAccepted',
        subBuilder: RuntimeWorkerAccepted.create)
    ..aOM<AgentJob>(2, _omitFieldNames ? '' : 'runAssigned',
        subBuilder: AgentJob.create)
    ..aOM<RuntimeRunCancelled>(3, _omitFieldNames ? '' : 'runCancelled',
        subBuilder: RuntimeRunCancelled.create)
    ..aOM<RuntimeApprovalUpdated>(4, _omitFieldNames ? '' : 'approvalUpdated',
        subBuilder: RuntimeApprovalUpdated.create)
    ..aOM<RuntimeShutdownRequested>(
        5, _omitFieldNames ? '' : 'shutdownRequested',
        subBuilder: RuntimeShutdownRequested.create)
    ..aOM<$9.ToolPolicyDecision>(6, _omitFieldNames ? '' : 'toolPolicyDecision',
        subBuilder: $9.ToolPolicyDecision.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeCommand clone() => RuntimeCommand()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuntimeCommand copyWith(void Function(RuntimeCommand) updates) =>
      super.copyWith((message) => updates(message as RuntimeCommand))
          as RuntimeCommand;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuntimeCommand create() => RuntimeCommand._();
  RuntimeCommand createEmptyInstance() => create();
  static $pb.PbList<RuntimeCommand> createRepeated() =>
      $pb.PbList<RuntimeCommand>();
  @$core.pragma('dart2js:noInline')
  static RuntimeCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuntimeCommand>(create);
  static RuntimeCommand? _defaultInstance;

  RuntimeCommand_Command whichCommand() =>
      _RuntimeCommand_CommandByTag[$_whichOneof(0)]!;
  void clearCommand() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  RuntimeWorkerAccepted get workerAccepted => $_getN(0);
  @$pb.TagNumber(1)
  set workerAccepted(RuntimeWorkerAccepted v) {
    $_setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasWorkerAccepted() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkerAccepted() => $_clearField(1);
  @$pb.TagNumber(1)
  RuntimeWorkerAccepted ensureWorkerAccepted() => $_ensure(0);

  @$pb.TagNumber(2)
  AgentJob get runAssigned => $_getN(1);
  @$pb.TagNumber(2)
  set runAssigned(AgentJob v) {
    $_setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasRunAssigned() => $_has(1);
  @$pb.TagNumber(2)
  void clearRunAssigned() => $_clearField(2);
  @$pb.TagNumber(2)
  AgentJob ensureRunAssigned() => $_ensure(1);

  @$pb.TagNumber(3)
  RuntimeRunCancelled get runCancelled => $_getN(2);
  @$pb.TagNumber(3)
  set runCancelled(RuntimeRunCancelled v) {
    $_setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasRunCancelled() => $_has(2);
  @$pb.TagNumber(3)
  void clearRunCancelled() => $_clearField(3);
  @$pb.TagNumber(3)
  RuntimeRunCancelled ensureRunCancelled() => $_ensure(2);

  @$pb.TagNumber(4)
  RuntimeApprovalUpdated get approvalUpdated => $_getN(3);
  @$pb.TagNumber(4)
  set approvalUpdated(RuntimeApprovalUpdated v) {
    $_setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasApprovalUpdated() => $_has(3);
  @$pb.TagNumber(4)
  void clearApprovalUpdated() => $_clearField(4);
  @$pb.TagNumber(4)
  RuntimeApprovalUpdated ensureApprovalUpdated() => $_ensure(3);

  @$pb.TagNumber(5)
  RuntimeShutdownRequested get shutdownRequested => $_getN(4);
  @$pb.TagNumber(5)
  set shutdownRequested(RuntimeShutdownRequested v) {
    $_setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasShutdownRequested() => $_has(4);
  @$pb.TagNumber(5)
  void clearShutdownRequested() => $_clearField(5);
  @$pb.TagNumber(5)
  RuntimeShutdownRequested ensureShutdownRequested() => $_ensure(4);

  @$pb.TagNumber(6)
  $9.ToolPolicyDecision get toolPolicyDecision => $_getN(5);
  @$pb.TagNumber(6)
  set toolPolicyDecision($9.ToolPolicyDecision v) {
    $_setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasToolPolicyDecision() => $_has(5);
  @$pb.TagNumber(6)
  void clearToolPolicyDecision() => $_clearField(6);
  @$pb.TagNumber(6)
  $9.ToolPolicyDecision ensureToolPolicyDecision() => $_ensure(5);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
