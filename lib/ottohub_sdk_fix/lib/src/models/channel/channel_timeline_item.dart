import 'package:json_annotation/json_annotation.dart';

part 'channel_timeline_item.g.dart';

/// 频道动态时间线条目。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ChannelTimelineItem {
  final String contentType;
  final int? vid;
  final int? bid;
  final int uid;
  final String title;
  final String? content;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final String? coverUrl;
  final String? username;
  final String? avatarUrl;
  final List<String>? thumbnails;

  const ChannelTimelineItem({
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
    this.username,
    this.avatarUrl,
    this.thumbnails,
  });

  factory ChannelTimelineItem.fromJson(Map<String, dynamic> json) =>
      _$ChannelTimelineItemFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelTimelineItemToJson(this);
}

/// 带频道信息的动态时间线条目。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ChannelTimelineWithChannelItem extends ChannelTimelineItem {
  final int channelId;
  final String channelName;
  final String channelTitle;
  final String channelDescription;
  final String channelCoverUrl;

  const ChannelTimelineWithChannelItem({
    required super.contentType,
    super.vid,
    super.bid,
    required super.uid,
    required super.title,
    super.content,
    required super.time,
    required super.likeCount,
    required super.favoriteCount,
    required super.viewCount,
    super.coverUrl,
    super.username,
    super.avatarUrl,
    super.thumbnails,
    required this.channelId,
    required this.channelName,
    required this.channelTitle,
    required this.channelDescription,
    required this.channelCoverUrl,
  });

  factory ChannelTimelineWithChannelItem.fromJson(Map<String, dynamic> json) =>
      _$ChannelTimelineWithChannelItemFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ChannelTimelineWithChannelItemToJson(this);
}
