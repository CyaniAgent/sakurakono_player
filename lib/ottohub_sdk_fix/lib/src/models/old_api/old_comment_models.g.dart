// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'old_comment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogComment _$BlogCommentFromJson(Map<String, dynamic> json) => BlogComment(
  bcid: (json['bcid'] as num).toInt(),
  parentBcid: (json['parent_bcid'] as num).toInt(),
  uid: (json['uid'] as num).toInt(),
  content: json['content'] as String,
  time: json['time'] as String,
  childCommentNum: (json['child_comment_num'] as num?)?.toInt(),
  ifMyComment: (json['if_my_comment'] as num?)?.toInt(),
  username: json['username'] as String?,
  honour: json['honour'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$BlogCommentToJson(BlogComment instance) =>
    <String, dynamic>{
      'bcid': instance.bcid,
      'parent_bcid': instance.parentBcid,
      'uid': instance.uid,
      'content': instance.content,
      'time': instance.time,
      'child_comment_num': ?instance.childCommentNum,
      'if_my_comment': ?instance.ifMyComment,
      'username': ?instance.username,
      'honour': ?instance.honour,
      'avatar_url': ?instance.avatarUrl,
    };

VideoComment _$VideoCommentFromJson(Map<String, dynamic> json) => VideoComment(
  vcid: (json['vcid'] as num).toInt(),
  parentVcid: (json['parent_vcid'] as num).toInt(),
  uid: (json['uid'] as num).toInt(),
  content: json['content'] as String,
  time: json['time'] as String,
  childCommentNum: (json['child_comment_num'] as num?)?.toInt(),
  ifMyComment: (json['if_my_comment'] as num?)?.toInt(),
  username: json['username'] as String?,
  honour: json['honour'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$VideoCommentToJson(VideoComment instance) =>
    <String, dynamic>{
      'vcid': instance.vcid,
      'parent_vcid': instance.parentVcid,
      'uid': instance.uid,
      'content': instance.content,
      'time': instance.time,
      'child_comment_num': ?instance.childCommentNum,
      'if_my_comment': ?instance.ifMyComment,
      'username': ?instance.username,
      'honour': ?instance.honour,
      'avatar_url': ?instance.avatarUrl,
    };

CommentResult _$CommentResultFromJson(Map<String, dynamic> json) =>
    CommentResult(
      ifGetExperience: (json['if_get_experience'] as num?)?.toInt(),
      ifWarn: (json['if_warn'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CommentResultToJson(CommentResult instance) =>
    <String, dynamic>{
      'if_get_experience': ?instance.ifGetExperience,
      'if_warn': ?instance.ifWarn,
    };

AuditBlogComment _$AuditBlogCommentFromJson(Map<String, dynamic> json) =>
    AuditBlogComment(
      bcid: (json['bcid'] as num).toInt(),
      parentBcid: (json['parent_bcid'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
      content: json['content'] as String,
      time: json['time'] as String,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$AuditBlogCommentToJson(AuditBlogComment instance) =>
    <String, dynamic>{
      'bcid': instance.bcid,
      'parent_bcid': instance.parentBcid,
      'uid': instance.uid,
      'content': instance.content,
      'time': instance.time,
      'username': ?instance.username,
    };

AuditVideoComment _$AuditVideoCommentFromJson(Map<String, dynamic> json) =>
    AuditVideoComment(
      vcid: (json['vcid'] as num).toInt(),
      parentVcid: (json['parent_vcid'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
      content: json['content'] as String,
      time: json['time'] as String,
      childCommentNum: (json['child_comment_num'] as num?)?.toInt(),
      ifMyComment: (json['if_my_comment'] as num?)?.toInt(),
      username: json['username'] as String?,
      honour: json['honour'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$AuditVideoCommentToJson(AuditVideoComment instance) =>
    <String, dynamic>{
      'vcid': instance.vcid,
      'parent_vcid': instance.parentVcid,
      'uid': instance.uid,
      'content': instance.content,
      'time': instance.time,
      'child_comment_num': ?instance.childCommentNum,
      'if_my_comment': ?instance.ifMyComment,
      'username': ?instance.username,
      'honour': ?instance.honour,
      'avatar_url': ?instance.avatarUrl,
    };
