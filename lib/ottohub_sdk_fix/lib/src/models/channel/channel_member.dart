import 'package:json_annotation/json_annotation.dart';

part 'channel_member.g.dart';

/// 频道成员信息。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ChannelMember {
  final int uid;
  final String username;
  final String? avatarUrl;

  /// 成员角色（`0`=普通成员，`1`=管理员，`2`=创建者）。
  final int role;

  /// 成员状态（`0`=正常，`1`=待审核，`2`=已踢出）。
  final int status;

  final String joinedAt;

  const ChannelMember({
    required this.uid,
    required this.username,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.joinedAt,
  });

  factory ChannelMember.fromJson(Map<String, dynamic> json) =>
      _$ChannelMemberFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelMemberToJson(this);
}

/// 频道成员申请信息。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ChannelMemberApplication {
  final int uid;
  final String username;
  final String? avatarUrl;

  /// 申请状态（`0`=待审核，`1`=已通过，`2`=已拒绝）。
  final int status;

  final String appliedAt;

  const ChannelMemberApplication({
    required this.uid,
    required this.username,
    this.avatarUrl,
    required this.status,
    required this.appliedAt,
  });

  factory ChannelMemberApplication.fromJson(Map<String, dynamic> json) =>
      _$ChannelMemberApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelMemberApplicationToJson(this);
}
