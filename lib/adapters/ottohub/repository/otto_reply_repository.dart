import 'package:flutter/foundation.dart' show debugPrint;
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';

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

  @override
  Future<LoadingState<CoreMainListReply>> mainList({
    int type = 1,
    required int oid,
    required CoreMode mode,
    required String? offset,
    required int? cursorNext,
  }) async {
    try {
      if (type == 2) {
        // video comment
        final comments = await _client.oldComment.getVideoCommentList(
          vid: oid,
          offset: offset != null ? int.tryParse(offset) : null,
          num: 20,
        );
        return Success(CoreMainListReply(
          replies: comments
              .map((c) => <String, dynamic>{
                    'rpid': c.vcid,
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
                  })
              .toList(),
        ));
      } else {
        // blog comment (type 1)
        final comments = await _client.oldComment.getBlogCommentList(
          bid: oid,
          offset: offset != null ? int.tryParse(offset) : null,
          num: 20,
        );
        return Success(CoreMainListReply(
          replies: comments
              .map((c) => <String, dynamic>{
                    'rpid': c.bcid,
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
                  })
              .toList(),
        ));
      }
    } on ApiException catch (e) {
      debugPrint('OttoReplyRepository.mainList ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreDetailListReply>> detailList({
    int type = 1,
    required int oid,
    required int root,
    required int rpid,
    required CoreMode mode,
    required String? offset,
  }) async {
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
            'rpid': rpid,
          },
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
            'rpid': rpid,
          },
          cursor: <String, dynamic>{
            'is_end': comments.length < 20,
          },
        ));
      }
    } on ApiException catch (e) {
      debugPrint('OttoReplyRepository.detailList ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
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
      return Error(e.errorCode, code: e.httpStatus);
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
      return Error(e.errorCode, code: e.httpStatus);
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
      return Error(e.errorCode, code: e.httpStatus);
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
