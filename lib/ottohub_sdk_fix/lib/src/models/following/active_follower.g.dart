// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_follower.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveFollower _$ActiveFollowerFromJson(Map<String, dynamic> json) =>
    ActiveFollower(
      uid: (json['uid'] as num).toInt(),
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String,
      latestActivityTime: json['latest_activity_time'] as String,
    );

Map<String, dynamic> _$ActiveFollowerToJson(ActiveFollower instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'latest_activity_time': instance.latestActivityTime,
    };
