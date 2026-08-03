import 'package:json_annotation/json_annotation.dart';

part 'channel_content_item.g.dart';

/// 频道内容条目（视频或博客）。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ChannelContentItem {
  final String type;
  final int? vid;
  final int? bid;
  final int uid;
  final String title;
  final String? coverUrl;
  final List<String>? thumbnails;
  final int viewCount;
  final int? likeCount;
  final String createdAt;

  const ChannelContentItem({
    required this.type,
    this.vid,
    this.bid,
    required this.uid,
    required this.title,
    this.coverUrl,
    this.thumbnails,
    required this.viewCount,
    this.likeCount,
    required this.createdAt,
  });

  factory ChannelContentItem.fromJson(Map<String, dynamic> json) =>
      _$ChannelContentItemFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelContentItemToJson(this);
}
