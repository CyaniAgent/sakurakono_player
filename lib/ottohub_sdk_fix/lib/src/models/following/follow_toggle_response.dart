import 'package:json_annotation/json_annotation.dart';

part 'follow_toggle_response.g.dart';

/// 关注/取消关注操作响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class FollowToggleResponse {
  /// 更新后的粉丝数。
  final int newFansCount;

  /// 操作后的关注状态。
  final int followStatus;

  const FollowToggleResponse({
    required this.newFansCount,
    required this.followStatus,
  });

  factory FollowToggleResponse.fromJson(Map<String, dynamic> json) =>
      _$FollowToggleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FollowToggleResponseToJson(this);
}
