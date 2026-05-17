//
//  Generated code. Do not modify.
//  source: turing/v1/events.proto
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
import '../../google/protobuf/timestamp.pb.dart' as $8;
import 'events.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'events.pbenum.dart';

class TuringEvent extends $pb.GeneratedMessage {
  factory TuringEvent({
    $core.String? eventId,
    $core.String? sessionId,
    $core.String? runId,
    $core.String? traceId,
    $fixnum.Int64? sequence,
    TuringEventType? type,
    $8.Timestamp? createdAt,
    $6.Struct? payload,
  }) {
    final $result = create();
    if (eventId != null) {
      $result.eventId = eventId;
    }
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (runId != null) {
      $result.runId = runId;
    }
    if (traceId != null) {
      $result.traceId = traceId;
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    if (type != null) {
      $result.type = type;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (payload != null) {
      $result.payload = payload;
    }
    return $result;
  }
  TuringEvent._() : super();
  factory TuringEvent.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TuringEvent.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TuringEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'eventId')
    ..aOS(2, _omitFieldNames ? '' : 'sessionId')
    ..aOS(3, _omitFieldNames ? '' : 'runId')
    ..aOS(4, _omitFieldNames ? '' : 'traceId')
    ..aInt64(5, _omitFieldNames ? '' : 'sequence')
    ..e<TuringEventType>(6, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: TuringEventType.TURING_EVENT_TYPE_UNSPECIFIED,
        valueOf: TuringEventType.valueOf,
        enumValues: TuringEventType.values)
    ..aOM<$8.Timestamp>(7, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $8.Timestamp.create)
    ..aOM<$6.Struct>(8, _omitFieldNames ? '' : 'payload',
        subBuilder: $6.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TuringEvent clone() => TuringEvent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TuringEvent copyWith(void Function(TuringEvent) updates) =>
      super.copyWith((message) => updates(message as TuringEvent))
          as TuringEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TuringEvent create() => TuringEvent._();
  TuringEvent createEmptyInstance() => create();
  static $pb.PbList<TuringEvent> createRepeated() => $pb.PbList<TuringEvent>();
  @$core.pragma('dart2js:noInline')
  static TuringEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TuringEvent>(create);
  static TuringEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sessionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sessionId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasSessionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSessionId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get runId => $_getSZ(2);
  @$pb.TagNumber(3)
  set runId($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasRunId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRunId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get traceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set traceId($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasTraceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTraceId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get sequence => $_getI64(4);
  @$pb.TagNumber(5)
  set sequence($fixnum.Int64 v) {
    $_setInt64(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasSequence() => $_has(4);
  @$pb.TagNumber(5)
  void clearSequence() => $_clearField(5);

  @$pb.TagNumber(6)
  TuringEventType get type => $_getN(5);
  @$pb.TagNumber(6)
  set type(TuringEventType v) {
    $_setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasType() => $_has(5);
  @$pb.TagNumber(6)
  void clearType() => $_clearField(6);

  @$pb.TagNumber(7)
  $8.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($8.Timestamp v) {
    $_setField(7, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $8.Timestamp ensureCreatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $6.Struct get payload => $_getN(7);
  @$pb.TagNumber(8)
  set payload($6.Struct v) {
    $_setField(8, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasPayload() => $_has(7);
  @$pb.TagNumber(8)
  void clearPayload() => $_clearField(8);
  @$pb.TagNumber(8)
  $6.Struct ensurePayload() => $_ensure(7);
}

class ListEventsRequest extends $pb.GeneratedMessage {
  factory ListEventsRequest({
    $core.String? sessionId,
    $fixnum.Int64? afterSequence,
    $core.int? limit,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (afterSequence != null) {
      $result.afterSequence = afterSequence;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  ListEventsRequest._() : super();
  factory ListEventsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListEventsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListEventsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aInt64(2, _omitFieldNames ? '' : 'afterSequence')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListEventsRequest clone() => ListEventsRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListEventsRequest copyWith(void Function(ListEventsRequest) updates) =>
      super.copyWith((message) => updates(message as ListEventsRequest))
          as ListEventsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListEventsRequest create() => ListEventsRequest._();
  ListEventsRequest createEmptyInstance() => create();
  static $pb.PbList<ListEventsRequest> createRepeated() =>
      $pb.PbList<ListEventsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListEventsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListEventsRequest>(create);
  static ListEventsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get afterSequence => $_getI64(1);
  @$pb.TagNumber(2)
  set afterSequence($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasAfterSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearAfterSequence() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int v) {
    $_setSignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

class ListEventsResponse extends $pb.GeneratedMessage {
  factory ListEventsResponse({
    $core.Iterable<TuringEvent>? events,
    $fixnum.Int64? latestSequence,
    $core.bool? resyncRequired,
  }) {
    final $result = create();
    if (events != null) {
      $result.events.addAll(events);
    }
    if (latestSequence != null) {
      $result.latestSequence = latestSequence;
    }
    if (resyncRequired != null) {
      $result.resyncRequired = resyncRequired;
    }
    return $result;
  }
  ListEventsResponse._() : super();
  factory ListEventsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListEventsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListEventsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..pc<TuringEvent>(1, _omitFieldNames ? '' : 'events', $pb.PbFieldType.PM,
        subBuilder: TuringEvent.create)
    ..aInt64(2, _omitFieldNames ? '' : 'latestSequence')
    ..aOB(3, _omitFieldNames ? '' : 'resyncRequired')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListEventsResponse clone() => ListEventsResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListEventsResponse copyWith(void Function(ListEventsResponse) updates) =>
      super.copyWith((message) => updates(message as ListEventsResponse))
          as ListEventsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListEventsResponse create() => ListEventsResponse._();
  ListEventsResponse createEmptyInstance() => create();
  static $pb.PbList<ListEventsResponse> createRepeated() =>
      $pb.PbList<ListEventsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListEventsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListEventsResponse>(create);
  static ListEventsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TuringEvent> get events => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get latestSequence => $_getI64(1);
  @$pb.TagNumber(2)
  set latestSequence($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLatestSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearLatestSequence() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get resyncRequired => $_getBF(2);
  @$pb.TagNumber(3)
  set resyncRequired($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasResyncRequired() => $_has(2);
  @$pb.TagNumber(3)
  void clearResyncRequired() => $_clearField(3);
}

class SubscribeSessionEventsRequest extends $pb.GeneratedMessage {
  factory SubscribeSessionEventsRequest({
    $core.String? sessionId,
    $fixnum.Int64? afterSequence,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (afterSequence != null) {
      $result.afterSequence = afterSequence;
    }
    return $result;
  }
  SubscribeSessionEventsRequest._() : super();
  factory SubscribeSessionEventsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SubscribeSessionEventsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeSessionEventsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aInt64(2, _omitFieldNames ? '' : 'afterSequence')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeSessionEventsRequest clone() =>
      SubscribeSessionEventsRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeSessionEventsRequest copyWith(
          void Function(SubscribeSessionEventsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SubscribeSessionEventsRequest))
          as SubscribeSessionEventsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeSessionEventsRequest create() =>
      SubscribeSessionEventsRequest._();
  SubscribeSessionEventsRequest createEmptyInstance() => create();
  static $pb.PbList<SubscribeSessionEventsRequest> createRepeated() =>
      $pb.PbList<SubscribeSessionEventsRequest>();
  @$core.pragma('dart2js:noInline')
  static SubscribeSessionEventsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeSessionEventsRequest>(create);
  static SubscribeSessionEventsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get afterSequence => $_getI64(1);
  @$pb.TagNumber(2)
  set afterSequence($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasAfterSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearAfterSequence() => $_clearField(2);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
