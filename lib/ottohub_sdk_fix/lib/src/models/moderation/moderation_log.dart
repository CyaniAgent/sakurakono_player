import 'package:json_annotation/json_annotation.dart';

part 'moderation_log.g.dart';

/// 审核日志未读数统计。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class LogUnreadCount {
  final int unreadCount;
  final int unreadApproved;
  final int unreadRejected;

  const LogUnreadCount({
    required this.unreadCount,
    required this.unreadApproved,
    required this.unreadRejected,
  });

  factory LogUnreadCount.fromJson(Map<String, dynamic> json) =>
      _$LogUnreadCountFromJson(json);

  Map<String, dynamic> toJson() => _$LogUnreadCountToJson(this);
}

/// 审核日志目标内容详情。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TargetDetail {
  final String type;
  final int targetId;
  final String? title;
  final String? coverUrl;
  final String? videoUrl;

  const TargetDetail({
    required this.type,
    required this.targetId,
    this.title,
    this.coverUrl,
    this.videoUrl,
  });

  factory TargetDetail.fromJson(Map<String, dynamic> json) =>
      _$TargetDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TargetDetailToJson(this);
}

/// 审核操作日志。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ModerationLog {
  final int logId;
  final int operatorUid;
  final String? operatorUsername;
  final int ownerUid;
  final String? ownerUsername;
  final String auditType;
  final int action;
  final String? rejectReason;
  final int targetId;
  final int isRead;
  final int isUnread;
  final String createdAt;
  final String? viewRole;
  final TargetDetail? targetDetail;

  const ModerationLog({
    required this.logId,
    required this.operatorUid,
    this.operatorUsername,
    required this.ownerUid,
    this.ownerUsername,
    required this.auditType,
    required this.action,
    this.rejectReason,
    required this.targetId,
    required this.isRead,
    required this.isUnread,
    required this.createdAt,
    this.viewRole,
    this.targetDetail,
  });

  factory ModerationLog.fromJson(Map<String, dynamic> json) =>
      _$ModerationLogFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationLogToJson(this);
}

/// 审核日志列表响应。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ModerationLogListData {
  final String role;
  final int isAdmin;
  final int isAudit;
  final int offset;
  final int num;
  final List<ModerationLog> logs;

  const ModerationLogListData({
    required this.role,
    required this.isAdmin,
    required this.isAudit,
    required this.offset,
    required this.num,
    required this.logs,
  });

  factory ModerationLogListData.fromJson(Map<String, dynamic> json) =>
      _$ModerationLogListDataFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationLogListDataToJson(this);
}
