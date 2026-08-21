// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoSummary _$VideoSummaryFromJson(Map<String, dynamic> json) => VideoSummary(
  vid: const StringToIntConverter().fromJson(json['vid']),
  uid: const StringToIntConverter().fromJson(json['uid']),
  title: json['title'] as String,
  time: json['time'] as String,
  likeCount: const StringToIntConverter().fromJson(json['like_count']),
  favoriteCount: const StringToIntConverter().fromJson(json['favorite_count']),
  viewCount: const StringToIntConverter().fromJson(json['view_count']),
  duration: const StringToIntConverter().fromJson(json['duration']),
  coverUrl: json['cover_url'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatar_url'] as String?,
  intro: json['intro'] as String?,
  tag: json['tag'] as String?,
  collection: json['collection'] as String?,
  type: const StringToNullableIntConverter().fromJson(json['type']),
  category: json['category'] as String?,
  collectionSortOrder: const StringToNullableIntConverter().fromJson(
    json['collection_sort_order'],
  ),
  channelId: const StringToNullableIntConverter().fromJson(json['channel_id']),
  channelDetail: json['channel_detail'] == null
      ? null
      : ChannelDetail.fromJson(json['channel_detail'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VideoSummaryToJson(
  VideoSummary instance,
) => <String, dynamic>{
  'vid': const StringToIntConverter().toJson(instance.vid),
  'uid': const StringToIntConverter().toJson(instance.uid),
  'title': instance.title,
  'time': instance.time,
  'like_count': const StringToIntConverter().toJson(instance.likeCount),
  'favorite_count': const StringToIntConverter().toJson(instance.favoriteCount),
  'view_count': const StringToIntConverter().toJson(instance.viewCount),
  'duration': const StringToIntConverter().toJson(instance.duration),
  'cover_url': instance.coverUrl,
  'username': instance.username,
  'avatar_url': instance.avatarUrl,
  'intro': instance.intro,
  'tag': instance.tag,
  'collection': instance.collection,
  'type': const StringToNullableIntConverter().toJson(instance.type),
  'category': instance.category,
  'collection_sort_order': const StringToNullableIntConverter().toJson(
    instance.collectionSortOrder,
  ),
  'channel_id': const StringToNullableIntConverter().toJson(instance.channelId),
  'channel_detail': instance.channelDetail?.toJson(),
};
