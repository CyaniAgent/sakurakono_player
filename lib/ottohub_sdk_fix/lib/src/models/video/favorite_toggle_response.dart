import 'package:json_annotation/json_annotation.dart';

part 'favorite_toggle_response.g.dart';

/// 收藏切换响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class FavoriteToggleResponse {
  final int ifFavorite;
  final int favoriteCount;

  const FavoriteToggleResponse({
    required this.ifFavorite,
    required this.favoriteCount,
  });

  factory FavoriteToggleResponse.fromJson(Map<String, dynamic> json) =>
      _$FavoriteToggleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteToggleResponseToJson(this);
}
