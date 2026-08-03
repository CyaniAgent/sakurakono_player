// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelHistoryItem _$ChannelHistoryItemFromJson(Map<String, dynamic> json) =>
    ChannelHistoryItem(
      logId: (json['log_id'] as num).toInt(),
      operationType: (json['operation_type'] as num).toInt(),
      operationName: json['operation_name'] as String,
      operatorUid: (json['operator_uid'] as num?)?.toInt(),
      operatorName: json['operator_name'] as String?,
      oldStatus: (json['old_status'] as num?)?.toInt(),
      newStatus: (json['new_status'] as num?)?.toInt(),
      oldRole: (json['old_role'] as num?)?.toInt(),
      newRole: (json['new_role'] as num?)?.toInt(),
      reason: json['reason'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ChannelHistoryItemToJson(ChannelHistoryItem instance) =>
    <String, dynamic>{
      'log_id': instance.logId,
      'operation_type': instance.operationType,
      'operation_name': instance.operationName,
      'operator_uid': instance.operatorUid,
      'operator_name': instance.operatorName,
      'old_status': instance.oldStatus,
      'new_status': instance.newStatus,
      'old_role': instance.oldRole,
      'new_role': instance.newRole,
      'reason': instance.reason,
      'created_at': instance.createdAt,
    };
