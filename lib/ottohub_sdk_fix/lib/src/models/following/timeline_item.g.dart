// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineItem _$TimelineItemFromJson(Map<String, dynamic> json) => TimelineItem(
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
  username: json['username'] as String,
  avatarUrl: json['avatar_url'] as String?,
  thumbnails: (json['thumbnails'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TimelineItemToJson(TimelineItem instance) =>
    <String, dynamic>{
      'content_type': instance.contentType,
      'vid': instance.vid,
      'bid': instance.bid,
      'uid': instance.uid,
      'title': instance.title,
      'content': instance.content,
      'time': instance.time,
      'like_count': instance.likeCount,
      'favorite_count': instance.favoriteCount,
      'view_count': instance.viewCount,
      'cover_url': instance.coverUrl,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'thumbnails': instance.thumbnails,
    };
