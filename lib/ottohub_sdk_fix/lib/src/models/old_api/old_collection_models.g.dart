// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'old_collection_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionVideoItem _$CollectionVideoItemFromJson(Map<String, dynamic> json) =>
    CollectionVideoItem(
      vid: (json['vid'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
      title: json['title'] as String,
      time: json['time'] as String,
      likeCount: (json['like_count'] as num).toInt(),
      favoriteCount: (json['favorite_count'] as num).toInt(),
      viewCount: (json['view_count'] as num).toInt(),
      coverUrl: json['cover_url'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      collectionSortOrder: (json['collection_sort_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CollectionVideoItemToJson(
  CollectionVideoItem instance,
) => <String, dynamic>{
  'vid': instance.vid,
  'uid': instance.uid,
  'title': instance.title,
  'time': instance.time,
  'like_count': instance.likeCount,
  'favorite_count': instance.favoriteCount,
  'view_count': instance.viewCount,
  'cover_url': ?instance.coverUrl,
  'username': ?instance.username,
  'avatar_url': ?instance.avatarUrl,
  'collection_sort_order': ?instance.collectionSortOrder,
};

CollectionDetail _$CollectionDetailFromJson(Map<String, dynamic> json) =>
    CollectionDetail(
      collection: json['collection'] as String,
      videoList: (json['video_list'] as List<dynamic>)
          .map((e) => CollectionVideoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CollectionDetailToJson(CollectionDetail instance) =>
    <String, dynamic>{
      'collection': instance.collection,
      'video_list': instance.videoList.map((e) => e.toJson()).toList(),
    };
