//
//  Generated code. Do not modify.
//  source: turing/v1/mcp.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use mcpRequestDescriptor instead')
const McpRequest$json = {
  '1': 'McpRequest',
  '2': [
    {'1': 'server_name', '3': 1, '4': 1, '5': 9, '10': 'serverName'},
    {'1': 'method', '3': 2, '4': 1, '5': 9, '10': 'method'},
    {
      '1': 'params',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'params'
    },
  ],
};

/// Descriptor for `McpRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mcpRequestDescriptor = $convert.base64Decode(
    'CgpNY3BSZXF1ZXN0Eh8KC3NlcnZlcl9uYW1lGAEgASgJUgpzZXJ2ZXJOYW1lEhYKBm1ldGhvZB'
    'gCIAEoCVIGbWV0aG9kEi8KBnBhcmFtcxgDIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RS'
    'BnBhcmFtcw==');

@$core.Deprecated('Use mcpResultDescriptor instead')
const McpResult$json = {
  '1': 'McpResult',
  '2': [
    {
      '1': 'result',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'result'
    },
  ],
};

/// Descriptor for `McpResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mcpResultDescriptor = $convert.base64Decode(
    'CglNY3BSZXN1bHQSLwoGcmVzdWx0GAEgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIGcm'
    'VzdWx0');
