import 'package:json_annotation/json_annotation.dart';

part 'moderation_item.g.dart';

/// 待审核视频。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ModerationVideo {
  final int vid;
  final int uid;
  final String title;
  final String? intro;
  final String? tag;
  final String? coverUrl;
  final String? videoUrl;
  final String? reportReason;

  const ModerationVideo({
    required this.vid,
    required this.uid,
    required this.title,
    this.intro,
    this.tag,
    this.coverUrl,
    this.videoUrl,
    this.reportReason,
  });

  factory ModerationVideo.fromJson(Map<String, dynamic> json) =>
      _$ModerationVideoFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationVideoToJson(this);
}

/// 待审核博客。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ModerationBlog {
  final int bid;
  final String? title;
  final String? content;
  final String? reportReason;

  const ModerationBlog({
    required this.bid,
    this.title,
    this.content,
    this.reportReason,
  });

  factory ModerationBlog.fromJson(Map<String, dynamic> json) =>
      _$ModerationBlogFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationBlogToJson(this);
}

/// 待审核头像。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ModerationAvatar {
  final int uid;
  final String username;
  final String avatarUrl;
  final String? reportReason;

  const ModerationAvatar({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    this.reportReason,
  });

  factory ModerationAvatar.fromJson(Map<String, dynamic> json) =>
      _$ModerationAvatarFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationAvatarToJson(this);
}

/// 待审核封面。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ModerationCover {
  final int uid;
  final String username;
  final String coverUrl;
  final String? reportReason;

  const ModerationCover({
    required this.uid,
    required this.username,
    required this.coverUrl,
    this.reportReason,
  });

  factory ModerationCover.fromJson(Map<String, dynamic> json) =>
      _$ModerationCoverFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationCoverToJson(this);
}

/// 待审核弹幕。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ModerationDanmaku {
  final int danmakuId;
  final String text;
  final double time;
  final int mode;
  final String color;
  final int fontSize;
  final String render;
  final String? reportReason;

  const ModerationDanmaku({
    required this.danmakuId,
    required this.text,
    required this.time,
    required this.mode,
    required this.color,
    required this.fontSize,
    required this.render,
    this.reportReason,
  });

  factory ModerationDanmaku.fromJson(Map<String, dynamic> json) =>
      _$ModerationDanmakuFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationDanmakuToJson(this);
}

/// 待审核视频评论。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ModerationVideoComment {
  final int vcid;
  final int parentVcid;
  final int vid;
  final int uid;
  final String content;
  final String time;
  final String username;
  final String? reportReason;

  const ModerationVideoComment({
    required this.vcid,
    required this.parentVcid,
    required this.vid,
    required this.uid,
    required this.content,
    required this.time,
    required this.username,
    this.reportReason,
  });

  factory ModerationVideoComment.fromJson(Map<String, dynamic> json) =>
      _$ModerationVideoCommentFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationVideoCommentToJson(this);
}

/// 待审核博客评论。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ModerationBlogComment {
  final int bcid;
  final int parentBcid;
  final int bid;
  final int uid;
  final String content;
  final String time;
  final String username;
  final String? reportReason;

  const ModerationBlogComment({
    required this.bcid,
    required this.parentBcid,
    required this.bid,
    required this.uid,
    required this.content,
    required this.time,
    required this.username,
    this.reportReason,
  });

  factory ModerationBlogComment.fromJson(Map<String, dynamic> json) =>
      _$ModerationBlogCommentFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationBlogCommentToJson(this);
}
