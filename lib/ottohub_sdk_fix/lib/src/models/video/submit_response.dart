import 'package:json_annotation/json_annotation.dart';

part 'submit_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
/// 视频提交/编辑响应。
class SubmitResponse {
  /// 视频 ID。
  final int vid;

  /// 是否获得经验值，`1`=获得，`0`=未获得。
  final int ifAddExperience;

  const SubmitResponse({
    required this.vid,
    required this.ifAddExperience,
  });

  factory SubmitResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitResponseToJson(this);
}
