import 'package:skf/core/models/msg_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:dio/dio.dart';

/// Abstract interface for messaging and notification operations.
///
/// All methods delegate to Bilibili MsgHttp endpoints. Methods returning
/// [LoadingState] follow the Success/Error/Loading pattern.
abstract class MsgRepository {
  /// Feed: replies to me.
  Future<LoadingState<CoreMsgReplyData>> msgFeedReplyMe({
    int? cursor,
    int? cursorTime,
  });

  /// Feed: @ me.
  Future<LoadingState<CoreMsgAtData>> msgFeedAtMe({
    int? cursor,
    int? cursorTime,
  });

  /// Feed: likes on my content.
  Future<LoadingState<CoreMsgLikeData>> msgFeedLikeMe({
    int? cursor,
    int? cursorTime,
  });

  /// Like detail for a specific card.
  Future<LoadingState<CoreMsgLikeDetailData>> msgLikeDetail({
    required String cardId,
    required int pn,
    Object lastMid = 0,
  });

  /// Feed: system notifications.
  Future<LoadingState<List<CoreMsgSysItem>?>> msgFeedNotify({
    int? cursor,
    int pageSize = 20,
  });

  /// Update the system-notification cursor.
  Future<LoadingState<void>> msgSysUpdateCursor(int cursor);

  /// Upload an image to Bilibili storage.
  Future<LoadingState<Map>> uploadImage({
    required String path,
    required String bucket,
    required String dir,
  });

  /// Upload a file to BFS.
  Future<LoadingState<CoreUploadBfsResData>> uploadBfs({
    required String path,
    String? category,
    String? biz,
    CancelToken? cancelToken,
  });

  /// Create a text-only dynamic (post).
  Future<LoadingState<void>> createTextDynamic(Object content);

  /// Remove a dynamic post.
  Future<LoadingState<void>> removeDynamic({
    required String dynIdStr,
    Object? dynType,
    Object? ridStr,
  });

  /// Remove a private-message conversation.
  Future<LoadingState<void>> removeMsg(Object talkerId);

  /// Delete a feed item.
  Future<LoadingState<void>> delMsgfeed(int tp, Object? id);

  /// Delete a system message.
  Future<LoadingState<void>> delSysMsg(Object id);

  /// Set or unset a conversation as top.
  Future<LoadingState<void>> setTop({
    required int talkerId,
    required int opType,
  });

  /// Acknowledge (mark as read) session messages.
  Future<LoadingState<void>> ackSessionMsg({
    required int talkerId,
    required int ackSeqno,
  });

  /// Set notification state for a message.
  Future<LoadingState<void>> msgSetNotice({
    required String id,
    required int noticeState,
  });

  /// Set do-not-disturb for a specific user.
  Future<LoadingState<void>> setMsgDnd({
    required int uid,
    required int setting,
    required dndUid,
  });

  /// Toggle push setting for a session.
  Future<LoadingState<void>> setPushSs({
    required int setting,
    required talkerUid,
  });

  /// Fetch IM user info for given UIDs.
  Future<LoadingState<List<CoreImUserInfosData>?>> imUserInfos({
    required String uids,
  });

  /// Get session-specific setting for a user.
  Future<LoadingState<CoreSessionSsData>> getSessionSs({
    required int talkerUid,
  });

  /// Get do-not-disturb settings for given UIDs.
  Future<LoadingState<List<CoreUidSetting>?>> getMsgDnd({
    required String uidsStr,
  });

  /// Get total unread message count.
  Future<LoadingState<CoreSingleUnreadData>> msgUnread();

  /// Get unread feed counts (reply / @ / like / system).
  Future<LoadingState<CoreMsgFeedUnreadData>> msgFeedUnread();

  /// Report an IM message.
  Future<LoadingState<void>> imMsgReport({
    required int accusedUid,
    required int reasonType,
    required String reasonDesc,
    required Map comment,
    required Map extra,
  });
}
