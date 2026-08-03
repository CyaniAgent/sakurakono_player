// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_toggle_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowToggleResponse _$FollowToggleResponseFromJson(
  Map<String, dynamic> json,
) => FollowToggleResponse(
  newFansCount: (json['new_fans_count'] as num).toInt(),
  followStatus: (json['follow_status'] as num).toInt(),
);

Map<String, dynamic> _$FollowToggleResponseToJson(
  FollowToggleResponse instance,
) => <String, dynamic>{
  'new_fans_count': instance.newFansCount,
  'follow_status': instance.followStatus,
};
