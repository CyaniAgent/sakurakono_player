// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoDetail _$VideoDetailFromJson(Map<String, dynamic> json) => VideoDetail(
  vid: json['vid'] as String,
  uid: json['uid'] as String,
  title: json['title'] as String,
  intro: json['intro'] as String?,
  type: json['type'] as String?,
  category: json['category'] as String?,
  tag: json['tag'] as String?,
  time: json['time'] as String,
  likeCount: (json['like_count'] as num).toInt(),
  favoriteCount: (json['favorite_count'] as num).toInt(),
  viewCount: (json['view_count'] as num).toInt(),
  coverUrl: json['cover_url'] as String,
  videoUrl: json['video_url'] as String?,
  audioUrl: json['audio_url'] as String?,
  username: json['username'] as String,
  userintro: json['userintro'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  ifLike: (json['if_like'] as num).toInt(),
  ifFavorite: (json['if_favorite'] as num).toInt(),
  videoWidth: (json['video_width'] as num?)?.toInt(),
  videoHeight: (json['video_height'] as num?)?.toInt(),
  videoSar: (json['video_sar'] as num?)?.toInt(),
  videoDar: (json['video_dar'] as num?)?.toInt(),
  duration: (json['duration'] as num).toInt(),
  commentCount: (json['comment_count'] as num?)?.toInt(),
  videoM3u8Url: json['video_m3u8_url'] as String?,
  channelId: (json['channel_id'] as num?)?.toInt(),
  channelDetail: json['channel_detail'] == null
      ? null
      : ChannelDetail.fromJson(json['channel_detail'] as Map<String, dynamic>),
  lastWatchSecond: (json['last_watch_second'] as num?)?.toInt(),
);

Map<String, dynamic> _$VideoDetailToJson(VideoDetail instance) =>
    <String, dynamic>{
      'vid': instance.vid,
      'uid': instance.uid,
      'title': instance.title,
      'intro': instance.intro,
      'type': instance.type,
      'category': instance.category,
      'tag': instance.tag,
      'time': instance.time,
      'like_count': instance.likeCount,
      'favorite_count': instance.favoriteCount,
      'view_count': instance.viewCount,
      'cover_url': instance.coverUrl,
      'video_url': instance.videoUrl,
      'audio_url': instance.audioUrl,
      'username': instance.username,
      'userintro': instance.userintro,
      'avatar_url': instance.avatarUrl,
      'if_like': instance.ifLike,
      'if_favorite': instance.ifFavorite,
      'video_width': instance.videoWidth,
      'video_height': instance.videoHeight,
      'video_sar': instance.videoSar,
      'video_dar': instance.videoDar,
      'duration': instance.duration,
      'comment_count': instance.commentCount,
      'video_m3u8_url': instance.videoM3u8Url,
      'channel_id': instance.channelId,
      'channel_detail': instance.channelDetail?.toJson(),
      'last_watch_second': instance.lastWatchSecond,
    };
