import 'package:json_annotation/json_annotation.dart';

part 'active_follower.g.dart';

/// 活跃粉丝信息。
@JsonSerializable(fieldRename: FieldRename.snake)
class ActiveFollower {
  final int uid;
  final String username;
  final String avatarUrl;
  final String latestActivityTime;

  const ActiveFollower({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    required this.latestActivityTime,
  });

  factory ActiveFollower.fromJson(Map<String, dynamic> json) =>
      _$ActiveFollowerFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveFollowerToJson(this);
}
