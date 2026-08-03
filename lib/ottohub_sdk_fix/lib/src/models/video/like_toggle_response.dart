import 'package:json_annotation/json_annotation.dart';

part 'like_toggle_response.g.dart';

/// 点赞切换响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class LikeToggleResponse {
  final int ifLike;
  final int likeCount;

  const LikeToggleResponse({
    required this.ifLike,
    required this.likeCount,
  });

  factory LikeToggleResponse.fromJson(Map<String, dynamic> json) =>
      _$LikeToggleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LikeToggleResponseToJson(this);
}
