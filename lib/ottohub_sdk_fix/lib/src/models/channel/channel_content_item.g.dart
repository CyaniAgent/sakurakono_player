// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_content_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelContentItem _$ChannelContentItemFromJson(Map<String, dynamic> json) =>
    ChannelContentItem(
      type: json['type'] as String,
      vid: (json['vid'] as num?)?.toInt(),
      bid: (json['bid'] as num?)?.toInt(),
      uid: (json['uid'] as num).toInt(),
      title: json['title'] as String,
      coverUrl: json['cover_url'] as String?,
      thumbnails: (json['thumbnails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      viewCount: (json['view_count'] as num).toInt(),
      likeCount: (json['like_count'] as num?)?.toInt(),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ChannelContentItemToJson(ChannelContentItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'vid': ?instance.vid,
      'bid': ?instance.bid,
      'uid': instance.uid,
      'title': instance.title,
      'cover_url': ?instance.coverUrl,
      'thumbnails': ?instance.thumbnails,
      'view_count': instance.viewCount,
      'like_count': ?instance.likeCount,
      'created_at': instance.createdAt,
    };
