import 'package:json_annotation/json_annotation.dart';
import '../video/channel_detail.dart';

part 'old_blog_models.g.dart';

/// 博客摘要信息。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class BlogSummary {
  final int bid;
  final int uid;
  final String title;
  final String? content;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final String? avatarUrl;
  final int? commentCount;
  final List<String>? thumbnails;

  const BlogSummary({
    required this.bid,
    required this.uid,
    required this.title,
    this.content,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    this.avatarUrl,
    this.commentCount,
    this.thumbnails,
  });

  factory BlogSummary.fromJson(Map<String, dynamic> json) =>
      _$BlogSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$BlogSummaryToJson(this);
}

/// 博客详细信息。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class BlogDetail {
  final int bid;
  final int uid;
  final String title;
  final String content;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final String? avatarUrl;
  final String? username;
  final int? commentCount;
  final int? ifLike;
  final int? ifFavorite;
  final List<String>? thumbnails;
  final int? channelId;
  final ChannelDetail? channelDetail;

  const BlogDetail({
    required this.bid,
    required this.uid,
    required this.title,
    required this.content,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    this.avatarUrl,
    this.username,
    this.commentCount,
    this.ifLike,
    this.ifFavorite,
    this.thumbnails,
    this.channelId,
    this.channelDetail,
  });

  factory BlogDetail.fromJson(Map<String, dynamic> json) =>
      _$BlogDetailFromJson(json);

  Map<String, dynamic> toJson() => _$BlogDetailToJson(this);
}

/// 博客审核条目。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class BlogAuditItem {
  final int bid;
  final String? title;
  final String? content;

  const BlogAuditItem({
    required this.bid,
    this.title,
    this.content,
  });

  factory BlogAuditItem.fromJson(Map<String, dynamic> json) =>
      _$BlogAuditItemFromJson(json);

  Map<String, dynamic> toJson() => _$BlogAuditItemToJson(this);
}
