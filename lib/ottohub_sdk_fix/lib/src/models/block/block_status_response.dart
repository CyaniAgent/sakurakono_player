import 'package:json_annotation/json_annotation.dart';

part 'block_status_response.g.dart';

/// 黑名单状态查询响应，返回双向拉黑关系。
@JsonSerializable(fieldRename: FieldRename.snake)
class BlockStatusResponse {
  /// 目标用户 ID。
  final int targetUserId;

  /// 当前用户是否已将对方拉黑。
  final bool iBlocked;

  /// 对方是否已将当前用户拉黑。
  final bool heBlocked;

  /// 是否双向拉黑。
  final bool mutualBlock;

  /// 是否存在任意拉黑关系。
  final bool anyBlock;

  /// 当前用户的拉黑原因。
  final String? myReason;

  /// 对方的拉黑原因。
  final String? hisReason;

  /// 对方的拉黑原因是否公开可见。
  final bool? hisReasonVisible;

  const BlockStatusResponse({
    required this.targetUserId,
    required this.iBlocked,
    required this.heBlocked,
    required this.mutualBlock,
    required this.anyBlock,
    this.myReason,
    this.hisReason,
    this.hisReasonVisible,
  });

  factory BlockStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$BlockStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BlockStatusResponseToJson(this);
}
