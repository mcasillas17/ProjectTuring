//
//  Generated code. Do not modify.
//  source: turing/v1/approvals.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ApprovalStatus extends $pb.ProtobufEnum {
  static const ApprovalStatus APPROVAL_STATUS_UNSPECIFIED =
      ApprovalStatus._(0, _omitEnumNames ? '' : 'APPROVAL_STATUS_UNSPECIFIED');
  static const ApprovalStatus APPROVAL_STATUS_PENDING =
      ApprovalStatus._(1, _omitEnumNames ? '' : 'APPROVAL_STATUS_PENDING');
  static const ApprovalStatus APPROVAL_STATUS_APPROVED =
      ApprovalStatus._(2, _omitEnumNames ? '' : 'APPROVAL_STATUS_APPROVED');
  static const ApprovalStatus APPROVAL_STATUS_DENIED =
      ApprovalStatus._(3, _omitEnumNames ? '' : 'APPROVAL_STATUS_DENIED');
  static const ApprovalStatus APPROVAL_STATUS_EXPIRED =
      ApprovalStatus._(4, _omitEnumNames ? '' : 'APPROVAL_STATUS_EXPIRED');
  static const ApprovalStatus APPROVAL_STATUS_CONSUMED =
      ApprovalStatus._(5, _omitEnumNames ? '' : 'APPROVAL_STATUS_CONSUMED');

  static const $core.List<ApprovalStatus> values = <ApprovalStatus>[
    APPROVAL_STATUS_UNSPECIFIED,
    APPROVAL_STATUS_PENDING,
    APPROVAL_STATUS_APPROVED,
    APPROVAL_STATUS_DENIED,
    APPROVAL_STATUS_EXPIRED,
    APPROVAL_STATUS_CONSUMED,
  ];

  static final $core.List<ApprovalStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ApprovalStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ApprovalStatus._(super.v, super.n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
