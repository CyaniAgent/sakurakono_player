import 'package:json_annotation/json_annotation.dart';

part 'channel_responses.g.dart';

/// 更新频道响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateChannelResponse {
  final int channelId;
  final String updatedAt;

  const UpdateChannelResponse({
    required this.channelId,
    required this.updatedAt,
  });

  factory UpdateChannelResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateChannelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateChannelResponseToJson(this);
}

/// 删除频道响应，包含操作前的内容计数。
@JsonSerializable(fieldRename: FieldRename.snake)
class DeleteChannelResponse {
  final int videoCount;
  final int blogCount;
  final int totalContent;

  const DeleteChannelResponse({
    required this.videoCount,
    required this.blogCount,
    required this.totalContent,
  });

  factory DeleteChannelResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteChannelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteChannelResponseToJson(this);
}

/// 成员操作（踢出/审核）响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class MemberActionResponse {
  final int channelId;
  final int uid;
  final int status;
  final String message;

  const MemberActionResponse({
    required this.channelId,
    required this.uid,
    required this.status,
    required this.message,
  });

  factory MemberActionResponse.fromJson(Map<String, dynamic> json) =>
      _$MemberActionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MemberActionResponseToJson(this);
}

/// 角色变更响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class RoleChangeResponse {
  final int uid;
  final int oldRole;
  final int newRole;
  final String message;

  const RoleChangeResponse({
    required this.uid,
    required this.oldRole,
    required this.newRole,
    required this.message,
  });

  factory RoleChangeResponse.fromJson(Map<String, dynamic> json) =>
      _$RoleChangeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RoleChangeResponseToJson(this);
}

/// 内容添加响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class ContentAddResponse {
  final int channelId;
  final int channelSectionId;
  final String type;
  final int contentId;
  final String message;

  const ContentAddResponse({
    required this.channelId,
    required this.channelSectionId,
    required this.type,
    required this.contentId,
    required this.message,
  });

  factory ContentAddResponse.fromJson(Map<String, dynamic> json) =>
      _$ContentAddResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ContentAddResponseToJson(this);
}

/// 内容迁移栏目响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class SectionContentChangeResponse {
  final int channelId;
  final String type;
  final int contentId;
  final int oldSectionId;
  final int newSectionId;
  final String message;

  const SectionContentChangeResponse({
    required this.channelId,
    required this.type,
    required this.contentId,
    required this.oldSectionId,
    required this.newSectionId,
    required this.message,
  });

  factory SectionContentChangeResponse.fromJson(Map<String, dynamic> json) =>
      _$SectionContentChangeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SectionContentChangeResponseToJson(this);
}

/// 删除栏目响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class DeleteSectionResponse {
  final int channelSectionId;
  final int channelId;
  final String sectionName;
  final int? transferredContentCount;
  final int? transferToSectionId;
  final String message;

  const DeleteSectionResponse({
    required this.channelSectionId,
    required this.channelId,
    required this.sectionName,
    this.transferredContentCount,
    this.transferToSectionId,
    required this.message,
  });

  factory DeleteSectionResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteSectionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteSectionResponseToJson(this);
}

/// 创建公告响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class NoticeCreateResponse {
  final int noticeId;
  final int channelId;
  final String? title;
  final String content;
  final int sortOrder;
  final int creatorUid;
  final String createdAt;

  const NoticeCreateResponse({
    required this.noticeId,
    required this.channelId,
    this.title,
    required this.content,
    required this.sortOrder,
    required this.creatorUid,
    required this.createdAt,
  });

  factory NoticeCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$NoticeCreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeCreateResponseToJson(this);
}

/// 删除公告响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class NoticeDeleteResponse {
  final int noticeId;
  final int channelId;
  final String title;
  final String message;

  const NoticeDeleteResponse({
    required this.noticeId,
    required this.channelId,
    required this.title,
    required this.message,
  });

  factory NoticeDeleteResponse.fromJson(Map<String, dynamic> json) =>
      _$NoticeDeleteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeDeleteResponseToJson(this);
}

/// 公告排序响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class NoticeSortResponse {
  final int noticeId;
  final int channelId;
  final int sortOrder;
  final String updatedAt;

  const NoticeSortResponse({
    required this.noticeId,
    required this.channelId,
    required this.sortOrder,
    required this.updatedAt,
  });

  factory NoticeSortResponse.fromJson(Map<String, dynamic> json) =>
      _$NoticeSortResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeSortResponseToJson(this);
}
