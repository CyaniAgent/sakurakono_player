import 'package:flutter/foundation.dart' show debugPrint;
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';

/// Implementation of [ImRepository] that delegates to OttoHub SDK APIs.
///
/// Uses [IOldImApi] for IM (instant messaging) operations.
class OttoImRepository implements ImRepository {
  final OttohubClient _client;

  OttoImRepository(this._client);

  // ---- helpers ----

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  
  @override
  Future<LoadingState<CoreImRspSendMsg>> sendMsg({
    required int senderUid,
    required int receiverId,
    required String content,
    CoreImMsgType msgType = CoreImMsgType.text,
  }) async {
    try {
      await _client.oldIm.sendMessage(receiver: receiverId, message: content);
      return Success(CoreImRspSendMsg(msgKey: 0, msgContent: content, seqno: 0));
    } on ApiException catch (e) {
      debugPrint('OttoImRepository.sendMsg ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreImRspShareList>> shareList({int size = 10}) async {
    // no SDK API — SDK oldIm 无分享列表接口 (无 shareList)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreImRspSessionMsg>> syncFetchSessionMsgs({
    required int talkerId,
    int? endSeqno,
    int? beginSeqno,
  }) async {
    try {
      final msgs = await _client.oldIm.getFriendMessages(
        friendUid: talkerId,
        offset: beginSeqno,
        num: endSeqno != null ? endSeqno - (beginSeqno ?? 0) : null,
      );
      return Success(CoreImRspSessionMsg(
        messages: msgs
            .map((m) => CoreImMsg(
                  msgKey: m.msgId,
                  msgType: 1,
                  content: m.content,
                  seqno: m.msgId,
                  senderUid: m.sender,
                  timestamp: _parseTime(m.time),
                ))
            .toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoImRepository.syncFetchSessionMsgs ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreImSessionMainReply>> sessionMain({
    Map<int, CoreImOffset>? offset,
  }) async {
    // Core keys pagination by session type; the SDK friend list is not
    // session-type-keyed, so the FIRST entry's normalOffset is forwarded as
    // the SDK offset (num: 20, approximate mapping) when the map is non-empty.
    try {
      final firstOffset = offset?.values.firstOrNull?.normalOffset;
      final friends = await _client.oldIm.getFriendList(
        offset: firstOffset,
        num: firstOffset != null ? 20 : null,
      );
      return Success(CoreImSessionMainReply(
        sessions: friends
            .map((f) => CoreImSession(
                  talkerId: f.uid,
                  sessionType: 1,
                  unreadCount: f.newMessageNum ?? 0,
                  sessionName: f.username,
                ))
            .toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoImRepository.sessionMain ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreImSessionSecondaryReply>> sessionSecondary({
    Map<int, CoreImOffset>? offset,
    CoreImSessionPageType? pageType,
  }) async {
    // no SDK API — SDK oldIm 无会话次级列表接口 (无 secondary list)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreImClearUnreadReply>> clearUnread({
    CoreImSessionPageType? pageType,
    CoreImSessionId? sessionId,
  }) async {
    try {
      await _client.oldIm.readAllSystemMessage();
      return const Success(CoreImClearUnreadReply());
    } on ApiException catch (e) {
      debugPrint('OttoImRepository.clearUnread ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreImSessionUpdateReply>> sessionUpdate({
    CoreImSessionPageType? pageType,
    CoreImSessionId? sessionId,
  }) async {
    // no SDK API — SDK oldIm 无会话更新接口 (无 updateSession)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreImPinSessionReply>> pinSession({
    CoreImSessionId? sessionId,
    int? topTimeMicros,
  }) async {
    // no SDK API — SDK oldIm 无会话置顶接口 (无 pinSession)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreImUnPinSessionReply>> unpinSession({
    CoreImSessionId? sessionId,
  }) async {
    // no SDK API — SDK oldIm 无取消置顶接口 (无 unpinSession)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreImDeleteSessionListReply>> deleteSessionList({
    CoreImSessionPageType? pageType,
  }) async {
    // SDK `IOldImApi.deleteMessage(msgId)` is keyed by msgId; the core call
    // carries no session id, so the closest equivalent is deleting every
    // friend-session message (clearing the session list). Bounded paged sweep
    // (num: 50, loop while a full page returns); abort-on-error — no per-friend
    // swallowing, any ApiException surfaces as Error.
    try {
      final friends = await _client.oldIm.getFriendList();
      for (final friend in friends) {
        var pageStart = 0;
        while (true) {
          final msgs = await _client.oldIm.getFriendMessages(
            friendUid: friend.uid,
            offset: pageStart,
            num: 50,
          );
          for (final m in msgs) {
            await _client.oldIm.deleteMessage(m.msgId);
          }
          if (msgs.length < 50) break;
          pageStart += msgs.length;
        }
      }
      return const Success(CoreImDeleteSessionListReply());
    } on ApiException catch (e) {
      debugPrint('OttoImRepository.deleteSessionList ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreImGetImSettingsReply>> getImSettings({
    CoreImSettingType? type,
  }) async {
    // no SDK API — SDK oldIm 无 IM 设置查询接口 (无 getImSettings)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreImSetImSettingsReply>> setImSettings({
    Map<int, CoreImSetting>? settings,
  }) async {
    // no SDK API — SDK oldIm 无 IM 设置写入接口 (无 setImSettings)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreImKeywordBlockingListReply>> keywordBlockingList() async {
    // no SDK API — SDK oldIm 无关键词屏蔽列表接口 (无 keywordBlockingList)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreImKeywordBlockingAddReply>> keywordBlockingAdd(
    String keyword,
  ) async {
    // no SDK API — SDK oldIm 无关键词屏蔽添加接口 (无 keywordBlockingAdd)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreImKeywordBlockingDeleteReply>> keywordBlockingDelete(
    String keyword,
  ) async {
    // no SDK API — SDK oldIm 无关键词屏蔽删除接口 (无 keywordBlockingDelete)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreImRspTotalUnread>> getTotalUnread({
    int? unreadType,
  }) async {
    try {
      final num = await _client.oldIm.getNewMessageNum();
      return Success(CoreImRspTotalUnread(totalUnread: num.newMessageNum));
    } on ApiException catch (e) {
      debugPrint('OttoImRepository.getTotalUnread ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreImSessionInfo>> sessionDetail({
    int? talkerId,
    int? sessionType,
    int? uid,
  }) async {
    try {
      // Attempt to find the user in the friend list first.
      final lookupUid = talkerId ?? uid;
      if (lookupUid != null) {
        final friends = await _client.oldIm.getFriendList();
        final friend = friends.where((f) => f.uid == lookupUid).firstOrNull;
        if (friend != null) {
          return Success(CoreImSessionInfo(
            talkerId: friend.uid,
            sessionType: sessionType ?? 1,
            unreadCount: friend.newMessageNum ?? 0,
            groupName: friend.username,
            groupCover: friend.avatarUrl ?? '',
          ));
        }

        // If not a friend, try a generic user lookup for basic info.
        final users = await _client.oldUser.getUserById(lookupUid);
        if (users.isNotEmpty) {
          final user = users.first;
          return Success(CoreImSessionInfo(
            talkerId: user.uid,
            sessionType: sessionType ?? 1,
            groupName: user.username,
            groupCover: user.avatarUrl ?? '',
          ));
        }
      }
      return const Error('OttoHub: 会话不存在');
    } on ApiException catch (e) {
      debugPrint('OttoImRepository.sessionDetail ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  /// Parse OttoHub time string to Unix timestamp in seconds.
  int _parseTime(String time) {
    try {
      return DateTime.parse(time).millisecondsSinceEpoch ~/ 1000;
    } catch (e) {
      debugPrint('OttoImRepository._parseTime error: $e');
      return 0;
    }
  }
}
