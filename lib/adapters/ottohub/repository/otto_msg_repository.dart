import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';

/// Implementation of [MsgRepository] that delegates to OttoHub SDK APIs.
///
/// Uses [IOldImApi] for IM messaging operations.
class OttoMsgRepository implements MsgRepository {
  final OttohubClient _client;

  OttoMsgRepository(this._client);

  // ---- helpers ----

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  
  /// OttoHub 时间字符串("2026-09-17 23:58:05")→ Unix 秒。
  static int _parseTime(String? time) {
    final t = DateTime.tryParse(time ?? '');
    if (t == null) return 0;
    return t.millisecondsSinceEpoch ~/ 1000;
  }

  /// 通知跳转路由:1=视频 /videoV?aid=,2=博客 /blogDetail?bid=。
  static String? _dynUri(int? contentType, int? contentId) {
    if (contentId == null || contentId <= 0) return null;
    return contentType == 2
        ? '/blogDetail?bid=$contentId'
        : '/videoV?aid=$contentId';
  }

  static CoreUser _noticeUser(IMNoticeItem n) => CoreUser(
        mid: n.senderUid ?? n.mid,
        nickname: n.senderUsername ?? '',
        avatar: n.senderAvatarUrl ?? '',
      );

  @override
  Future<LoadingState<CoreMsgReplyData>> msgFeedReplyMe({
    int? cursor,
    int? cursorTime,
  }) async {
    try {
      // cursor 即 offset(kind 不传 = 评论+回复都收)。
      final list = await _client.oldIm.getCommentReplies(
        offset: cursor ?? 0,
        num: 20,
      );
      return Success(CoreMsgReplyData(
        cursor: CoreCursor(
          isEnd: list.length < 20,
          id: (cursor ?? 0) + list.length,
        ),
        items: list
            .map((n) => CoreMsgReplyItem(
                  id: n.rid ?? n.senderUid,
                  user: _noticeUser(n),
                  item: CoreMsgReplyContent(
                    // OttoHub:content_type 1=视频 2=博客;businessId 即 vid/bid。
                    subjectId: n.contentId,
                    businessId: n.contentId,
                    business: switch (n.contentType) {
                      2 => 'blog',
                      _ => 'video',
                    },
                    // kind 1=评论(源内容即目标) 2=回复(源=根,目标=被回复)。
                    rootReplyContent: n.kind == 2 ? n.contentTitle : null,
                    sourceContent: n.content,
                    targetReplyContent: n.kind == 2 ? n.content : n.contentTitle,
                  ),
                  counts: 1,
                  replyTime: _parseTime(n.time),
                ))
            .toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.msgFeedReplyMe ApiException: \${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreMsgAtData>> msgFeedAtMe({
    int? cursor,
    int? cursorTime,
  }) async {
    try {
      final list = await _client.oldIm.getMentions(offset: cursor ?? 0, num: 20);
      return Success(CoreMsgAtData(
        cursor: CoreCursor(
          isEnd: list.length < 20,
          id: (cursor ?? 0) + list.length,
        ),
        items: list
            .map((n) => CoreMsgAtItem(
                  id: n.mid,
                  user: _noticeUser(n),
                  item: CoreMsgAtContent(
                    business: switch (n.contentType) {
                      2 => 'blog',
                      _ => 'video',
                    },
                    sourceContent: n.excerpt ?? n.content ?? '',
                    // 跳转:1=视频 2=博客(与站点 /v/{id}、/b/{id} 对齐)。
                    nativeUri: _dynUri(n.contentType, n.contentId),
                  ),
                  atTime: _parseTime(n.time),
                ))
            .toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.msgFeedAtMe ApiException: \${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreMsgLikeData>> msgFeedLikeMe({
    int? cursor,
    int? cursorTime,
  }) async {
    // 站点消息中心仅评论/提及两类 inbox,无点赞通知端点。
    return const Error('暂无点赞消息');
  }

  @override
  Future<LoadingState<CoreMsgLikeDetailData>> msgLikeDetail({
    required String cardId,
    required int pn,
    Object lastMid = 0,
  }) async {
    // no SDK API — SDK 缺 oldIm.like-detail 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreMsgSysItem>?>> msgFeedNotify({
    int? cursor,
    int pageSize = 20,
  }) async {
    try {
      final list = await _client.oldIm.getUnreadMessageList(
        offset: cursor,
        num: pageSize,
      );
      return Success(list
          .map(
            (e) => CoreMsgSysItem(
              id: e.msgId,
              cursor: e.msgId,
              title: e.senderName,
              content: e.content,
              timeAt: e.time,
            ),
          )
          .toList());
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.msgFeedNotify ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> msgSysUpdateCursor(int cursor) async {
    // NOTE(otto): SDK has no cursor-level mark-read; readAll is the best
    // available mapping — keep in sync if the SDK adds per-cursor support.
    try {
      await _client.oldIm.readAllSystemMessage();
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.msgSysUpdateCursor ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<Map>> uploadImage({
    required String path,
    required String bucket,
    required String dir,
  }) async {
    // SDK 有 oldCreator.submitImage(File) 但 path/bucket/dir 参数语义不匹配 —
    // core 传本地路径+存储桶，SDK 只收 File，无法忠实映射，保留桩
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreUploadBfsResData>> uploadBfs({
    required String path,
    String? category,
    String? biz,
    CancelToken? cancelToken,
  }) async {
    // no SDK API — SDK 缺 uploadBfs 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> createTextDynamic(Object content) async {
    // Bilibili text dynamics are title-less; the SDK's blog API requires a
    // title, so the first non-empty line becomes the title and the full text
    // the content (channelId/channelSectionId unused).
    try {
      final text = content.toString();
      final firstLine = text.split('\n').first.trim();
      await _client.oldCreator.submitBlog(
        title: firstLine.isEmpty ? '动态' : firstLine,
        content: text,
      );
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.createTextDynamic ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> removeDynamic({
    required String dynIdStr,
    Object? dynType,
    Object? ridStr,
  }) async {
    // no SDK API — SDK 缺 deleteDynamic 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> removeMsg(Object talkerId) async {
    try {
      final id = int.tryParse(talkerId.toString());
      if (id == null) return const Error('missing_argument');
      await _client.oldIm.deleteMessage(id);
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.removeMsg ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> delMsgfeed(int tp, Object? id) async {
    try {
      final msgId = int.tryParse(id.toString());
      if (msgId == null) return const Error('missing_argument');
      await _client.oldIm.deleteMessage(msgId);
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.delMsgfeed ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> delSysMsg(Object id) async {
    try {
      final msgId = int.tryParse(id.toString());
      if (msgId == null) return const Error('missing_argument');
      await _client.oldIm.deleteMessage(msgId);
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.delSysMsg ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> setTop({
    required int talkerId,
    required int opType,
  }) async {
    // no SDK API — SDK 缺 oldIm.pinSession 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> ackSessionMsg({
    required int talkerId,
    required int ackSeqno,
  }) async {
    try {
      await _client.oldIm.readMessage(ackSeqno);
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.ackSessionMsg ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> msgSetNotice({
    required String id,
    required int noticeState,
  }) async {
    // no SDK API — SDK 缺 oldIm.setNotice 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> setMsgDnd({
    required int uid,
    required int setting,
    required dndUid,
  }) async {
    // no SDK API — SDK 缺 oldIm.setDnd 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> setPushSs({
    required int setting,
    required talkerUid,
  }) async {
    // no SDK API — SDK 缺 oldIm.setPushSs 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreImUserInfosData>?>> imUserInfos({
    required String uids,
  }) async {
    // SDK `IOldUserApi.getUserById(uid)` is single-uid; core passes a
    // comma-separated list, so resolve each uid and merge the results.
    try {
      final ids = uids
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .where((e) => e != null)
          .cast<int>()
          .toList();
      if (ids.isEmpty) return const Error('missing_argument');
      final list = <CoreImUserInfosData>[];
      for (final uid in ids) {
        final users = await _client.oldUser.getUserById(uid);
        if (users.isEmpty) continue;
        final u = users.first;
        list.add(CoreImUserInfosData(
          mid: u.uid,
          name: u.username,
          face: u.avatarUrl,
          sign: u.intro,
        ));
      }
      return Success(list);
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.imUserInfos ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreSessionSsData>> getSessionSs({
    required int talkerUid,
  }) async {
    // no SDK API — SDK 缺 oldIm.getSessionSs 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreUidSetting>?>> getMsgDnd({
    required String uidsStr,
  }) async {
    // no SDK API — SDK 缺 oldIm.getMsgDnd 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreSingleUnreadData>> msgUnread() async {
    try {
      final num = await _client.oldIm.getNewMessageNum();
      return Success(CoreSingleUnreadData(
        unfollowUnread: num.newMessageNum,
        followUnread: num.newMessageNum,
        unfollowPushMsg: 0,
        dustbinPushMsg: 0,
        dustbinUnread: 0,
        bizMsgUnfollowUnread: 0,
        bizMsgFollowUnread: 0,
        customUnread: 0,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.msgUnread ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreMsgFeedUnreadData>> msgFeedUnread() async {
    try {
      final num = await _client.oldIm.getNewMessageNum();
      return Success(CoreMsgFeedUnreadData(
        at: 0,
        like: 0,
        reply: 0,
        sysMsg: num.newMessageNum,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMsgRepository.msgFeedUnread ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> imMsgReport({
    required int accusedUid,
    required int reasonType,
    required String reasonDesc,
    required Map comment,
    required Map extra,
  }) async {
    // no SDK API — SDK 缺 oldIm.reportMessage 或等效端点
    return _err(const ApiException('not_implemented'));
  }
}
