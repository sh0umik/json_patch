import 'package:json_annotation/json_annotation.dart';
part 'json_patch.g.dart';

@JsonSerializable()
class JsonPatchOperation {
  String op;
  String path;
  dynamic value;
  JsonPatchOperation({this.op, this.path, this.value});

  factory JsonPatchOperation.fromJson(Map<String, dynamic> json) =>
      _$JsonPatchOperationFromJson(json);
  Map<String, dynamic> toJson() => _$JsonPatchOperationToJson(this);
}