// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockRecord _$BlockRecordFromJson(Map<String, dynamic> json) => BlockRecord(
  blockId: (json['block_id'] as num).toInt(),
  blockedId: (json['blocked_id'] as num?)?.toInt(),
  blockerId: (json['blocker_id'] as num?)?.toInt(),
  username: json['username'] as String,
  avatar: json['avatar'] as String,
  reason: json['reason'] as String?,
  reasonVisible: (json['reason_visible'] as num?)?.toInt(),
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$BlockRecordToJson(BlockRecord instance) =>
    <String, dynamic>{
      'block_id': instance.blockId,
      'blocked_id': instance.blockedId,
      'blocker_id': instance.blockerId,
      'username': instance.username,
      'avatar': instance.avatar,
      'reason': instance.reason,
      'reason_visible': instance.reasonVisible,
      'created_at': instance.createdAt,
    };
