import 'package:json_annotation/json_annotation.dart';

part 'follow_status_response.g.dart';

/// 关注状态查询响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class FollowStatusResponse {
  /// 关注状态（`0`=未关注，`1`=已关注，`2`=互相关注）。
  final int followStatus;

  const FollowStatusResponse({
    required this.followStatus,
  });

  factory FollowStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$FollowStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FollowStatusResponseToJson(this);
}
