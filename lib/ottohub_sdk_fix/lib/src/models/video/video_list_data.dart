import 'package:json_annotation/json_annotation.dart';
import '../utils/converters.dart';
import 'video_summary.dart';

part 'video_list_data.g.dart';

/// 视频列表响应，支持分页及统计数据。
@JsonSerializable(
  fieldRename: FieldRename.snake,
  converters: [StringToNullableIntConverter()],
)
class VideoListData {
  final List<VideoSummary> videoList;
  final int? totalCount;
  final int? favoriteVideoCount;
  final int? manageVideoCount;

  const VideoListData({
    required this.videoList,
    this.totalCount,
    this.favoriteVideoCount,
    this.manageVideoCount,
  });

  factory VideoListData.fromJson(Map<String, dynamic> json) =>
      _$VideoListDataFromJson(json);

  Map<String, dynamic> toJson() => _$VideoListDataToJson(this);
}
