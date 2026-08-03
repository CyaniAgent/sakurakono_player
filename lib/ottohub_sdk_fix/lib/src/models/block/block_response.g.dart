// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockResponse _$BlockResponseFromJson(Map<String, dynamic> json) =>
    BlockResponse(
      blockId: (json['block_id'] as num?)?.toInt(),
      blockedId: (json['blocked_id'] as num).toInt(),
      reason: json['reason'] as String?,
      reasonVisible: (json['reason_visible'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BlockResponseToJson(BlockResponse instance) =>
    <String, dynamic>{
      'block_id': instance.blockId,
      'blocked_id': instance.blockedId,
      'reason': instance.reason,
      'reason_visible': instance.reasonVisible,
    };
