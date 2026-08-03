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

  @override
  Future<LoadingState<CoreMsgReplyData>> msgFeedReplyMe({
    int? cursor,
    int? cursorTime,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreMsgAtData>> msgFeedAtMe({
    int? cursor,
    int? cursorTime,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreMsgLikeData>> msgFeedLikeMe({
    int? cursor,
    int? cursorTime,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreMsgLikeDetailData>> msgLikeDetail({
    required Object cardId,
    required int pn,
    Object lastMid = 0,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
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
    // TODO(otto): SDK has no cursor-level mark-read, using readAll as best-available mapping
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
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreUploadBfsResData>> uploadBfs({
    required String path,
    String? category,
    String? biz,
    CancelToken? cancelToken,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> createTextDynamic(Object content) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> removeDynamic({
    required Object dynIdStr,
    Object? dynType,
    Object? ridStr,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
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
    required Object talkerId,
    required int opType,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
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
    required Object id,
    required int noticeState,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> setMsgDnd({
    required Object uid,
    required int setting,
    required dndUid,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> setPushSs({
    required int setting,
    required talkerUid,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<List<CoreImUserInfosData>?>> imUserInfos({
    required String uids,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreSessionSsData>> getSessionSs({
    required Object talkerUid,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<List<CoreUidSetting>?>> getMsgDnd({
    required Object uidsStr,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
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
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }
}
