// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'old_blog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogSummary _$BlogSummaryFromJson(Map<String, dynamic> json) => BlogSummary(
  bid: (json['bid'] as num).toInt(),
  uid: (json['uid'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String?,
  time: json['time'] as String,
  likeCount: (json['like_count'] as num).toInt(),
  favoriteCount: (json['favorite_count'] as num).toInt(),
  viewCount: (json['view_count'] as num).toInt(),
  avatarUrl: json['avatar_url'] as String?,
  commentCount: (json['comment_count'] as num?)?.toInt(),
  thumbnails: (json['thumbnails'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$BlogSummaryToJson(BlogSummary instance) =>
    <String, dynamic>{
      'bid': instance.bid,
      'uid': instance.uid,
      'title': instance.title,
      'content': ?instance.content,
      'time': instance.time,
      'like_count': instance.likeCount,
      'favorite_count': instance.favoriteCount,
      'view_count': instance.viewCount,
      'avatar_url': ?instance.avatarUrl,
      'comment_count': ?instance.commentCount,
      'thumbnails': ?instance.thumbnails,
    };

BlogDetail _$BlogDetailFromJson(Map<String, dynamic> json) => BlogDetail(
  bid: (json['bid'] as num).toInt(),
  uid: (json['uid'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  time: json['time'] as String,
  likeCount: (json['like_count'] as num).toInt(),
  favoriteCount: (json['favorite_count'] as num).toInt(),
  viewCount: (json['view_count'] as num).toInt(),
  avatarUrl: json['avatar_url'] as String?,
  username: json['username'] as String?,
  commentCount: (json['comment_count'] as num?)?.toInt(),
  ifLike: (json['if_like'] as num?)?.toInt(),
  ifFavorite: (json['if_favorite'] as num?)?.toInt(),
  thumbnails: (json['thumbnails'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  channelId: (json['channel_id'] as num?)?.toInt(),
  channelDetail: json['channel_detail'] == null
      ? null
      : ChannelDetail.fromJson(json['channel_detail'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BlogDetailToJson(BlogDetail instance) =>
    <String, dynamic>{
      'bid': instance.bid,
      'uid': instance.uid,
      'title': instance.title,
      'content': instance.content,
      'time': instance.time,
      'like_count': instance.likeCount,
      'favorite_count': instance.favoriteCount,
      'view_count': instance.viewCount,
      'avatar_url': ?instance.avatarUrl,
      'username': ?instance.username,
      'comment_count': ?instance.commentCount,
      'if_like': ?instance.ifLike,
      'if_favorite': ?instance.ifFavorite,
      'thumbnails': ?instance.thumbnails,
      'channel_id': ?instance.channelId,
      'channel_detail': ?instance.channelDetail,
    };

BlogAuditItem _$BlogAuditItemFromJson(Map<String, dynamic> json) =>
    BlogAuditItem(
      bid: (json['bid'] as num).toInt(),
      title: json['title'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$BlogAuditItemToJson(BlogAuditItem instance) =>
    <String, dynamic>{
      'bid': instance.bid,
      'title': ?instance.title,
      'content': ?instance.content,
    };
