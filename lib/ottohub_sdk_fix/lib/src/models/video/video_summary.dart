import 'package:json_annotation/json_annotation.dart';
import '../utils/converters.dart';
import 'channel_detail.dart';

part 'video_summary.g.dart';

/// 视频摘要信息，用于列表展示。
@JsonSerializable(fieldRename: FieldRename.snake)
class VideoSummary {
  /// 视频 ID。
  @StringToIntConverter()
  final int vid;

  /// 上传者用户 ID。
  @StringToIntConverter()
  final int uid;

  /// 视频标题。
  final String title;

  /// 发布时间。
  final String time;

  /// 点赞数。
  @StringToIntConverter()
  final int likeCount;

  /// 收藏数。
  @StringToIntConverter()
  final int favoriteCount;

  /// 播放量。
  @StringToIntConverter()
  final int viewCount;

  /// 视频时长（秒）。
  @StringToIntConverter()
  final int duration;

  /// 封面图 URL。
  final String coverUrl;

  /// 上传者用户名。
  final String username;

  /// 上传者头像 URL。
  final String? avatarUrl;

  /// 视频简介。
  final String? intro;

  /// 视频标签。
  final String? tag;

  /// 所属合集名称。
  final String? collection;

  /// 视频类型（如 0=普通，1=转载等）。
  @StringToNullableIntConverter()
  final int? type;

  /// 视频分类。
  final String? category;

  /// 在合集中的排序值。
  @StringToNullableIntConverter()
  final int? collectionSortOrder;

  /// 关联频道 ID。
  @StringToNullableIntConverter()
  final int? channelId;

  /// 关联频道详情。
  final ChannelDetail? channelDetail;

  const VideoSummary({
    required this.vid,
    required this.uid,
    required this.title,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    required this.duration,
    required this.coverUrl,
    required this.username,
    this.avatarUrl,
    this.intro,
    this.tag,
    this.collection,
    this.type,
    this.category,
    this.collectionSortOrder,
    this.channelId,
    this.channelDetail,
  });

  factory VideoSummary.fromJson(Map<String, dynamic> json) =>
      _$VideoSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$VideoSummaryToJson(this);
}
