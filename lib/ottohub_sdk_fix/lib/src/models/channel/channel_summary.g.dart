// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelSummary _$ChannelSummaryFromJson(Map<String, dynamic> json) =>
    ChannelSummary(
      channelId: (json['channel_id'] as num).toInt(),
      channelName: json['channel_name'] as String,
      channelTitle: json['channel_title'] as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      memberCount: (json['member_count'] as num).toInt(),
      followerCount: (json['follower_count'] as num).toInt(),
      createdAt: json['created_at'] as String?,
      followedAt: json['followed_at'] as String?,
      creatorUid: (json['creator_uid'] as num?)?.toInt(),
      creatorUsername: json['creator_username'] as String?,
      ownerUid: (json['owner_uid'] as num?)?.toInt(),
      joinPermission: (json['join_permission'] as num?)?.toInt(),
      isFollowing: json['is_following'] as bool?,
      isMember: json['is_member'] as bool?,
      userRole: (json['user_role'] as num?)?.toInt(),
      role: (json['role'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      joinedAt: json['joined_at'] as String?,
    );

Map<String, dynamic> _$ChannelSummaryToJson(ChannelSummary instance) =>
    <String, dynamic>{
      'channel_id': instance.channelId,
      'channel_name': instance.channelName,
      'channel_title': instance.channelTitle,
      'description': ?instance.description,
      'cover_url': ?instance.coverUrl,
      'member_count': instance.memberCount,
      'follower_count': instance.followerCount,
      'created_at': ?instance.createdAt,
      'followed_at': ?instance.followedAt,
      'creator_uid': ?instance.creatorUid,
      'creator_username': ?instance.creatorUsername,
      'owner_uid': ?instance.ownerUid,
      'join_permission': ?instance.joinPermission,
      'is_following': ?instance.isFollowing,
      'is_member': ?instance.isMember,
      'user_role': ?instance.userRole,
      'role': ?instance.role,
      'status': ?instance.status,
      'joined_at': ?instance.joinedAt,
    };
