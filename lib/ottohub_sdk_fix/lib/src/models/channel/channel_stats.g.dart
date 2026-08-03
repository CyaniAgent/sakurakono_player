// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelStats _$ChannelStatsFromJson(Map<String, dynamic> json) => ChannelStats(
  channelId: (json['channel_id'] as num).toInt(),
  memberCount: (json['member_count'] as num).toInt(),
  followerCount: (json['follower_count'] as num).toInt(),
  videoCount: (json['video_count'] as num).toInt(),
  blogCount: (json['blog_count'] as num).toInt(),
  totalContentCount: (json['total_content_count'] as num).toInt(),
  todayContentCount: (json['today_content_count'] as num).toInt(),
  weekContentCount: (json['week_content_count'] as num).toInt(),
  monthContentCount: (json['month_content_count'] as num).toInt(),
);

Map<String, dynamic> _$ChannelStatsToJson(ChannelStats instance) =>
    <String, dynamic>{
      'channel_id': instance.channelId,
      'member_count': instance.memberCount,
      'follower_count': instance.followerCount,
      'video_count': instance.videoCount,
      'blog_count': instance.blogCount,
      'total_content_count': instance.totalContentCount,
      'today_content_count': instance.todayContentCount,
      'week_content_count': instance.weekContentCount,
      'month_content_count': instance.monthContentCount,
    };
