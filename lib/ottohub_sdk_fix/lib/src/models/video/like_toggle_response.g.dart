// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_toggle_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LikeToggleResponse _$LikeToggleResponseFromJson(Map<String, dynamic> json) =>
    LikeToggleResponse(
      ifLike: (json['if_like'] as num).toInt(),
      likeCount: (json['like_count'] as num).toInt(),
    );

Map<String, dynamic> _$LikeToggleResponseToJson(LikeToggleResponse instance) =>
    <String, dynamic>{
      'if_like': instance.ifLike,
      'like_count': instance.likeCount,
    };
