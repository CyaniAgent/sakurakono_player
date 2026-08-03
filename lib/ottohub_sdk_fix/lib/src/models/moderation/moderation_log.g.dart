// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogUnreadCount _$LogUnreadCountFromJson(Map<String, dynamic> json) =>
    LogUnreadCount(
      unreadCount: (json['unread_count'] as num).toInt(),
      unreadApproved: (json['unread_approved'] as num).toInt(),
      unreadRejected: (json['unread_rejected'] as num).toInt(),
    );

Map<String, dynamic> _$LogUnreadCountToJson(LogUnreadCount instance) =>
    <String, dynamic>{
      'unread_count': instance.unreadCount,
      'unread_approved': instance.unreadApproved,
      'unread_rejected': instance.unreadRejected,
    };

TargetDetail _$TargetDetailFromJson(Map<String, dynamic> json) => TargetDetail(
  type: json['type'] as String,
  targetId: (json['target_id'] as num).toInt(),
  title: json['title'] as String?,
  coverUrl: json['cover_url'] as String?,
  videoUrl: json['video_url'] as String?,
);

Map<String, dynamic> _$TargetDetailToJson(TargetDetail instance) =>
    <String, dynamic>{
      'type': instance.type,
      'target_id': instance.targetId,
      'title': ?instance.title,
      'cover_url': ?instance.coverUrl,
      'video_url': ?instance.videoUrl,
    };

ModerationLog _$ModerationLogFromJson(Map<String, dynamic> json) =>
    ModerationLog(
      logId: (json['log_id'] as num).toInt(),
      operatorUid: (json['operator_uid'] as num).toInt(),
      operatorUsername: json['operator_username'] as String?,
      ownerUid: (json['owner_uid'] as num).toInt(),
      ownerUsername: json['owner_username'] as String?,
      auditType: json['audit_type'] as String,
      action: (json['action'] as num).toInt(),
      rejectReason: json['reject_reason'] as String?,
      targetId: (json['target_id'] as num).toInt(),
      isRead: (json['is_read'] as num).toInt(),
      isUnread: (json['is_unread'] as num).toInt(),
      createdAt: json['created_at'] as String,
      viewRole: json['view_role'] as String?,
      targetDetail: json['target_detail'] == null
          ? null
          : TargetDetail.fromJson(
              json['target_detail'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ModerationLogToJson(ModerationLog instance) =>
    <String, dynamic>{
      'log_id': instance.logId,
      'operator_uid': instance.operatorUid,
      'operator_username': ?instance.operatorUsername,
      'owner_uid': instance.ownerUid,
      'owner_username': ?instance.ownerUsername,
      'audit_type': instance.auditType,
      'action': instance.action,
      'reject_reason': ?instance.rejectReason,
      'target_id': instance.targetId,
      'is_read': instance.isRead,
      'is_unread': instance.isUnread,
      'created_at': instance.createdAt,
      'view_role': ?instance.viewRole,
      'target_detail': ?instance.targetDetail,
    };

ModerationLogListData _$ModerationLogListDataFromJson(
  Map<String, dynamic> json,
) => ModerationLogListData(
  role: json['role'] as String,
  isAdmin: (json['is_admin'] as num).toInt(),
  isAudit: (json['is_audit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  num: (json['num'] as num).toInt(),
  logs: (json['logs'] as List<dynamic>)
      .map((e) => ModerationLog.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ModerationLogListDataToJson(
  ModerationLogListData instance,
) => <String, dynamic>{
  'role': instance.role,
  'is_admin': instance.isAdmin,
  'is_audit': instance.isAudit,
  'offset': instance.offset,
  'num': instance.num,
  'logs': instance.logs,
};
