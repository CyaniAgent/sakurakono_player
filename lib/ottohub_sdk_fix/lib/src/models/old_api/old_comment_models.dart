import 'package:json_annotation/json_annotation.dart';

part 'old_comment_models.g.dart';

/// 博客评论。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class BlogComment {
  final int bcid;
  final int parentBcid;
  final int uid;
  final String content;
  final String time;
  final int? childCommentNum;
  final int? ifMyComment;
  final String? username;
  final String? honour;
  final String? avatarUrl;

  const BlogComment({
    required this.bcid,
    required this.parentBcid,
    required this.uid,
    required this.content,
    required this.time,
    this.childCommentNum,
    this.ifMyComment,
    this.username,
    this.honour,
    this.avatarUrl,
  });

  factory BlogComment.fromJson(Map<String, dynamic> json) =>
      _$BlogCommentFromJson(json);

  Map<String, dynamic> toJson() => _$BlogCommentToJson(this);
}

/// 视频评论。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class VideoComment {
  final int vcid;
  final int parentVcid;
  final int uid;
  final String content;
  final String time;
  final int? childCommentNum;
  final int? ifMyComment;
  final String? username;
  final String? honour;
  final String? avatarUrl;

  const VideoComment({
    required this.vcid,
    required this.parentVcid,
    required this.uid,
    required this.content,
    required this.time,
    this.childCommentNum,
    this.ifMyComment,
    this.username,
    this.honour,
    this.avatarUrl,
  });

  factory VideoComment.fromJson(Map<String, dynamic> json) =>
      _$VideoCommentFromJson(json);

  Map<String, dynamic> toJson() => _$VideoCommentToJson(this);
}

/// 评论提交结果。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CommentResult {
  final int? ifGetExperience;
  final int? ifWarn;

  const CommentResult({this.ifGetExperience, this.ifWarn});

  factory CommentResult.fromJson(Map<String, dynamic> json) =>
      _$CommentResultFromJson(json);

  Map<String, dynamic> toJson() => _$CommentResultToJson(this);
}

/// 待审核博客评论。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class AuditBlogComment {
  final int bcid;
  final int parentBcid;
  final int uid;
  final String content;
  final String time;
  final String? username;

  const AuditBlogComment({
    required this.bcid,
    required this.parentBcid,
    required this.uid,
    required this.content,
    required this.time,
    this.username,
  });

  factory AuditBlogComment.fromJson(Map<String, dynamic> json) =>
      _$AuditBlogCommentFromJson(json);

  Map<String, dynamic> toJson() => _$AuditBlogCommentToJson(this);
}

/// 待审核视频评论。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class AuditVideoComment {
  final int vcid;
  final int parentVcid;
  final int uid;
  final String content;
  final String time;
  final int? childCommentNum;
  final int? ifMyComment;
  final String? username;
  final String? honour;
  final String? avatarUrl;

  const AuditVideoComment({
    required this.vcid,
    required this.parentVcid,
    required this.uid,
    required this.content,
    required this.time,
    this.childCommentNum,
    this.ifMyComment,
    this.username,
    this.honour,
    this.avatarUrl,
  });

  factory AuditVideoComment.fromJson(Map<String, dynamic> json) =>
      _$AuditVideoCommentFromJson(json);

  Map<String, dynamic> toJson() => _$AuditVideoCommentToJson(this);
}
