import 'package:json_annotation/json_annotation.dart';

part 'channel_detail.g.dart';

/// 频道详细信息。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ChannelDetail {
  final int channelId;
  final String channelName;
  final String channelTitle;
  final String? description;
  final String? coverUrl;
  /// 频道创建者 UID。
  final int creatorUid;

  /// 频道拥有者 UID（通常与创建者相同）。
  final int ownerUid;

  /// 管理员 UID 列表。
  final List<int>? adminUids;

  /// 加入权限，`0`=自由加入，`1`=需审核，`2`=仅邀请。
  final int joinPermission;

  final int memberCount;
  final int followerCount;
  final String createdAt;
  final String? updatedAt;
  final bool? isMember;
  final bool? isFollowing;

  /// 当前用户在频道中的角色（如 `0`=普通成员，`1`=管理员，`2`=创建者）。
  final int? userRole;

  /// 当前用户是否被拉黑。
  final bool? isBlacklisted;

  const ChannelDetail({
    required this.channelId,
    required this.channelName,
    required this.channelTitle,
    this.description,
    this.coverUrl,
    required this.creatorUid,
    required this.ownerUid,
    this.adminUids,
    required this.joinPermission,
    required this.memberCount,
    required this.followerCount,
    required this.createdAt,
    this.updatedAt,
    this.isMember,
    this.isFollowing,
    this.userRole,
    this.isBlacklisted,
  });

  factory ChannelDetail.fromJson(Map<String, dynamic> json) =>
      _$ChannelDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelDetailToJson(this);
}
