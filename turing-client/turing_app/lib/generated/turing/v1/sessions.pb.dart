//
//  Generated code. Do not modify.
//  source: turing/v1/sessions.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/timestamp.pb.dart' as $8;
import 'common.pb.dart' as $7;
import 'common.pbenum.dart' as $7;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Session extends $pb.GeneratedMessage {
  factory Session({
    $core.String? sessionId,
    $core.String? title,
    $core.String? status,
    $8.Timestamp? createdAt,
    $8.Timestamp? updatedAt,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (title != null) {
      $result.title = title;
    }
    if (status != null) {
      $result.status = status;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    return $result;
  }
  Session._() : super();
  factory Session.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Session.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Session',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..aOM<$8.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $8.Timestamp.create)
    ..aOM<$8.Timestamp>(5, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $8.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Session clone() => Session()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Session copyWith(void Function(Session) updates) =>
      super.copyWith((message) => updates(message as Session)) as Session;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Session create() => Session._();
  Session createEmptyInstance() => create();
  static $pb.PbList<Session> createRepeated() => $pb.PbList<Session>();
  @$core.pragma('dart2js:noInline')
  static Session getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Session>(create);
  static Session? _defaultInstance;

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
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

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

  @$pb.TagNumber(4)
  $8.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($8.Timestamp v) {
    $_setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $8.Timestamp ensureCreatedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $8.Timestamp get updatedAt => $_getN(4);
  @$pb.TagNumber(5)
  set updatedAt($8.Timestamp v) {
    $_setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $8.Timestamp ensureUpdatedAt() => $_ensure(4);
}

class CreateSessionRequest extends $pb.GeneratedMessage {
  factory CreateSessionRequest({
    $core.String? title,
  }) {
    final $result = create();
    if (title != null) {
      $result.title = title;
    }
    return $result;
  }
  CreateSessionRequest._() : super();
  factory CreateSessionRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CreateSessionRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSessionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionRequest clone() =>
      CreateSessionRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionRequest copyWith(void Function(CreateSessionRequest) updates) =>
      super.copyWith((message) => updates(message as CreateSessionRequest))
          as CreateSessionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSessionRequest create() => CreateSessionRequest._();
  CreateSessionRequest createEmptyInstance() => create();
  static $pb.PbList<CreateSessionRequest> createRepeated() =>
      $pb.PbList<CreateSessionRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateSessionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSessionRequest>(create);
  static CreateSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);
}

class CreateSessionResponse extends $pb.GeneratedMessage {
  factory CreateSessionResponse({
    $core.String? sessionId,
    $8.Timestamp? createdAt,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  CreateSessionResponse._() : super();
  factory CreateSessionResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CreateSessionResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSessionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOM<$8.Timestamp>(2, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $8.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionResponse clone() =>
      CreateSessionResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionResponse copyWith(
          void Function(CreateSessionResponse) updates) =>
      super.copyWith((message) => updates(message as CreateSessionResponse))
          as CreateSessionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSessionResponse create() => CreateSessionResponse._();
  CreateSessionResponse createEmptyInstance() => create();
  static $pb.PbList<CreateSessionResponse> createRepeated() =>
      $pb.PbList<CreateSessionResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateSessionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSessionResponse>(create);
  static CreateSessionResponse? _defaultInstance;

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
  $8.Timestamp get createdAt => $_getN(1);
  @$pb.TagNumber(2)
  set createdAt($8.Timestamp v) {
    $_setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCreatedAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreatedAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $8.Timestamp ensureCreatedAt() => $_ensure(1);
}

class ListSessionsRequest extends $pb.GeneratedMessage {
  factory ListSessionsRequest({
    $7.PageRequest? page,
  }) {
    final $result = create();
    if (page != null) {
      $result.page = page;
    }
    return $result;
  }
  ListSessionsRequest._() : super();
  factory ListSessionsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListSessionsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSessionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOM<$7.PageRequest>(1, _omitFieldNames ? '' : 'page',
        subBuilder: $7.PageRequest.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsRequest clone() => ListSessionsRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsRequest copyWith(void Function(ListSessionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListSessionsRequest))
          as ListSessionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSessionsRequest create() => ListSessionsRequest._();
  ListSessionsRequest createEmptyInstance() => create();
  static $pb.PbList<ListSessionsRequest> createRepeated() =>
      $pb.PbList<ListSessionsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListSessionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSessionsRequest>(create);
  static ListSessionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $7.PageRequest get page => $_getN(0);
  @$pb.TagNumber(1)
  set page($7.PageRequest v) {
    $_setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPage() => $_clearField(1);
  @$pb.TagNumber(1)
  $7.PageRequest ensurePage() => $_ensure(0);
}

class ListSessionsResponse extends $pb.GeneratedMessage {
  factory ListSessionsResponse({
    $core.Iterable<Session>? sessions,
    $7.PageResponse? page,
  }) {
    final $result = create();
    if (sessions != null) {
      $result.sessions.addAll(sessions);
    }
    if (page != null) {
      $result.page = page;
    }
    return $result;
  }
  ListSessionsResponse._() : super();
  factory ListSessionsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListSessionsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSessionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..pc<Session>(1, _omitFieldNames ? '' : 'sessions', $pb.PbFieldType.PM,
        subBuilder: Session.create)
    ..aOM<$7.PageResponse>(2, _omitFieldNames ? '' : 'page',
        subBuilder: $7.PageResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsResponse clone() =>
      ListSessionsResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsResponse copyWith(void Function(ListSessionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListSessionsResponse))
          as ListSessionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSessionsResponse create() => ListSessionsResponse._();
  ListSessionsResponse createEmptyInstance() => create();
  static $pb.PbList<ListSessionsResponse> createRepeated() =>
      $pb.PbList<ListSessionsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSessionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSessionsResponse>(create);
  static ListSessionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Session> get sessions => $_getList(0);

  @$pb.TagNumber(2)
  $7.PageResponse get page => $_getN(1);
  @$pb.TagNumber(2)
  set page($7.PageResponse v) {
    $_setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);
  @$pb.TagNumber(2)
  $7.PageResponse ensurePage() => $_ensure(1);
}

class GetSessionRequest extends $pb.GeneratedMessage {
  factory GetSessionRequest({
    $core.String? sessionId,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    return $result;
  }
  GetSessionRequest._() : super();
  factory GetSessionRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetSessionRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSessionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionRequest clone() => GetSessionRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionRequest copyWith(void Function(GetSessionRequest) updates) =>
      super.copyWith((message) => updates(message as GetSessionRequest))
          as GetSessionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSessionRequest create() => GetSessionRequest._();
  GetSessionRequest createEmptyInstance() => create();
  static $pb.PbList<GetSessionRequest> createRepeated() =>
      $pb.PbList<GetSessionRequest>();
  @$core.pragma('dart2js:noInline')
  static GetSessionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSessionRequest>(create);
  static GetSessionRequest? _defaultInstance;

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
}

class ListMessagesRequest extends $pb.GeneratedMessage {
  factory ListMessagesRequest({
    $core.String? sessionId,
    $core.int? limit,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  ListMessagesRequest._() : super();
  factory ListMessagesRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListMessagesRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMessagesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMessagesRequest clone() => ListMessagesRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMessagesRequest copyWith(void Function(ListMessagesRequest) updates) =>
      super.copyWith((message) => updates(message as ListMessagesRequest))
          as ListMessagesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMessagesRequest create() => ListMessagesRequest._();
  ListMessagesRequest createEmptyInstance() => create();
  static $pb.PbList<ListMessagesRequest> createRepeated() =>
      $pb.PbList<ListMessagesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMessagesRequest>(create);
  static ListMessagesRequest? _defaultInstance;

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
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);
}

class ListMessagesResponse extends $pb.GeneratedMessage {
  factory ListMessagesResponse({
    $core.Iterable<$7.Message>? messages,
  }) {
    final $result = create();
    if (messages != null) {
      $result.messages.addAll(messages);
    }
    return $result;
  }
  ListMessagesResponse._() : super();
  factory ListMessagesResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListMessagesResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMessagesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..pc<$7.Message>(1, _omitFieldNames ? '' : 'messages', $pb.PbFieldType.PM,
        subBuilder: $7.Message.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMessagesResponse clone() =>
      ListMessagesResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMessagesResponse copyWith(void Function(ListMessagesResponse) updates) =>
      super.copyWith((message) => updates(message as ListMessagesResponse))
          as ListMessagesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMessagesResponse create() => ListMessagesResponse._();
  ListMessagesResponse createEmptyInstance() => create();
  static $pb.PbList<ListMessagesResponse> createRepeated() =>
      $pb.PbList<ListMessagesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMessagesResponse>(create);
  static ListMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$7.Message> get messages => $_getList(0);
}

class GetConfigRequest extends $pb.GeneratedMessage {
  factory GetConfigRequest() => create();
  GetConfigRequest._() : super();
  factory GetConfigRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetConfigRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConfigRequest clone() => GetConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConfigRequest copyWith(void Function(GetConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetConfigRequest))
          as GetConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConfigRequest create() => GetConfigRequest._();
  GetConfigRequest createEmptyInstance() => create();
  static $pb.PbList<GetConfigRequest> createRepeated() =>
      $pb.PbList<GetConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static GetConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConfigRequest>(create);
  static GetConfigRequest? _defaultInstance;
}

class GetConfigResponse extends $pb.GeneratedMessage {
  factory GetConfigResponse({
    $core.Iterable<$7.ProviderConfig>? providers,
    $core.bool? approvalsEnabled,
    $core.bool? filesMcpEnabled,
  }) {
    final $result = create();
    if (providers != null) {
      $result.providers.addAll(providers);
    }
    if (approvalsEnabled != null) {
      $result.approvalsEnabled = approvalsEnabled;
    }
    if (filesMcpEnabled != null) {
      $result.filesMcpEnabled = filesMcpEnabled;
    }
    return $result;
  }
  GetConfigResponse._() : super();
  factory GetConfigResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetConfigResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..pc<$7.ProviderConfig>(
        1, _omitFieldNames ? '' : 'providers', $pb.PbFieldType.PM,
        subBuilder: $7.ProviderConfig.create)
    ..aOB(2, _omitFieldNames ? '' : 'approvalsEnabled')
    ..aOB(3, _omitFieldNames ? '' : 'filesMcpEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConfigResponse clone() => GetConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConfigResponse copyWith(void Function(GetConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetConfigResponse))
          as GetConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConfigResponse create() => GetConfigResponse._();
  GetConfigResponse createEmptyInstance() => create();
  static $pb.PbList<GetConfigResponse> createRepeated() =>
      $pb.PbList<GetConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static GetConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConfigResponse>(create);
  static GetConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$7.ProviderConfig> get providers => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get approvalsEnabled => $_getBF(1);
  @$pb.TagNumber(2)
  set approvalsEnabled($core.bool v) {
    $_setBool(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasApprovalsEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearApprovalsEnabled() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get filesMcpEnabled => $_getBF(2);
  @$pb.TagNumber(3)
  set filesMcpEnabled($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasFilesMcpEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilesMcpEnabled() => $_clearField(3);
}

class ListAgentsRequest extends $pb.GeneratedMessage {
  factory ListAgentsRequest() => create();
  ListAgentsRequest._() : super();
  factory ListAgentsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListAgentsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAgentsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAgentsRequest clone() => ListAgentsRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAgentsRequest copyWith(void Function(ListAgentsRequest) updates) =>
      super.copyWith((message) => updates(message as ListAgentsRequest))
          as ListAgentsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAgentsRequest create() => ListAgentsRequest._();
  ListAgentsRequest createEmptyInstance() => create();
  static $pb.PbList<ListAgentsRequest> createRepeated() =>
      $pb.PbList<ListAgentsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListAgentsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAgentsRequest>(create);
  static ListAgentsRequest? _defaultInstance;
}

class ListAgentsResponse extends $pb.GeneratedMessage {
  factory ListAgentsResponse({
    $core.Iterable<$7.AgentDescriptor>? agents,
  }) {
    final $result = create();
    if (agents != null) {
      $result.agents.addAll(agents);
    }
    return $result;
  }
  ListAgentsResponse._() : super();
  factory ListAgentsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListAgentsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAgentsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..pc<$7.AgentDescriptor>(
        1, _omitFieldNames ? '' : 'agents', $pb.PbFieldType.PM,
        subBuilder: $7.AgentDescriptor.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAgentsResponse clone() => ListAgentsResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAgentsResponse copyWith(void Function(ListAgentsResponse) updates) =>
      super.copyWith((message) => updates(message as ListAgentsResponse))
          as ListAgentsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAgentsResponse create() => ListAgentsResponse._();
  ListAgentsResponse createEmptyInstance() => create();
  static $pb.PbList<ListAgentsResponse> createRepeated() =>
      $pb.PbList<ListAgentsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListAgentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAgentsResponse>(create);
  static ListAgentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$7.AgentDescriptor> get agents => $_getList(0);
}

class ToolDescriptor extends $pb.GeneratedMessage {
  factory ToolDescriptor({
    $core.String? serverName,
    $core.String? toolName,
    $7.ToolPolicy? policy,
  }) {
    final $result = create();
    if (serverName != null) {
      $result.serverName = serverName;
    }
    if (toolName != null) {
      $result.toolName = toolName;
    }
    if (policy != null) {
      $result.policy = policy;
    }
    return $result;
  }
  ToolDescriptor._() : super();
  factory ToolDescriptor.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ToolDescriptor.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ToolDescriptor',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'serverName')
    ..aOS(2, _omitFieldNames ? '' : 'toolName')
    ..e<$7.ToolPolicy>(3, _omitFieldNames ? '' : 'policy', $pb.PbFieldType.OE,
        defaultOrMaker: $7.ToolPolicy.TOOL_POLICY_UNSPECIFIED,
        valueOf: $7.ToolPolicy.valueOf,
        enumValues: $7.ToolPolicy.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToolDescriptor clone() => ToolDescriptor()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToolDescriptor copyWith(void Function(ToolDescriptor) updates) =>
      super.copyWith((message) => updates(message as ToolDescriptor))
          as ToolDescriptor;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ToolDescriptor create() => ToolDescriptor._();
  ToolDescriptor createEmptyInstance() => create();
  static $pb.PbList<ToolDescriptor> createRepeated() =>
      $pb.PbList<ToolDescriptor>();
  @$core.pragma('dart2js:noInline')
  static ToolDescriptor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ToolDescriptor>(create);
  static ToolDescriptor? _defaultInstance;

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
  $core.String get toolName => $_getSZ(1);
  @$pb.TagNumber(2)
  set toolName($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasToolName() => $_has(1);
  @$pb.TagNumber(2)
  void clearToolName() => $_clearField(2);

  @$pb.TagNumber(3)
  $7.ToolPolicy get policy => $_getN(2);
  @$pb.TagNumber(3)
  set policy($7.ToolPolicy v) {
    $_setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasPolicy() => $_has(2);
  @$pb.TagNumber(3)
  void clearPolicy() => $_clearField(3);
}

class ListToolsRequest extends $pb.GeneratedMessage {
  factory ListToolsRequest() => create();
  ListToolsRequest._() : super();
  factory ListToolsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListToolsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListToolsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListToolsRequest clone() => ListToolsRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListToolsRequest copyWith(void Function(ListToolsRequest) updates) =>
      super.copyWith((message) => updates(message as ListToolsRequest))
          as ListToolsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListToolsRequest create() => ListToolsRequest._();
  ListToolsRequest createEmptyInstance() => create();
  static $pb.PbList<ListToolsRequest> createRepeated() =>
      $pb.PbList<ListToolsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListToolsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListToolsRequest>(create);
  static ListToolsRequest? _defaultInstance;
}

class ListToolsResponse extends $pb.GeneratedMessage {
  factory ListToolsResponse({
    $core.Iterable<ToolDescriptor>? tools,
  }) {
    final $result = create();
    if (tools != null) {
      $result.tools.addAll(tools);
    }
    return $result;
  }
  ListToolsResponse._() : super();
  factory ListToolsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListToolsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListToolsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turing.v1'),
      createEmptyInstance: create)
    ..pc<ToolDescriptor>(1, _omitFieldNames ? '' : 'tools', $pb.PbFieldType.PM,
        subBuilder: ToolDescriptor.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListToolsResponse clone() => ListToolsResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListToolsResponse copyWith(void Function(ListToolsResponse) updates) =>
      super.copyWith((message) => updates(message as ListToolsResponse))
          as ListToolsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListToolsResponse create() => ListToolsResponse._();
  ListToolsResponse createEmptyInstance() => create();
  static $pb.PbList<ListToolsResponse> createRepeated() =>
      $pb.PbList<ListToolsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListToolsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListToolsResponse>(create);
  static ListToolsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ToolDescriptor> get tools => $_getList(0);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
