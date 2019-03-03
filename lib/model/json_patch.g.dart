// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonPatchOperation _$JsonPatchOperationFromJson(Map<String, dynamic> json) {
  return JsonPatchOperation(
      op: json['op'] as String,
      path: json['path'] as String,
      value: json['value']);
}

Map<String, dynamic> _$JsonPatchOperationToJson(JsonPatchOperation instance) =>
    <String, dynamic>{
      'op': instance.op,
      'path': instance.path,
      'value': instance.value
    };
