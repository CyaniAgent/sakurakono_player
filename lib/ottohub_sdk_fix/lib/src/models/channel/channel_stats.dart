import 'package:json_annotation/json_annotation.dart';

part 'channel_stats.g.dart';

/// 频道统计数据。
@JsonSerializable(fieldRename: FieldRename.snake)
class ChannelStats {
  final int channelId;
  final int memberCount;
  final int followerCount;
  final int videoCount;
  final int blogCount;
  final int totalContentCount;
  final int todayContentCount;
  final int weekContentCount;
  final int monthContentCount;

  const ChannelStats({
    required this.channelId,
    required this.memberCount,
    required this.followerCount,
    required this.videoCount,
    required this.blogCount,
    required this.totalContentCount,
    required this.todayContentCount,
    required this.weekContentCount,
    required this.monthContentCount,
  });

  factory ChannelStats.fromJson(Map<String, dynamic> json) =>
      _$ChannelStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelStatsToJson(this);
}
