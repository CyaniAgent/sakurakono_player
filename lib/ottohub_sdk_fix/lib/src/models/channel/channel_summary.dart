import 'package:json_annotation/json_annotation.dart';

part 'channel_summary.g.dart';

/// 频道摘要信息。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ChannelSummary {
  final int channelId;
  final String channelName;
  final String channelTitle;
  final String? description;
  final String? coverUrl;
  final int memberCount;
  final int followerCount;
  final String? createdAt;
  final String? followedAt;
  final int? creatorUid;
  final String? creatorUsername;
  final int? ownerUid;
  final int? joinPermission;
  final bool? isFollowing;
  final bool? isMember;
  final int? userRole;
  final int? role;
  final int? status;
  final String? joinedAt;

  const ChannelSummary({
    required this.channelId,
    required this.channelName,
    required this.channelTitle,
    this.description,
    this.coverUrl,
    required this.memberCount,
    required this.followerCount,
    this.createdAt,
    this.followedAt,
    this.creatorUid,
    this.creatorUsername,
    this.ownerUid,
    this.joinPermission,
    this.isFollowing,
    this.isMember,
    this.userRole,
    this.role,
    this.status,
    this.joinedAt,
  });

  factory ChannelSummary.fromJson(Map<String, dynamic> json) =>
      _$ChannelSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelSummaryToJson(this);
}
