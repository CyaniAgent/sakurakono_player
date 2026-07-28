/// Core IM types - adapter-independent wrapper types for instant messaging.
///
/// These types mirror the fields of gRPC protobuf types used in [ImRepository]
/// without any dependency on protobuf or adapter-specific code.
library;

import 'dart:math' as $math;

// ──────────────────────────── Enums ────────────────────────────

/// IM message type enum.
enum CoreImMsgType {
  text,
  pic,
  audio,
  share,
  drawBack,
  customFace,
  shareV2,
  sysCancel,
  miniProgram,
  notifyMsg,
  videoCard,
  articleCard,
  pictureCard,
  commonShareCard,
  textShare,
  tipMessage,
  gptMessage,
  bizMsgType,
  modifyMsgType,
  unknown,
}

/// Session page type enum.
enum CoreImSessionPageType {
  unknown,
  home,
  unfollowed,
  stranger,
  dustbin,
  group,
  huahuo,
  ai,
  customer,
}

/// IM setting type enum.
enum CoreImSettingType {
  needAll,
  replyMe,
  newFans,
  receiveLike,
  msgRemind,
  msgInterception,
  fansGroupMsg,
  keywordBlocking,
  unknown,
}

// ──────────────────────────── Data classes ─────────────────────

/// IM offset for pagination (replaces gRPC [Offset]).
class CoreImOffset {
  final int normalOffset;
  final int topOffset;

  const CoreImOffset({this.normalOffset = 0, this.topOffset = 0});
}

/// IM session identifier (replaces gRPC [SessionId]).
class CoreImSessionId {
  final int? privateTalkerUid;
  final int? groupId;

  const CoreImSessionId({this.privateTalkerUid, this.groupId});
}

/// IM setting value (replaces gRPC [Setting]).
class CoreImSetting {
  final bool? switchValue;
  final String? textValue;

  const CoreImSetting({this.switchValue, this.textValue});
}

/// Share session info (replaces gRPC [ShareSessionInfo]).
class CoreImShareSessionInfo {
  final int talkerId;
  final String talkerUname;
  final String talkerIcon;

  const CoreImShareSessionInfo({
    this.talkerId = 0,
    this.talkerUname = '',
    this.talkerIcon = '',
  });
}

/// IM message (replaces gRPC [Msg] from type.pb.dart).
class CoreImMsg {
  final int msgKey;
  final int msgType;
  final String content;
  final int seqno;
  final int senderUid;
  final int timestamp;

  const CoreImMsg({
    this.msgKey = 0,
    this.msgType = 0,
    this.content = '',
    this.seqno = 0,
    this.senderUid = 0,
    this.timestamp = 0,
  });
}

/// IM session (replaces gRPC [Session] from v1.pb.dart).
class CoreImSession {
  final int talkerId;
  final int sessionType;
  final int unreadCount;
  final int ackSeqno;
  final String sessionName;
  final bool isPinned;

  const CoreImSession({
    this.talkerId = 0,
    this.sessionType = 0,
    this.unreadCount = 0,
    this.ackSeqno = 0,
    this.sessionName = '',
    this.isPinned = false,
  });
}

/// Keyword blocking item (replaces gRPC [KeywordBlockingItem]).
class CoreImKeywordBlockingItem {
  final String keyword;
  final int id;

  const CoreImKeywordBlockingItem({this.keyword = '', this.id = 0});
}

// ──────────────────────────── Reply types ──────────────────────

/// Response from sending a message (replaces gRPC [RspSendMsg]).
class CoreImRspSendMsg {
  final int msgKey;
  final String msgContent;
  final int seqno;

  const CoreImRspSendMsg({
    this.msgKey = 0,
    this.msgContent = '',
    this.seqno = 0,
  });
}

/// Response for share list (replaces gRPC [RspShareList]).
class CoreImRspShareList {
  final List<CoreImShareSessionInfo> sessionList;
  final int isAddressListEmpty;

  const CoreImRspShareList({
    this.sessionList = const [],
    this.isAddressListEmpty = 0,
  });
}

/// Response for session messages (replaces gRPC [RspSessionMsg]).
class CoreImRspSessionMsg {
  final List<CoreImMsg> messages;
  final int hasMore;
  final int minSeqno;
  final int maxSeqno;

