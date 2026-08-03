// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_notice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelNotice _$ChannelNoticeFromJson(Map<String, dynamic> json) =>
    ChannelNotice(
      noticeId: (json['notice_id'] as num).toInt(),
      channelId: (json['channel_id'] as num).toInt(),
      title: json['title'] as String?,
      content: json['content'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      creatorUid: (json['creator_uid'] as num).toInt(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      isDeleted: (json['is_deleted'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChannelNoticeToJson(ChannelNotice instance) =>
    <String, dynamic>{
      'notice_id': instance.noticeId,
      'channel_id': instance.channelId,
      'title': ?instance.title,
      'content': instance.content,
      'sort_order': instance.sortOrder,
      'creator_uid': instance.creatorUid,
      'created_at': instance.createdAt,
      'updated_at': ?instance.updatedAt,
      'is_deleted': ?instance.isDeleted,
    };
