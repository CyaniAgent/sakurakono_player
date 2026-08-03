// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateChannelResponse _$UpdateChannelResponseFromJson(
  Map<String, dynamic> json,
) => UpdateChannelResponse(
  channelId: (json['channel_id'] as num).toInt(),
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$UpdateChannelResponseToJson(
  UpdateChannelResponse instance,
) => <String, dynamic>{
  'channel_id': instance.channelId,
  'updated_at': instance.updatedAt,
};

DeleteChannelResponse _$DeleteChannelResponseFromJson(
  Map<String, dynamic> json,
) => DeleteChannelResponse(
  videoCount: (json['video_count'] as num).toInt(),
  blogCount: (json['blog_count'] as num).toInt(),
  totalContent: (json['total_content'] as num).toInt(),
);

Map<String, dynamic> _$DeleteChannelResponseToJson(
  DeleteChannelResponse instance,
) => <String, dynamic>{
  'video_count': instance.videoCount,
  'blog_count': instance.blogCount,
  'total_content': instance.totalContent,
};

MemberActionResponse _$MemberActionResponseFromJson(
  Map<String, dynamic> json,
) => MemberActionResponse(
  channelId: (json['channel_id'] as num).toInt(),
  uid: (json['uid'] as num).toInt(),
  status: (json['status'] as num).toInt(),
  message: json['message'] as String,
);

Map<String, dynamic> _$MemberActionResponseToJson(
  MemberActionResponse instance,
) => <String, dynamic>{
  'channel_id': instance.channelId,
  'uid': instance.uid,
  'status': instance.status,
  'message': instance.message,
};

RoleChangeResponse _$RoleChangeResponseFromJson(Map<String, dynamic> json) =>
    RoleChangeResponse(
      uid: (json['uid'] as num).toInt(),
      oldRole: (json['old_role'] as num).toInt(),
      newRole: (json['new_role'] as num).toInt(),
      message: json['message'] as String,
    );

Map<String, dynamic> _$RoleChangeResponseToJson(RoleChangeResponse instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'old_role': instance.oldRole,
      'new_role': instance.newRole,
      'message': instance.message,
    };

ContentAddResponse _$ContentAddResponseFromJson(Map<String, dynamic> json) =>
    ContentAddResponse(
      channelId: (json['channel_id'] as num).toInt(),
      channelSectionId: (json['channel_section_id'] as num).toInt(),
      type: json['type'] as String,
      contentId: (json['content_id'] as num).toInt(),
      message: json['message'] as String,
    );

Map<String, dynamic> _$ContentAddResponseToJson(ContentAddResponse instance) =>
    <String, dynamic>{
      'channel_id': instance.channelId,
      'channel_section_id': instance.channelSectionId,
      'type': instance.type,
      'content_id': instance.contentId,
      'message': instance.message,
    };

SectionContentChangeResponse _$SectionContentChangeResponseFromJson(
  Map<String, dynamic> json,
) => SectionContentChangeResponse(
  channelId: (json['channel_id'] as num).toInt(),
  type: json['type'] as String,
  contentId: (json['content_id'] as num).toInt(),
  oldSectionId: (json['old_section_id'] as num).toInt(),
  newSectionId: (json['new_section_id'] as num).toInt(),
  message: json['message'] as String,
);

Map<String, dynamic> _$SectionContentChangeResponseToJson(
  SectionContentChangeResponse instance,
) => <String, dynamic>{
  'channel_id': instance.channelId,
  'type': instance.type,
  'content_id': instance.contentId,
  'old_section_id': instance.oldSectionId,
  'new_section_id': instance.newSectionId,
  'message': instance.message,
};

DeleteSectionResponse _$DeleteSectionResponseFromJson(
  Map<String, dynamic> json,
) => DeleteSectionResponse(
  channelSectionId: (json['channel_section_id'] as num).toInt(),
  channelId: (json['channel_id'] as num).toInt(),
  sectionName: json['section_name'] as String,
  transferredContentCount: (json['transferred_content_count'] as num?)?.toInt(),
  transferToSectionId: (json['transfer_to_section_id'] as num?)?.toInt(),
  message: json['message'] as String,
);

Map<String, dynamic> _$DeleteSectionResponseToJson(
  DeleteSectionResponse instance,
) => <String, dynamic>{
  'channel_section_id': instance.channelSectionId,
  'channel_id': instance.channelId,
  'section_name': instance.sectionName,
  'transferred_content_count': instance.transferredContentCount,
  'transfer_to_section_id': instance.transferToSectionId,
  'message': instance.message,
};

NoticeCreateResponse _$NoticeCreateResponseFromJson(
  Map<String, dynamic> json,
) => NoticeCreateResponse(
  noticeId: (json['notice_id'] as num).toInt(),
  channelId: (json['channel_id'] as num).toInt(),
  title: json['title'] as String?,
  content: json['content'] as String,
  sortOrder: (json['sort_order'] as num).toInt(),
  creatorUid: (json['creator_uid'] as num).toInt(),
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$NoticeCreateResponseToJson(
  NoticeCreateResponse instance,
) => <String, dynamic>{
  'notice_id': instance.noticeId,
  'channel_id': instance.channelId,
  'title': instance.title,
  'content': instance.content,
  'sort_order': instance.sortOrder,
  'creator_uid': instance.creatorUid,
  'created_at': instance.createdAt,
};

NoticeDeleteResponse _$NoticeDeleteResponseFromJson(
  Map<String, dynamic> json,
) => NoticeDeleteResponse(
  noticeId: (json['notice_id'] as num).toInt(),
  channelId: (json['channel_id'] as num).toInt(),
  title: json['title'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$NoticeDeleteResponseToJson(
  NoticeDeleteResponse instance,
) => <String, dynamic>{
  'notice_id': instance.noticeId,
  'channel_id': instance.channelId,
  'title': instance.title,
  'message': instance.message,
};

NoticeSortResponse _$NoticeSortResponseFromJson(Map<String, dynamic> json) =>
    NoticeSortResponse(
      noticeId: (json['notice_id'] as num).toInt(),
      channelId: (json['channel_id'] as num).toInt(),
      sortOrder: (json['sort_order'] as num).toInt(),
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$NoticeSortResponseToJson(NoticeSortResponse instance) =>
    <String, dynamic>{
      'notice_id': instance.noticeId,
      'channel_id': instance.channelId,
      'sort_order': instance.sortOrder,
      'updated_at': instance.updatedAt,
    };
