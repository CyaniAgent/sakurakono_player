// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelMember _$ChannelMemberFromJson(Map<String, dynamic> json) =>
    ChannelMember(
      uid: (json['uid'] as num).toInt(),
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: (json['role'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      joinedAt: json['joined_at'] as String,
    );

Map<String, dynamic> _$ChannelMemberToJson(ChannelMember instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'avatar_url': ?instance.avatarUrl,
      'role': instance.role,
      'status': instance.status,
      'joined_at': instance.joinedAt,
    };

ChannelMemberApplication _$ChannelMemberApplicationFromJson(
  Map<String, dynamic> json,
) => ChannelMemberApplication(
  uid: (json['uid'] as num).toInt(),
  username: json['username'] as String,
  avatarUrl: json['avatar_url'] as String?,
  status: (json['status'] as num).toInt(),
  appliedAt: json['applied_at'] as String,
);

Map<String, dynamic> _$ChannelMemberApplicationToJson(
  ChannelMemberApplication instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'username': instance.username,
  'avatar_url': ?instance.avatarUrl,
  'status': instance.status,
  'applied_at': instance.appliedAt,
};
