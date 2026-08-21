// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentCount _$ContentCountFromJson(Map<String, dynamic> json) => ContentCount(
  videoCount: (json['video_count'] as num).toInt(),
  blogCount: (json['blog_count'] as num).toInt(),
  totalCount: (json['total_count'] as num).toInt(),
);

Map<String, dynamic> _$ContentCountToJson(ContentCount instance) =>
    <String, dynamic>{
      'video_count': instance.videoCount,
      'blog_count': instance.blogCount,
      'total_count': instance.totalCount,
    };

ChannelSection _$ChannelSectionFromJson(Map<String, dynamic> json) =>
    ChannelSection(
      channelSectionId: (json['channel_section_id'] as num).toInt(),
      channelId: (json['channel_id'] as num).toInt(),
      sectionName: json['section_name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      creatorUid: (json['creator_uid'] as num).toInt(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      isDeleted: (json['is_deleted'] as num?)?.toInt(),
      contentCount: json['content_count'] == null
          ? null
          : ContentCount.fromJson(
              json['content_count'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ChannelSectionToJson(ChannelSection instance) =>
    <String, dynamic>{
      'channel_section_id': instance.channelSectionId,
      'channel_id': instance.channelId,
      'section_name': instance.sectionName,
      'description': ?instance.description,
      'icon_url': ?instance.iconUrl,
      'sort_order': instance.sortOrder,
      'creator_uid': instance.creatorUid,
      'created_at': instance.createdAt,
      'updated_at': ?instance.updatedAt,
      'is_deleted': ?instance.isDeleted,
      'content_count': ?instance.contentCount?.toJson(),
    };

SectionCountStats _$SectionCountStatsFromJson(Map<String, dynamic> json) =>
    SectionCountStats(
      approvedCount: (json['approved_count'] as num).toInt(),
      pendingCount: (json['pending_count'] as num).toInt(),
      totalViews: (json['total_views'] as num).toInt(),
      totalLikes: (json['total_likes'] as num).toInt(),
    );

Map<String, dynamic> _$SectionCountStatsToJson(SectionCountStats instance) =>
    <String, dynamic>{
      'approved_count': instance.approvedCount,
      'pending_count': instance.pendingCount,
      'total_views': instance.totalViews,
      'total_likes': instance.totalLikes,
    };

SectionStats _$SectionStatsFromJson(Map<String, dynamic> json) => SectionStats(
  channelSectionId: (json['channel_section_id'] as num).toInt(),
  channelId: (json['channel_id'] as num).toInt(),
  sectionName: json['section_name'] as String,
  video: SectionCountStats.fromJson(json['video'] as Map<String, dynamic>),
  blog: SectionCountStats.fromJson(json['blog'] as Map<String, dynamic>),
  total: SectionCountStats.fromJson(json['total'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SectionStatsToJson(SectionStats instance) =>
    <String, dynamic>{
      'channel_section_id': instance.channelSectionId,
      'channel_id': instance.channelId,
      'section_name': instance.sectionName,
      'video': instance.video.toJson(),
      'blog': instance.blog.toJson(),
      'total': instance.total.toJson(),
    };
