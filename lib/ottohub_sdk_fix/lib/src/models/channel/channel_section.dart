import 'package:json_annotation/json_annotation.dart';

part 'channel_section.g.dart';

/// 栏目内容计数。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ContentCount {
  final int videoCount;
  final int blogCount;
  final int totalCount;

  const ContentCount({
    required this.videoCount,
    required this.blogCount,
    required this.totalCount,
  });

  factory ContentCount.fromJson(Map<String, dynamic> json) =>
      _$ContentCountFromJson(json);

  Map<String, dynamic> toJson() => _$ContentCountToJson(this);
}

/// 频道栏目。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ChannelSection {
  final int channelSectionId;
  final int channelId;
  final String sectionName;
  final String? description;
  final String? iconUrl;
  final int sortOrder;
  final int creatorUid;
  final String createdAt;
  final String? updatedAt;
  final int? isDeleted;
  final ContentCount? contentCount;

  const ChannelSection({
    required this.channelSectionId,
    required this.channelId,
    required this.sectionName,
    this.description,
    this.iconUrl,
    required this.sortOrder,
    required this.creatorUid,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.contentCount,
  });

  factory ChannelSection.fromJson(Map<String, dynamic> json) =>
      _$ChannelSectionFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelSectionToJson(this);
}

/// 栏目内容审核及互动统计。
@JsonSerializable(fieldRename: FieldRename.snake)
class SectionCountStats {
  final int approvedCount;
  final int pendingCount;
  final int totalViews;
  final int totalLikes;

  const SectionCountStats({
    required this.approvedCount,
    required this.pendingCount,
    required this.totalViews,
    required this.totalLikes,
  });

  factory SectionCountStats.fromJson(Map<String, dynamic> json) =>
      _$SectionCountStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SectionCountStatsToJson(this);
}

/// 栏目统计数据（含审核及互动）。
@JsonSerializable(fieldRename: FieldRename.snake)
class SectionStats {
  final int channelSectionId;
  final int channelId;
  final String sectionName;
  final SectionCountStats video;
  final SectionCountStats blog;
  final SectionCountStats total;

  const SectionStats({
    required this.channelSectionId,
    required this.channelId,
    required this.sectionName,
    required this.video,
    required this.blog,
    required this.total,
  });

  factory SectionStats.fromJson(Map<String, dynamic> json) =>
      _$SectionStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SectionStatsToJson(this);
}
