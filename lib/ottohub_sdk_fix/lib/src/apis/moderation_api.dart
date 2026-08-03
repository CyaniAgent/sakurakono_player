import '../base_api.dart';
import '../models/moderation/moderation_item.dart';
import '../models/moderation/moderation_log.dart';

/// 审核模块接口。
///
/// 提供审核列表查看、审批/驳回、举报、申诉、审核日志功能。
/// 需要审核员或管理员权限。
abstract class IModerationApi {
  /// 获取待审核视频列表。
  Future<List<ModerationVideo>> getVideoList({int? offset, int? num});

  /// 获取待审核博客列表。
  Future<List<ModerationBlog>> getBlogList({int? offset, int? num});

  /// 获取待审核头像列表。
  Future<List<ModerationAvatar>> getAvatarList({int? offset, int? num});

  /// 获取待审核封面列表。
  Future<List<ModerationCover>> getCoverList({int? offset, int? num});

  /// 获取待审核弹幕列表。
  Future<List<ModerationDanmaku>> getDanmakuList({int? offset, int? num});

  /// 获取待审核视频评论列表。
  Future<List<ModerationVideoComment>> getVideoCommentList({int? offset, int? num});

  /// 获取待审核博客评论列表。
  Future<List<ModerationBlogComment>> getBlogCommentList({int? offset, int? num});

  /// 审批通过视频。
  Future<void> approveVideo(int vid);

  /// 审批通过博客。
  Future<void> approveBlog(int bid);

  /// 审批通过头像。
  Future<void> approveAvatar(int uid);

  /// 审批通过封面。
  Future<void> approveCover(int uid);

  /// 审批通过弹幕。
  Future<void> approveDanmaku(int danmakuId);

  /// 审批通过视频评论。
  Future<void> approveVideoComment(int vcid);

  /// 审批通过博客评论。
  Future<void> approveBlogComment(int bcid);

  /// 驳回视频。
  Future<void> rejectVideo(int vid, {required String reason});

  /// 驳回博客。
  Future<void> rejectBlog(int bid, {required String reason});

  /// 驳回头像。
  Future<void> rejectAvatar(int uid, {required String reason});

  /// 驳回封面。
  Future<void> rejectCover(int uid, {required String reason});

  /// 驳回弹幕。
  Future<void> rejectDanmaku(int danmakuId, {required String reason});

  /// 驳回视频评论。
  Future<void> rejectVideoComment(int vcid, {required String reason});

  /// 驳回博客评论。
  Future<void> rejectBlogComment(int bcid, {required String reason});

  /// 举报视频。
  Future<void> reportVideo(int vid, {required String reason});

  /// 举报博客。
  Future<void> reportBlog(int bid, {required String reason});

  /// 举报头像。
  Future<void> reportAvatar(int uid, {required String reason});

  /// 举报封面。
  Future<void> reportCover(int uid, {required String reason});

  /// 举报弹幕。
  Future<void> reportDanmaku(int danmakuId, {required String reason});

  /// 举报视频评论。
  Future<void> reportVideoComment(int vcid, {required String reason});

  /// 举报博客评论。
  Future<void> reportBlogComment(int bcid, {required String reason});

  /// 申诉视频。
  Future<void> appealVideo(int vid, {required String reason});

  /// 申诉博客。
  Future<void> appealBlog(int bid, {required String reason});

  /// 申诉头像。
  Future<void> appealAvatar(int uid, {required String reason});

  /// 申诉封面。
  Future<void> appealCover(int uid, {required String reason});

  /// 申诉弹幕。
  Future<void> appealDanmaku(int danmakuId, {required String reason});

  /// 申诉视频评论。
  Future<void> appealVideoComment(int vcid, {required String reason});

  /// 申诉博客评论。
  Future<void> appealBlogComment(int bcid, {required String reason});

  /// 获取未读审核日志数量。
  Future<LogUnreadCount> getUnreadCount({int? isAdmin, int? isAudit});

