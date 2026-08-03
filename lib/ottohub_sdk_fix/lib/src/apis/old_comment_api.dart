import '../base_api.dart';
import '../models/old_api/old_comment_models.dart';

/// 旧版评论模块接口。
abstract class IOldCommentApi {
  /// 获取博客评论列表。
  Future<List<BlogComment>> getBlogCommentList({required int bid, int? parentBcid, int? offset, int? num, int? cidAsc});

  /// 获取视频评论列表。
  Future<List<VideoComment>> getVideoCommentList({required int vid, int? parentVcid, int? offset, int? num, int? cidAsc});

  /// 评论博客。
  Future<CommentResult> commentBlog({required int bid, required int parentBcid, required String content});

  /// 评论视频。
  Future<CommentResult> commentVideo({required int vid, required int parentVcid, required String content});

  /// 删除博客评论。
  Future<void> deleteBlogComment(int bcid);

  /// 删除视频评论。
  Future<void> deleteVideoComment(int vcid);

  /// 举报博客评论。
  Future<void> reportBlogComment(int bcid, {required String reason});

  /// 举报视频评论。
  Future<void> reportVideoComment(int vcid, {required String reason});

  /// 获取待审核博客评论列表。
  Future<List<AuditBlogComment>> getAuditBlogCommentList({int? offset, int? num});

  /// 获取待审核视频评论列表。
  Future<List<AuditVideoComment>> getAuditVideoCommentList({int? offset, int? num});

  /// 审批通过博客评论。
  Future<void> approveBlogComment(int bcid);

  /// 审批通过视频评论。
  Future<void> approveVideoComment(int vcid);

  /// 驳回博客评论。
  Future<void> rejectBlogComment(int bcid, {required String reason});

  /// 驳回视频评论。
  Future<void> rejectVideoComment(int vcid, {required String reason});
}

class OldCommentApi extends BaseApi implements IOldCommentApi {
  OldCommentApi(super.dio, super.getToken, {super.config});

  @override
  Future<List<BlogComment>> getBlogCommentList({
    required int bid,
    int? parentBcid,
    int? offset,
    int? num,
    int? cidAsc,
  }) async {
    final response = await get('/comment/blog_comment_list', queryParameters: {
      'bid': bid,
      'parent_bcid': ?parentBcid,
      'offset': ?offset,
      'num': ?num,
      'cid_asc': ?cidAsc,
    });
    final list = (response['data'] as Map<String, dynamic>)['comment_list']
        as List<dynamic>;
    return list.map((e) => BlogComment.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<VideoComment>> getVideoCommentList({
    required int vid,
    int? parentVcid,
    int? offset,
    int? num,
    int? cidAsc,
  }) async {
    final response = await get('/comment/video_comment_list', queryParameters: {
      'vid': vid,
      'parent_vcid': ?parentVcid,
      'offset': ?offset,
      'num': ?num,
      'cid_asc': ?cidAsc,
    });
    final list = (response['data'] as Map<String, dynamic>)['comment_list']
        as List<dynamic>;
    return list.map((e) => VideoComment.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<CommentResult> commentBlog({
    required int bid,
    required int parentBcid,
    required String content,
  }) async {
    final response = await post('/comment/comment_blog', data: {
      'bid': bid,
      'parent_bcid': parentBcid,
      'content': content,
    });
    return CommentResult.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<CommentResult> commentVideo({
    required int vid,
    required int parentVcid,
    required String content,
  }) async {
    final response = await post('/comment/comment_video', data: {
      'vid': vid,
      'parent_vcid': parentVcid,
      'content': content,
    });
    return CommentResult.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteBlogComment(int bcid) async {
    await post('/comment/delete_blog_comment', data: {'bcid': bcid});
  }

  @override
  Future<void> deleteVideoComment(int vcid) async {
    await post('/comment/delete_video_comment', data: {'vcid': vcid});
  }

  @override
  Future<void> reportBlogComment(int bcid, {required String reason}) async {
    await post('/comment/report_blog_comment',
        data: {'bcid': bcid, 'reason': reason});
  }

  @override
  Future<void> reportVideoComment(int vcid, {required String reason}) async {
    await post('/comment/report_video_comment',
        data: {'vcid': vcid, 'reason': reason});
  }

  @override
  Future<List<AuditBlogComment>> getAuditBlogCommentList({
    int? offset,
    int? num,
  }) async {
    final response = await get('/comment/audit_blog_comment_list',
        queryParameters: {
          'offset': ?offset,
          'num': ?num,
        });
    final list = (response['data'] as Map<String, dynamic>)['comment_list']
        as List<dynamic>;
    return list
        .map((e) => AuditBlogComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AuditVideoComment>> getAuditVideoCommentList({
    int? offset,
    int? num,
  }) async {
    final response = await get('/comment/audit_video_comment_list',
        queryParameters: {
          'offset': ?offset,
          'num': ?num,
        });
    final list = (response['data'] as Map<String, dynamic>)['comment_list']
        as List<dynamic>;
    return list
        .map((e) => AuditVideoComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> approveBlogComment(int bcid) async {
    await put('/comment/approve_blog_comment', data: {'bcid': bcid});
  }

  @override
  Future<void> approveVideoComment(int vcid) async {
    await put('/comment/approve_video_comment', data: {'vcid': vcid});
  }

  @override
  Future<void> rejectBlogComment(int bcid, {required String reason}) async {
    await put('/comment/reject_blog_comment',
        data: {'bcid': bcid, 'reason': reason});
  }

  @override
  Future<void> rejectVideoComment(int vcid, {required String reason}) async {
    await put('/comment/reject_video_comment',
        data: {'vcid': vcid, 'reason': reason});
  }
}
