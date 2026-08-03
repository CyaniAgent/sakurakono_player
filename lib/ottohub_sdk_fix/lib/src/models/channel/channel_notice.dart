import 'package:json_annotation/json_annotation.dart';

part 'channel_notice.g.dart';

/// 频道公告。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ChannelNotice {
  final int noticeId;
  final int channelId;
  final String? title;
  final String content;

  /// 排序值（值越小越靠前）。
  final int sortOrder;

  final int creatorUid;
  final String createdAt;
  final String? updatedAt;

  /// 是否已删除，`1`=已删除。
  final int? isDeleted;

  const ChannelNotice({
    required this.noticeId,
    required this.channelId,
    this.title,
    required this.content,
    required this.sortOrder,
    required this.creatorUid,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  factory ChannelNotice.fromJson(Map<String, dynamic> json) =>
      _$ChannelNoticeFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelNoticeToJson(this);
}
