import 'package:dio/dio.dart' show DioException;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
// ignore: implementation_imports
import 'package:ottohub_sdk_dart/src/models/old_api/old_comment_models.dart'
    show BlogComment, VideoComment;

/// Implementation of [ReplyRepository] that delegates to OttoHub SDK APIs.
///
/// Uses [IOldCommentApi] for comment operations (list, post, delete, report).
///
/// Note: Core reply types ([CoreMainListReply], [CoreDetailListReply]) are
/// gRPC-based wrappers with [Object?] reply lists. OttoHub adapter returns
/// raw comment map data cast to Object? to match the interface.
class OttoReplyRepository implements ReplyRepository {
  final OttohubClient _client;

  OttoReplyRepository(this._client);
  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  /// 评论翻页超出末页:服务端报 400。
  bool _isNoMoreReplies(ApiException e) => e.httpStatus == 400;

  /// 兜底:HTTP 层异常(超时/连接失败/未包装的 DioException)转为
  /// Error 态,避免调用方面对一个永不完成的 Future。
  LoadingState<T> _dioErr<T>(DioException e) {
    debugPrint('OttoReplyRepository DioException: ${e.type} ${e.message}');
    return Error('网络错误: ${e.message ?? e.type.name}',
        code: e.response?.statusCode);
  }

  @override
  Future<LoadingState<CoreMainListReply>> mainList({
    int type = 1,
    required int oid,
    required CoreMode mode,
    required String? offset,
    required int? cursorNext,
  }) async {
    // 服务端在 offset 超出末页时返回 400(而非空列表):视为「没有更多」。
    Future<List<dynamic>> fetch() => type == 2
        ? _client.oldComment.getVideoCommentList(
            vid: oid,
            offset: offset != null ? int.tryParse(offset) : null,
            num: 20,
          )
        : _client.oldComment.getBlogCommentList(
            bid: oid,
            offset: offset != null ? int.tryParse(offset) : null,
            num: 20,
          );
    try {
      final comments = await fetch();
      return Success(CoreMainListReply(replies: _replyMaps(comments)));
    } on ApiException catch (e) {
      // 非首屏翻页遇 400 = 已到末页,返回空列表而非错误态。
      if (e.httpStatus == 400 && offset != null) {
        return const Success(CoreMainListReply(replies: []));
      }
      debugPrint('OttoReplyRepository.mainList ApiException: ${e.errorCode}');
      return _err(e);
    } on DioException catch (e) {
      return _dioErr(e);
    }
  }

  /// SDK 强类型评论 → gRPC 形态 map(供 CoreReplyItem.fromMap 消费)。
  /// 博客评论带 bcid,视频评论带 vcid(无 bcid getter,动态调用会抛)。
  List<Map<String, dynamic>> _replyMaps(List<dynamic> comments) => comments
      .map(
        (c) => <String, dynamic>{
          'rpid': _replyId(c),
          'content': {'message': c.content},
          'mid': c.uid,
          'member': {
            'mid': c.uid,
            'uname': c.username ?? '',
            'avatar': c.avatarUrl ?? '',
          },
          'like': 0,
          'rcount': c.childCommentNum ?? 0,
          'ctime': _parseTime(c.time),
        },
      )
      .toList();

  static int _replyId(dynamic c) =>
      c is BlogComment ? c.bcid : (c as VideoComment).vcid;



  @override
  Future<LoadingState<CoreDetailListReply>> detailList({
    int type = 1,
    required int oid,
    required int root,
    required int rpid,
    required CoreMode mode,
    required String? offset,
  }) async {
    // SDK 返回强类型评论列表;键名与 gRPC 形态不同(vcid/uid/time/
    // username/avatar_url/child_comment_num),显式映射成
    // CoreReplyItem.fromMap 认的形状回填 `replies`。
    List<Map<String, dynamic>> toMaps(List<dynamic> comments) => comments
        .map((raw) {
          final c = (raw as dynamic).toJson() as Map<String, dynamic>;
          final id = (c['vcid'] ?? c['bcid']) as int? ?? 0;
          final uid = c['uid'] as int? ?? 0;
          return <String, dynamic>{
            'rpid': id,
            'oid': oid,
            'type': type,
            'mid': uid,
            'root': root,
            'parent': (c['parent_vcid'] ?? c['parent_bcid']) as int? ?? 0,
            'content': c['content'],
            'ctime': _parseTime(c['time'] as String? ?? ''),
            'rcount': c['child_comment_num'],
            'member': <String, dynamic>{
              'mid': uid,
              'uname': c['username'],
              'avatar': c['avatar_url'],
            },
          };
        })
        .toList();
    try {
      if (type == 2) {
        final comments = await _client.oldComment.getVideoCommentList(
          vid: oid,
          parentVcid: root,
          offset: offset != null ? int.tryParse(offset) : null,
          num: 20,
        );
        return Success(CoreDetailListReply(
          root: <String, dynamic>{
            'rpid': root,
          },
          replies: toMaps(comments),
          cursor: <String, dynamic>{
            'is_end': comments.length < 20,
          },
        ));
      } else {
        final comments = await _client.oldComment.getBlogCommentList(
          bid: oid,
          parentBcid: root,
          offset: offset != null ? int.tryParse(offset) : null,
          num: 20,
        );
        return Success(CoreDetailListReply(
          root: <String, dynamic>{
            'rpid': root,
          },
          replies: toMaps(comments),
          cursor: <String, dynamic>{
            'is_end': comments.length < 20,
          },
        ));
      }
    } on ApiException catch (e) {
      // 无更多子评论时服务端报 400:返回空列表而非错误态。
      if (_isNoMoreReplies(e)) {
        return Success(const CoreDetailListReply(replies: []));
      }
      debugPrint(
        'OttoReplyRepository.detailList ApiException: ${e.errorCode}',
      );
      return _err(e);
    } on DioException catch (e) {
      return _dioErr(e);
    }
  }

