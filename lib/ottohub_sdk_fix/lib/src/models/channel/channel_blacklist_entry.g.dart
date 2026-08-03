// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_blacklist_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelBlacklistEntry _$ChannelBlacklistEntryFromJson(
  Map<String, dynamic> json,
) => ChannelBlacklistEntry(
  uid: (json['uid'] as num).toInt(),
  username: json['username'] as String,
  avatarUrl: json['avatar_url'] as String?,
  reason: json['reason'] as String?,
  operatorUid: (json['operator_uid'] as num?)?.toInt(),
  operatorName: json['operator_name'] as String?,
  blacklistedAt: json['blacklisted_at'] as String,
);

Map<String, dynamic> _$ChannelBlacklistEntryToJson(
  ChannelBlacklistEntry instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'username': instance.username,
  'avatar_url': ?instance.avatarUrl,
  'reason': ?instance.reason,
  'operator_uid': ?instance.operatorUid,
  'operator_name': ?instance.operatorName,
  'blacklisted_at': instance.blacklistedAt,
};
