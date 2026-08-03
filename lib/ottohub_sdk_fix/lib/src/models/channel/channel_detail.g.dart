// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelDetail _$ChannelDetailFromJson(Map<String, dynamic> json) =>
    ChannelDetail(
      channelId: (json['channel_id'] as num).toInt(),
      channelName: json['channel_name'] as String,
      channelTitle: json['channel_title'] as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      creatorUid: (json['creator_uid'] as num).toInt(),
      ownerUid: (json['owner_uid'] as num).toInt(),
      adminUids: (json['admin_uids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      joinPermission: (json['join_permission'] as num).toInt(),
      memberCount: (json['member_count'] as num).toInt(),
      followerCount: (json['follower_count'] as num).toInt(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      isMember: json['is_member'] as bool?,
      isFollowing: json['is_following'] as bool?,
      userRole: (json['user_role'] as num?)?.toInt(),
      isBlacklisted: json['is_blacklisted'] as bool?,
    );

Map<String, dynamic> _$ChannelDetailToJson(ChannelDetail instance) =>
    <String, dynamic>{
      'channel_id': instance.channelId,
      'channel_name': instance.channelName,
      'channel_title': instance.channelTitle,
      'description': ?instance.description,
      'cover_url': ?instance.coverUrl,
      'creator_uid': instance.creatorUid,
      'owner_uid': instance.ownerUid,
      'admin_uids': ?instance.adminUids,
      'join_permission': instance.joinPermission,
      'member_count': instance.memberCount,
      'follower_count': instance.followerCount,
      'created_at': instance.createdAt,
      'updated_at': ?instance.updatedAt,
      'is_member': ?instance.isMember,
      'is_following': ?instance.isFollowing,
      'user_role': ?instance.userRole,
      'is_blacklisted': ?instance.isBlacklisted,
    };
