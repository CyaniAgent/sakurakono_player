// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModerationVideo _$ModerationVideoFromJson(Map<String, dynamic> json) =>
    ModerationVideo(
      vid: (json['vid'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
      title: json['title'] as String,
      intro: json['intro'] as String?,
      tag: json['tag'] as String?,
      coverUrl: json['cover_url'] as String?,
      videoUrl: json['video_url'] as String?,
      reportReason: json['report_reason'] as String?,
    );

Map<String, dynamic> _$ModerationVideoToJson(ModerationVideo instance) =>
    <String, dynamic>{
      'vid': instance.vid,
      'uid': instance.uid,
      'title': instance.title,
      'intro': ?instance.intro,
      'tag': ?instance.tag,
      'cover_url': ?instance.coverUrl,
      'video_url': ?instance.videoUrl,
      'report_reason': ?instance.reportReason,
    };

ModerationBlog _$ModerationBlogFromJson(Map<String, dynamic> json) =>
    ModerationBlog(
      bid: (json['bid'] as num).toInt(),
      title: json['title'] as String?,
      content: json['content'] as String?,
      reportReason: json['report_reason'] as String?,
    );

Map<String, dynamic> _$ModerationBlogToJson(ModerationBlog instance) =>
    <String, dynamic>{
      'bid': instance.bid,
      'title': ?instance.title,
      'content': ?instance.content,
      'report_reason': ?instance.reportReason,
    };

ModerationAvatar _$ModerationAvatarFromJson(Map<String, dynamic> json) =>
    ModerationAvatar(
      uid: (json['uid'] as num).toInt(),
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String,
      reportReason: json['report_reason'] as String?,
    );

Map<String, dynamic> _$ModerationAvatarToJson(ModerationAvatar instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'report_reason': ?instance.reportReason,
    };

ModerationCover _$ModerationCoverFromJson(Map<String, dynamic> json) =>
    ModerationCover(
      uid: (json['uid'] as num).toInt(),
      username: json['username'] as String,
      coverUrl: json['cover_url'] as String,
      reportReason: json['report_reason'] as String?,
    );

Map<String, dynamic> _$ModerationCoverToJson(ModerationCover instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'cover_url': instance.coverUrl,
      'report_reason': ?instance.reportReason,
    };

ModerationDanmaku _$ModerationDanmakuFromJson(Map<String, dynamic> json) =>
    ModerationDanmaku(
      danmakuId: (json['danmaku_id'] as num).toInt(),
      text: json['text'] as String,
      time: (json['time'] as num).toDouble(),
      mode: (json['mode'] as num).toInt(),
      color: json['color'] as String,
      fontSize: (json['font_size'] as num).toInt(),
      render: json['render'] as String,
      reportReason: json['report_reason'] as String?,
    );

Map<String, dynamic> _$ModerationDanmakuToJson(ModerationDanmaku instance) =>
    <String, dynamic>{
      'danmaku_id': instance.danmakuId,
      'text': instance.text,
      'time': instance.time,
      'mode': instance.mode,
      'color': instance.color,
      'font_size': instance.fontSize,
      'render': instance.render,
      'report_reason': ?instance.reportReason,
    };

ModerationVideoComment _$ModerationVideoCommentFromJson(
  Map<String, dynamic> json,
) => ModerationVideoComment(
  vcid: (json['vcid'] as num).toInt(),
  parentVcid: (json['parent_vcid'] as num).toInt(),
  vid: (json['vid'] as num).toInt(),
  uid: (json['uid'] as num).toInt(),
  content: json['content'] as String,
  time: json['time'] as String,
  username: json['username'] as String,
  reportReason: json['report_reason'] as String?,
);

Map<String, dynamic> _$ModerationVideoCommentToJson(
  ModerationVideoComment instance,
) => <String, dynamic>{
  'vcid': instance.vcid,
  'parent_vcid': instance.parentVcid,
  'vid': instance.vid,
  'uid': instance.uid,
  'content': instance.content,
  'time': instance.time,
  'username': instance.username,
  'report_reason': ?instance.reportReason,
};

ModerationBlogComment _$ModerationBlogCommentFromJson(
  Map<String, dynamic> json,
) => ModerationBlogComment(
  bcid: (json['bcid'] as num).toInt(),
  parentBcid: (json['parent_bcid'] as num).toInt(),
  bid: (json['bid'] as num).toInt(),
  uid: (json['uid'] as num).toInt(),
  content: json['content'] as String,
  time: json['time'] as String,
  username: json['username'] as String,
  reportReason: json['report_reason'] as String?,
);

Map<String, dynamic> _$ModerationBlogCommentToJson(
  ModerationBlogComment instance,
) => <String, dynamic>{
  'bcid': instance.bcid,
  'parent_bcid': instance.parentBcid,
  'bid': instance.bid,
  'uid': instance.uid,
  'content': instance.content,
  'time': instance.time,
  'username': instance.username,
  'report_reason': ?instance.reportReason,
};
