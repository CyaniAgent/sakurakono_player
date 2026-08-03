// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'following_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowingUser _$FollowingUserFromJson(Map<String, dynamic> json) =>
    FollowingUser(
      uid: (json['uid'] as num).toInt(),
      username: json['username'] as String,
      intro: json['intro'] as String?,
      avatarUrl: json['avatar_url'] as String,
      followStatus: (json['follow_status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FollowingUserToJson(FollowingUser instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'intro': instance.intro,
      'avatar_url': instance.avatarUrl,
      'follow_status': instance.followStatus,
    };