  const CoreImRspSessionMsg({
    this.messages = const [],
    this.hasMore = 0,
    this.minSeqno = 0,
    this.maxSeqno = 0,
  });
}

/// Session main list reply (replaces gRPC [SessionMainReply]).
class CoreImSessionMainReply {
  final bool hasMore;
  final List<CoreImSession> sessions;

  const CoreImSessionMainReply({
    this.hasMore = false,
    this.sessions = const [],
  });
}

/// Session secondary list reply (replaces gRPC [SessionSecondaryReply]).
class CoreImSessionSecondaryReply {
  final bool hasMore;
  final List<CoreImSession> sessions;

  const CoreImSessionSecondaryReply({
    this.hasMore = false,
    this.sessions = const [],
  });
}

/// Clear unread response (replaces gRPC [ClearUnreadReply]).
class CoreImClearUnreadReply {
  const CoreImClearUnreadReply();
}

/// Session update response (replaces gRPC [SessionUpdateReply]).
class CoreImSessionUpdateReply {
  final CoreImSession? session;

  const CoreImSessionUpdateReply({this.session});
}

/// Pin session response (replaces gRPC [PinSessionReply]).
class CoreImPinSessionReply {
  final int sequenceNumber;
  final int code;
  final String message;

  const CoreImPinSessionReply({
    this.sequenceNumber = 0,
    this.code = 0,
    this.message = '',
  });
}

/// Unpin session response (replaces gRPC [UnPinSessionReply]).
class CoreImUnPinSessionReply {
  final int sequenceNumber;

  const CoreImUnPinSessionReply({this.sequenceNumber = 0});
}

/// Delete session list response (replaces gRPC [DeleteSessionListReply]).
class CoreImDeleteSessionListReply {
  const CoreImDeleteSessionListReply();
}

/// Get IM settings response (replaces gRPC [GetImSettingsReply]).
class CoreImGetImSettingsReply {
  final String pageTitle;
  final Map<int, CoreImSetting> settings;

  const CoreImGetImSettingsReply({
    this.pageTitle = '',
    this.settings = const {},
  });
}

/// Set IM settings response (replaces gRPC [SetImSettingsReply]).
class CoreImSetImSettingsReply {
  final String toast;

  const CoreImSetImSettingsReply({this.toast = ''});
}

/// Keyword blocking list response (replaces gRPC [KeywordBlockingListReply]).
class CoreImKeywordBlockingListReply {
  final List<CoreImKeywordBlockingItem> items;
  final int listLimit;
  final int charLimit;
  final String listLimitText;

  const CoreImKeywordBlockingListReply({
    this.items = const [],
    this.listLimit = 0,
    this.charLimit = 0,
    this.listLimitText = '',
  });
}

/// Keyword blocking add response (replaces gRPC [KeywordBlockingAddReply]).
class CoreImKeywordBlockingAddReply {
  final String toast;
  final CoreImKeywordBlockingItem? item;

  const CoreImKeywordBlockingAddReply({this.toast = '', this.item});
}

/// Keyword blocking delete response (replaces gRPC [KeywordBlockingDeleteReply]).
class CoreImKeywordBlockingDeleteReply {
  final String toast;

  const CoreImKeywordBlockingDeleteReply({this.toast = ''});
}

/// Total unread response (replaces gRPC [RspTotalUnread]).
class CoreImRspTotalUnread {
  final int totalUnread;
  final Map<String, int>? msgFeedUnread;

  const CoreImRspTotalUnread({this.totalUnread = 0, this.msgFeedUnread});
}

/// Session detail info (replaces gRPC [SessionInfo] from type.pb.dart).
class CoreImSessionInfo {
  final int talkerId;
  final int sessionType;
  final int unreadCount;
  final String groupName;
  final String groupCover;
  final int ackSeqno;
  final int atSeqno;

  const CoreImSessionInfo({
    this.talkerId = 0,
    this.sessionType = 0,
    this.unreadCount = 0,
    this.groupName = '',
    this.groupCover = '',
    this.ackSeqno = 0,
    this.atSeqno = 0,
  });
}
