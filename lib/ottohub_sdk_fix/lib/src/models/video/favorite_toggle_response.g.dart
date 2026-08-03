// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_toggle_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteToggleResponse _$FavoriteToggleResponseFromJson(
  Map<String, dynamic> json,
) => FavoriteToggleResponse(
  ifFavorite: (json['if_favorite'] as num).toInt(),
  favoriteCount: (json['favorite_count'] as num).toInt(),
);

Map<String, dynamic> _$FavoriteToggleResponseToJson(
  FavoriteToggleResponse instance,
) => <String, dynamic>{
  'if_favorite': instance.ifFavorite,
  'favorite_count': instance.favoriteCount,
};
