import 'package:json_annotation/json_annotation.dart';

part 'channel_detail.g.dart';

/// 频道摘要信息（嵌套于视频/博客模型中）。
///
/// 注意：此模型与 [ChannelDetail]（`models/channel/channel_detail.dart`）不同，
/// 本模型字段较少，且 `channelId` 为字符串类型，服务器可能返回空字符串。
@JsonSerializable(fieldRename: FieldRename.snake)
class ChannelDetail {
  @JsonKey(fromJson: _asString)
  final String channelId;
  final String? channelName;
  final String? channelTitle;
  @JsonKey(readValue: _readDescription)
  final String? description;
  @JsonKey(readValue: _readCoverUrl)
  final String? coverUrl;

  const ChannelDetail({
    required this.channelId,
    this.channelName,
    this.channelTitle,
    this.description,
    this.coverUrl,
  });

  factory ChannelDetail.fromJson(Map<String, dynamic> json) =>
      _$ChannelDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelDetailToJson(this);

  static String _asString(dynamic v) => v?.toString() ?? '';

  static Object? _readDescription(Map map, String _) =>
      map['description'] ?? map['channel_description'];

  static Object? _readCoverUrl(Map map, String _) =>
      map['cover_url'] ?? map['channel_cover_url'];
}
