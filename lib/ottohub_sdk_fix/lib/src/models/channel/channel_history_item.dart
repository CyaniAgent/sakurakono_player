import 'package:json_annotation/json_annotation.dart';

part 'channel_history_item.g.dart';

/// 频道操作历史记录。
@JsonSerializable(fieldRename: FieldRename.snake)
class ChannelHistoryItem {
  final int logId;
  final int operationType;
  final String operationName;
  final int? operatorUid;
  final String? operatorName;
  final int? oldStatus;
  final int? newStatus;
  final int? oldRole;
  final int? newRole;
  final String? reason;
  final String createdAt;

  const ChannelHistoryItem({
    required this.logId,
    required this.operationType,
    required this.operationName,
    this.operatorUid,
    this.operatorName,
    this.oldStatus,
    this.newStatus,
    this.oldRole,
    this.newRole,
    this.reason,
    required this.createdAt,
  });

  factory ChannelHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$ChannelHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelHistoryItemToJson(this);
}
