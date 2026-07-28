import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for IM (instant messaging) operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class ImRepository {
  /// Send a message.
  Future<LoadingState<CoreImRspSendMsg>> sendMsg({
    required int senderUid,
    required int receiverId,
    required String content,
    CoreImMsgType msgType = CoreImMsgType.text,
  });

  /// Get share list.
  Future<LoadingState<CoreImRspShareList>> shareList({int size = 10});

  /// Sync fetch session messages.
  Future<LoadingState<CoreImRspSessionMsg>> syncFetchSessionMsgs({
    required int talkerId,
    int? endSeqno,
    int? beginSeqno,
  });

  /// Get session main list.
  Future<LoadingState<CoreImSessionMainReply>> sessionMain({
    Map<int, CoreImOffset>? offset,
  });

  /// Get session secondary list.
  Future<LoadingState<CoreImSessionSecondaryReply>> sessionSecondary({
    Map<int, CoreImOffset>? offset,
    CoreImSessionPageType? pageType,
  });

  /// Clear unread messages.
  Future<LoadingState<CoreImClearUnreadReply>> clearUnread({
    CoreImSessionPageType? pageType,
    CoreImSessionId? sessionId,
  });

  /// Update session.
  Future<LoadingState<CoreImSessionUpdateReply>> sessionUpdate({
    CoreImSessionPageType? pageType,
    CoreImSessionId? sessionId,
  });

  /// Pin a session to the top.
  Future<LoadingState<CoreImPinSessionReply>> pinSession({
    CoreImSessionId? sessionId,
    int? topTimeMicros,
  });

  /// Unpin a session.
  Future<LoadingState<CoreImUnPinSessionReply>> unpinSession({
    CoreImSessionId? sessionId,
  });

  /// Delete session list.
  Future<LoadingState<CoreImDeleteSessionListReply>> deleteSessionList({
    CoreImSessionPageType? pageType,
  });

  /// Get IM settings.
  Future<LoadingState<CoreImGetImSettingsReply>> getImSettings({
    CoreImSettingType? type,
  });

  /// Set IM settings.
  Future<LoadingState<CoreImSetImSettingsReply>> setImSettings({
    Map<int, CoreImSetting>? settings,
  });

  /// Get keyword blocking list.
  Future<LoadingState<CoreImKeywordBlockingListReply>> keywordBlockingList();

  /// Add a keyword to the blocking list.
  Future<LoadingState<CoreImKeywordBlockingAddReply>> keywordBlockingAdd(
    String keyword,
  );

  /// Delete a keyword from the blocking list.
  Future<LoadingState<CoreImKeywordBlockingDeleteReply>> keywordBlockingDelete(
    String keyword,
  );

  /// Get total unread count.
  Future<LoadingState<CoreImRspTotalUnread>> getTotalUnread({
    int? unreadType,
  });

  /// Get session detail.
  Future<LoadingState<CoreImSessionInfo>> sessionDetail({
    int? talkerId,
    int? sessionType,
    int? uid,
  });
}
