import 'package:json_annotation/json_annotation.dart';

part 'old_creator_models.g.dart';

/// 内容提交结果。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class SubmitResult {
  final int? ifAddExperience;
  final int? ifWarn;

  const SubmitResult({this.ifAddExperience, this.ifWarn});

  factory SubmitResult.fromJson(Map<String, dynamic> json) =>
      _$SubmitResultFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitResultToJson(this);
}

/// 图片上传结果。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ImageUploadResult {
  final String imageUrl;

  const ImageUploadResult({required this.imageUrl});

  factory ImageUploadResult.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResultFromJson(json);

  Map<String, dynamic> toJson() => _$ImageUploadResultToJson(this);
}

/// 新 Token 响应（用于刷新或续期）。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class NewTokenResponse {
  final String newToken;

  const NewTokenResponse({required this.newToken});

  factory NewTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$NewTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NewTokenResponseToJson(this);
}
