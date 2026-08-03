import 'package:json_annotation/json_annotation.dart';

part 'timeline_item.g.dart';

/// 关注动态时间线条目。
@JsonSerializable(fieldRename: FieldRename.snake)
class TimelineItem {
  /// 内容类型，如 `"video"`（视频）或 `"blog"`（博客）。
  final String contentType;

  /// 视频 ID（当 contentType 为 video 时存在）。
  final int? vid;

  /// 博客 ID（当 contentType 为 blog 时存在）。
  final int? bid;
  final int uid;
  final String title;
  final String? content;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final String? coverUrl;
  final String username;
  final String? avatarUrl;
  final List<String>? thumbnails;

  const TimelineItem({
    required this.contentType,
    this.vid,
    this.bid,
    required this.uid,
    required this.title,
    this.content,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    this.coverUrl,
    required this.username,
    this.avatarUrl,
    this.thumbnails,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) =>
      _$TimelineItemFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineItemToJson(this);
}
