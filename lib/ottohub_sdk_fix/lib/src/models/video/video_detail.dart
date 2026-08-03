import 'package:json_annotation/json_annotation.dart';
import 'channel_detail.dart';

part 'video_detail.g.dart';

/// 视频详细信息。
@JsonSerializable(fieldRename: FieldRename.snake)
class VideoDetail {
  final String vid;
  final String uid;
  final String title;
  final String? intro;
  final String? type;
  final String? category;
  final String? tag;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final String coverUrl;
  final String? videoUrl;
  final String? audioUrl;
  final String username;
  final String? userintro;
  final String? avatarUrl;
  /// 当前用户是否点赞，`1`=已点赞，`0`=未点赞。
  final int ifLike;

  /// 当前用户是否收藏，`1`=已收藏，`0`=未收藏。
  final int ifFavorite;

  /// 视频宽度。
  final int? videoWidth;

  /// 视频高度。
  final int? videoHeight;

  /// 视频样本宽高比（SAR）。
  final int? videoSar;

  /// 视频显示宽高比（DAR）。
  final int? videoDar;

  final int duration;
  final int? commentCount;

  /// HLS 流播放地址（m3u8）。
  final String? videoM3u8Url;

  final int? channelId;
  final ChannelDetail? channelDetail;

  /// 上次观看进度（秒），仅在请求携带 token 时返回。
  final int? lastWatchSecond;

  const VideoDetail({
    required this.vid,
    required this.uid,
    required this.title,
    this.intro,
    this.type,
    this.category,
    this.tag,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    required this.coverUrl,
    this.videoUrl,
    this.audioUrl,
    required this.username,
    this.userintro,
    this.avatarUrl,
    required this.ifLike,
    required this.ifFavorite,
    this.videoWidth,
    this.videoHeight,
    this.videoSar,
    this.videoDar,
    required this.duration,
    this.commentCount,
    this.videoM3u8Url,
    this.channelId,
    this.channelDetail,
    required this.lastWatchSecond,
  });

  factory VideoDetail.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailFromJson(json);

  Map<String, dynamic> toJson() => _$VideoDetailToJson(this);
}
