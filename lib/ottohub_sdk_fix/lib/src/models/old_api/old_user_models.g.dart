// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'old_user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSummary _$UserSummaryFromJson(Map<String, dynamic> json) => UserSummary(
  uid: (json['uid'] as num).toInt(),
  username: json['username'] as String,
  intro: json['intro'] as String?,
  time: json['time'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$UserSummaryToJson(UserSummary instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'intro': ?instance.intro,
      'time': ?instance.time,
      'avatar_url': ?instance.avatarUrl,
    };

UserDetail _$UserDetailFromJson(Map<String, dynamic> json) => UserDetail(
  uid: (json['uid'] as num).toInt(),
  username: json['username'] as String,
  intro: json['intro'] as String?,
  time: json['time'] as String?,
  sex: json['sex'] as String?,
  honour: json['honour'] as String?,
  experience: (json['experience'] as num?)?.toInt(),
  avatarUrl: json['avatar_url'] as String?,
  coverUrl: json['cover_url'] as String?,
  videoNum: (json['video_num'] as num?)?.toInt(),
  blogNum: (json['blog_num'] as num?)?.toInt(),
  mediaNum: (json['media_num'] as num?)?.toInt(),
  followingsCount: (json['followings_count'] as num?)?.toInt(),
  fansCount: (json['fans_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserDetailToJson(UserDetail instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'intro': ?instance.intro,
      'time': ?instance.time,
      'sex': ?instance.sex,
      'honour': ?instance.honour,
      'experience': ?instance.experience,
      'avatar_url': ?instance.avatarUrl,
      'cover_url': ?instance.coverUrl,
      'video_num': ?instance.videoNum,
      'blog_num': ?instance.blogNum,
      'media_num': ?instance.mediaNum,
      'followings_count': ?instance.followingsCount,
      'fans_count': ?instance.fansCount,
    };
