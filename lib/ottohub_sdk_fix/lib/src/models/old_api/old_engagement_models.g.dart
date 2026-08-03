// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'old_engagement_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OldLikeToggleResponse _$OldLikeToggleResponseFromJson(
  Map<String, dynamic> json,
) => OldLikeToggleResponse(
  ifLike: (json['if_like'] as num).toInt(),
  likeCount: (json['like_count'] as num).toInt(),
);

Map<String, dynamic> _$OldLikeToggleResponseToJson(
  OldLikeToggleResponse instance,
) => <String, dynamic>{
  'if_like': instance.ifLike,
  'like_count': instance.likeCount,
};

OldFavoriteToggleResponse _$OldFavoriteToggleResponseFromJson(
  Map<String, dynamic> json,
) => OldFavoriteToggleResponse(
  ifFavorite: (json['if_favorite'] as num).toInt(),
  favoriteCount: (json['like_favorite'] as num).toInt(),
);

Map<String, dynamic> _$OldFavoriteToggleResponseToJson(
  OldFavoriteToggleResponse instance,
) => <String, dynamic>{
  'if_favorite': instance.ifFavorite,
  'like_favorite': instance.favoriteCount,
};
