import 'package:json_annotation/json_annotation.dart';

part 'following_user.g.dart';

/// 关注的用户信息。
@JsonSerializable(fieldRename: FieldRename.snake)
class FollowingUser {
  final int uid;
  final String username;
  final String? intro;
  final String avatarUrl;

  /// 关注状态（如 `1`=已关注，`0`=未关注）。
  final int? followStatus;

  const FollowingUser({
    required this.uid,
    required this.username,
    this.intro,
    required this.avatarUrl,
    this.followStatus,
  });

  factory FollowingUser.fromJson(Map<String, dynamic> json) =>
      _$FollowingUserFromJson(json);

  Map<String, dynamic> toJson() => _$FollowingUserToJson(this);
}