  @override
  Future<LoadingState<CoreDialogListReply>> dialogList({
    int type = 1,
    required int oid,
    required int root,
    required int dialog,
    required String? offset,
  }) async {
    // no SDK API — SDK 缺 dialogList 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreSearchItemReply>> searchItem({
    required int page,
    required CoreSearchItemType itemType,
    required int oid,
    int type = 1,
    String? keyword,
  }) async {
    // no SDK API — SDK 缺 searchItem 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreTranslateReplyResp>> translateReply({
    required int type,
    required int oid,
    required int rpid,
  }) async {
    // no SDK API — SDK 缺 translateReply 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> replyTop({
    required int oid,
    required int type,
    required String rpid,
    required bool isUpTop,
  }) async {
    // no SDK API — SDK 缺 replyTop 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> replySubjectModify({
    required int oid,
    required int type,
    required int action,
  }) async {
    // no SDK API — SDK 缺 replySubjectModify 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreReplyInfo?>> replyAdd({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    List? pictures,
    bool syncToDynamic = false,
    Map<String, int>? atNameToMid,
  }) async {
    try {
      if (type == 2) {
        await _client.oldComment.commentVideo(
          vid: oid,
          content: message,
          parentVcid: parent ?? 0,
        );
      } else {
        await _client.oldComment.commentBlog(
          bid: oid,
          content: message,
          parentBcid: parent ?? 0,
        );
      }
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoReplyRepository.replyAdd ApiException: ${e.errorCode}');
      return _err(e);
    } on DioException catch (e) {
      return _dioErr(e);
    }
  }

  @override
  Future<LoadingState<void>> likeReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  }) async {
    // no SDK API — SDK 缺 likeReply 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> hateReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  }) async {
    // no SDK API — SDK 缺 hateReply 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> report({
    required String rpid,
    required String oid,
    required int reasonType,
    bool banUid = true,
    String? reasonDesc,
  }) async {
    final vcid = int.tryParse(rpid);
    if (vcid == null) {
      return const Error('OttoHub: 无法解析评论ID');
    }
    try {
      // Core report has no type param — video-comment report (mapping: oldComment.reportVideoComment).
      await _client.oldComment.reportVideoComment(
        vcid,
        reason: reasonDesc ?? '',
      );
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoReplyRepository.report ApiException: ${e.errorCode}');
      return _err(e);
    } on DioException catch (e) {
      return _dioErr(e);
    }
  }

  @override
  Future<LoadingState<dynamic>> getEmoteList({String? business}) async {
    // no SDK API — SDK 缺 getEmoteList 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> replyDel({
    required int type,
    required int oid,
    required int rpid,
  }) async {
    try {
      if (type == 2) {
        await _client.oldComment.deleteVideoComment(rpid);
      } else {
        await _client.oldComment.deleteBlogComment(rpid);
      }
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoReplyRepository.replyDel ApiException: ${e.errorCode}');
      return _err(e);
    } on DioException catch (e) {
      return _dioErr(e);
    }
  }

  /// Parse OttoHub time string (e.g. "2024-01-15 10:30:00") to Unix timestamp.
  int _parseTime(String time) {
    try {
      return DateTime.parse(time).millisecondsSinceEpoch ~/ 1000;
    } catch (e) {
      debugPrint('OttoReplyRepository._parseTime error: $e');
      return 0;
    }
  }
}