  /// 获取审核日志列表。
  ///
  /// [auditType]: 审核类型过滤。
  /// [action]: 操作类型过滤。
  /// [isRead]: 是否已读。
  Future<ModerationLogListData> getLogs({int? offset, int? num, String? auditType, int? action, int? isRead, int? isAdmin, int? isAudit});
}

class ModerationApi extends BaseApi implements IModerationApi {
  ModerationApi(super.dio, super.getToken, {super.config});

  // ── Lists ──

  @override
  Future<List<ModerationVideo>> getVideoList({int? offset, int? num}) async {
    final response = await get('/moderation/videos', queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final list = (response['data'] as Map<String, dynamic>)['video_list']
        as List<dynamic>;
    return list
        .map((e) => ModerationVideo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModerationBlog>> getBlogList({int? offset, int? num}) async {
    final response = await get('/moderation/blogs', queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final list = (response['data'] as Map<String, dynamic>)['blog_list']
        as List<dynamic>;
    return list
        .map((e) => ModerationBlog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModerationAvatar>> getAvatarList({int? offset, int? num}) async {
    final response = await get('/moderation/avatars', queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final list = (response['data'] as Map<String, dynamic>)['avatar_list']
        as List<dynamic>;
    return list
        .map((e) => ModerationAvatar.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModerationCover>> getCoverList({int? offset, int? num}) async {
    final response = await get('/moderation/covers', queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final list = (response['data'] as Map<String, dynamic>)['cover_list']
        as List<dynamic>;
    return list
        .map((e) => ModerationCover.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModerationDanmaku>> getDanmakuList(
      {int? offset, int? num}) async {
    final response = await get('/moderation/danmakus', queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final list = (response['data'] as Map<String, dynamic>)['danmaku_list']
        as List<dynamic>;
    return list
        .map((e) => ModerationDanmaku.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModerationVideoComment>> getVideoCommentList(
      {int? offset, int? num}) async {
    final response =
        await get('/moderation/video-comments', queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final list = (response['data'] as Map<String, dynamic>)['comment_list']
        as List<dynamic>;
    return list
        .map((e) =>
            ModerationVideoComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModerationBlogComment>> getBlogCommentList(
      {int? offset, int? num}) async {
    final response =
        await get('/moderation/blog-comments', queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final list = (response['data'] as Map<String, dynamic>)['comment_list']
        as List<dynamic>;
    return list
        .map((e) =>
            ModerationBlogComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Approve ──

  @override
  Future<void> approveVideo(int vid) async {
    await put('/moderation/videos/$vid/approve');
  }

  @override
  Future<void> approveBlog(int bid) async {
    await put('/moderation/blogs/$bid/approve');
  }

  @override
  Future<void> approveAvatar(int uid) async {
    await put('/moderation/avatars/$uid/approve');
  }

  @override
  Future<void> approveCover(int uid) async {
    await put('/moderation/covers/$uid/approve');
  }

  @override
  Future<void> approveDanmaku(int danmakuId) async {
    await put('/moderation/danmakus/$danmakuId/approve');
  }

  @override
  Future<void> approveVideoComment(int vcid) async {
    await put('/moderation/video-comments/$vcid/approve');
  }

  @override
  Future<void> approveBlogComment(int bcid) async {
    await put('/moderation/blog-comments/$bcid/approve');
  }

  // ── Reject ──

  @override
  Future<void> rejectVideo(int vid, {required String reason}) async {
    await put('/moderation/videos/$vid/reject', data: {'reason': reason});
  }

  @override
  Future<void> rejectBlog(int bid, {required String reason}) async {
    await put('/moderation/blogs/$bid/reject', data: {'reason': reason});
  }

  @override
  Future<void> rejectAvatar(int uid, {required String reason}) async {
    await put('/moderation/avatars/$uid/reject', data: {'reason': reason});
  }

  @override
  Future<void> rejectCover(int uid, {required String reason}) async {
    await put('/moderation/covers/$uid/reject', data: {'reason': reason});
  }

  @override
  Future<void> rejectDanmaku(int danmakuId, {required String reason}) async {
    await put('/moderation/danmakus/$danmakuId/reject',
        data: {'reason': reason});
  }

  @override
  Future<void> rejectVideoComment(int vcid, {required String reason}) async {
    await put('/moderation/video-comments/$vcid/reject',
        data: {'reason': reason});
  }

  @override
  Future<void> rejectBlogComment(int bcid, {required String reason}) async {
    await put('/moderation/blog-comments/$bcid/reject',
        data: {'reason': reason});
  }

  // ── Report ──

  @override
  Future<void> reportVideo(int vid, {required String reason}) async {
    await post('/moderation/videos/$vid/report', data: {'reason': reason});
  }

  @override
  Future<void> reportBlog(int bid, {required String reason}) async {
    await post('/moderation/blogs/$bid/report', data: {'reason': reason});
  }

  @override
  Future<void> reportAvatar(int uid, {required String reason}) async {
    await post('/moderation/avatars/$uid/report', data: {'reason': reason});
  }

  @override
  Future<void> reportCover(int uid, {required String reason}) async {
    await post('/moderation/covers/$uid/report', data: {'reason': reason});
  }

  @override
  Future<void> reportDanmaku(int danmakuId, {required String reason}) async {
    await post('/moderation/danmakus/$danmakuId/report',
        data: {'reason': reason});
  }

  @override
  Future<void> reportVideoComment(int vcid, {required String reason}) async {
    await post('/moderation/video-comments/$vcid/report',
        data: {'reason': reason});
  }

  @override
  Future<void> reportBlogComment(int bcid, {required String reason}) async {
    await post('/moderation/blog-comments/$bcid/report',
        data: {'reason': reason});
  }

  // ── Appeal ──

  @override
  Future<void> appealVideo(int vid, {required String reason}) async {
    await post('/moderation/videos/$vid/appeal', data: {'reason': reason});
  }

  @override
  Future<void> appealBlog(int bid, {required String reason}) async {
    await post('/moderation/blogs/$bid/appeal', data: {'reason': reason});
  }

  @override
  Future<void> appealAvatar(int uid, {required String reason}) async {
    await post('/moderation/avatars/$uid/appeal', data: {'reason': reason});
  }

  @override
  Future<void> appealCover(int uid, {required String reason}) async {
    await post('/moderation/covers/$uid/appeal', data: {'reason': reason});
  }

  @override
  Future<void> appealDanmaku(int danmakuId, {required String reason}) async {
    await post('/moderation/danmakus/$danmakuId/appeal',
        data: {'reason': reason});
  }

  @override
  Future<void> appealVideoComment(int vcid, {required String reason}) async {
    await post('/moderation/video-comments/$vcid/appeal',
        data: {'reason': reason});
  }

  @override
  Future<void> appealBlogComment(int bcid, {required String reason}) async {
    await post('/moderation/blog-comments/$bcid/appeal',
        data: {'reason': reason});
  }

  // ── Logs ──

  @override
  Future<LogUnreadCount> getUnreadCount({
    int? isAdmin,
    int? isAudit,
  }) async {
    final response = await get('/moderation/logs/unread-count',
        queryParameters: {
          'is_admin': ?isAdmin,
          'is_audit': ?isAudit,
        });
    return LogUnreadCount.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<ModerationLogListData> getLogs({
    int? offset,
    int? num,
    String? auditType,
    int? action,
    int? isRead,
    int? isAdmin,
    int? isAudit,
  }) async {
    final response = await get('/moderation/logs', queryParameters: {
      'offset': ?offset,
      'num': ?num,
      'audit_type': ?auditType,
      'action': ?action,
      'is_read': ?isRead,
      'is_admin': ?isAdmin,
      'is_audit': ?isAudit,
    });
    return ModerationLogListData.fromJson(
        response['data'] as Map<String, dynamic>);
  }
}
