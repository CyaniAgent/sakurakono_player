// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_timeline_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelTimelineItem _$ChannelTimelineItemFromJson(Map<String, dynamic> json) =>
    ChannelTimelineItem(
      contentType: json['content_type'] as String,
      vid: (json['vid'] as num?)?.toInt(),
      bid: (json['bid'] as num?)?.toInt(),
      uid: (json['uid'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String?,
      time: json['time'] as String,
      likeCount: (json['like_count'] as num).toInt(),
      favoriteCount: (json['favorite_count'] as num).toInt(),
      viewCount: (json['view_count'] as num).toInt(),
      coverUrl: json['cover_url'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      thumbnails: (json['thumbnails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ChannelTimelineItemToJson(
  ChannelTimelineItem instance,
) => <String, dynamic>{
  'content_type': instance.contentType,
  'vid': ?instance.vid,
  'bid': ?instance.bid,
  'uid': instance.uid,
  'title': instance.title,
  'content': ?instance.content,
  'time': instance.time,
  'like_count': instance.likeCount,
  'favorite_count': instance.favoriteCount,
  'view_count': instance.viewCount,
  'cover_url': ?instance.coverUrl,
  'username': ?instance.username,
  'avatar_url': ?instance.avatarUrl,
  'thumbnails': ?instance.thumbnails,
};

ChannelTimelineWithChannelItem _$ChannelTimelineWithChannelItemFromJson(
  Map<String, dynamic> json,
) => ChannelTimelineWithChannelItem(
  contentType: json['content_type'] as String,
  vid: (json['vid'] as num?)?.toInt(),
  bid: (json['bid'] as num?)?.toInt(),
  uid: (json['uid'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String?,
  time: json['time'] as String,
  likeCount: (json['like_count'] as num).toInt(),
  favoriteCount: (json['favorite_count'] as num).toInt(),
  viewCount: (json['view_count'] as num).toInt(),
  coverUrl: json['cover_url'] as String?,
  username: json['username'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  thumbnails: (json['thumbnails'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  channelId: (json['channel_id'] as num).toInt(),
  channelName: json['channel_name'] as String,
  channelTitle: json['channel_title'] as String,
  channelDescription: json['channel_description'] as String,
  channelCoverUrl: json['channel_cover_url'] as String,
);

Map<String, dynamic> _$ChannelTimelineWithChannelItemToJson(
  ChannelTimelineWithChannelItem instance,
) => <String, dynamic>{
  'content_type': instance.contentType,
  'vid': ?instance.vid,
  'bid': ?instance.bid,
  'uid': instance.uid,
  'title': instance.title,
  'content': ?instance.content,
  'time': instance.time,
  'like_count': instance.likeCount,
  'favorite_count': instance.favoriteCount,
  'view_count': instance.viewCount,
  'cover_url': ?instance.coverUrl,
  'username': ?instance.username,
  'avatar_url': ?instance.avatarUrl,
  'thumbnails': ?instance.thumbnails,
  'channel_id': instance.channelId,
  'channel_name': instance.channelName,
  'channel_title': instance.channelTitle,
  'channel_description': instance.channelDescription,
  'channel_cover_url': instance.channelCoverUrl,
};
