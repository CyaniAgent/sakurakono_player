// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockStatusResponse _$BlockStatusResponseFromJson(Map<String, dynamic> json) =>
    BlockStatusResponse(
      targetUserId: (json['target_user_id'] as num).toInt(),
      iBlocked: json['i_blocked'] as bool,
      heBlocked: json['he_blocked'] as bool,
      mutualBlock: json['mutual_block'] as bool,
      anyBlock: json['any_block'] as bool,
      myReason: json['my_reason'] as String?,
      hisReason: json['his_reason'] as String?,
      hisReasonVisible: json['his_reason_visible'] as bool?,
    );

Map<String, dynamic> _$BlockStatusResponseToJson(
  BlockStatusResponse instance,
) => <String, dynamic>{
  'target_user_id': instance.targetUserId,
  'i_blocked': instance.iBlocked,
  'he_blocked': instance.heBlocked,
  'mutual_block': instance.mutualBlock,
  'any_block': instance.anyBlock,
  'my_reason': instance.myReason,
  'his_reason': instance.hisReason,
  'his_reason_visible': instance.hisReasonVisible,
};
