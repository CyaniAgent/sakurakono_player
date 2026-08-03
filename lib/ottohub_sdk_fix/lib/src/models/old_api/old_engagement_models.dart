import 'package:json_annotation/json_annotation.dart';

part 'old_engagement_models.g.dart';

/// 老版 API 点赞切换响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class OldLikeToggleResponse {
  final int ifLike;
  final int likeCount;

  const OldLikeToggleResponse({
    required this.ifLike,
    required this.likeCount,
  });

  factory OldLikeToggleResponse.fromJson(Map<String, dynamic> json) =>
      _$OldLikeToggleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OldLikeToggleResponseToJson(this);
}

/// 老版 API 收藏切换响应。
///
/// 注意：收藏数对应字段名为 `like_favorite`（服务端命名）。
@JsonSerializable(fieldRename: FieldRename.snake)
class OldFavoriteToggleResponse {
  final int ifFavorite;

  @JsonKey(name: 'like_favorite')
  final int favoriteCount;

  const OldFavoriteToggleResponse({
    required this.ifFavorite,
    required this.favoriteCount,
  });

  factory OldFavoriteToggleResponse.fromJson(Map<String, dynamic> json) =>
      _$OldFavoriteToggleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OldFavoriteToggleResponseToJson(this);
}
