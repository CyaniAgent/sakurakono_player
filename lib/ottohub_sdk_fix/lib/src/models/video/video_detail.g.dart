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
  likeCount: json['like_count'] as int,
  favoriteCount: json['favorite_count'] as int,
  viewCount: json['view_count'] as int,
  coverUrl: json['cover_url'] as String,
  videoUrl: json['video_url'] as String?,
  audioUrl: json['audio_url'] as String?,
  username: json['username'] as String,
  userintro: json['userintro'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  ifLike: (json['if_like'] as num).toInt(),
  ifFavorite: (json['if_favorite'] as num).toInt(),
  videoWidth: json['video_width'] as int?,
  videoHeight: json['video_height'] as int?,
  videoSar: json['video_sar'] as int?,
  videoDar: json['video_dar'] as int?,
  duration: json['duration'] as int,
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
      'channel_detail': instance.channelDetail,
      'last_watch_second': instance.lastWatchSecond,
    };
