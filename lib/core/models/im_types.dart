/// Core IM types - adapter-independent wrapper types for instant messaging.
///
/// These types mirror the fields of gRPC protobuf types used in [ImRepository]
/// without any dependency on protobuf or adapter-specific code.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'im_types.freezed.dart';

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
  atMe,
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
@freezed
abstract class CoreImOffset with _$CoreImOffset {
  const factory CoreImOffset({
    @Default(0) int normalOffset,
    @Default(0) int topOffset,
  }) = _CoreImOffset;
}

/// IM session identifier (replaces gRPC [SessionId]).
@freezed
abstract class CoreImSessionId with _$CoreImSessionId {
  const factory CoreImSessionId({
    int? privateTalkerUid,
    int? groupId,
  }) = _CoreImSessionId;
}

/// IM setting value (replaces gRPC [Setting]).
@freezed
abstract class CoreImSetting with _$CoreImSetting {
  const factory CoreImSetting({
    bool? switchValue,
    String? textValue,
  }) = _CoreImSetting;
}

/// Share session info (replaces gRPC [ShareSessionInfo]).
@freezed
abstract class CoreImShareSessionInfo with _$CoreImShareSessionInfo {
  const factory CoreImShareSessionInfo({
    @Default(0) int talkerId,
    @Default('') String talkerUname,
    @Default('') String talkerIcon,
  }) = _CoreImShareSessionInfo;
}

/// IM message (replaces gRPC [Msg] from type.pb.dart).
@freezed
abstract class CoreImMsg with _$CoreImMsg {
  const factory CoreImMsg({
    @Default(0) int msgKey,
    @Default(0) int msgType,
    @Default('') String content,
    @Default(0) int seqno,
    @Default(0) int senderUid,
    @Default(0) int timestamp,
  }) = _CoreImMsg;
}

/// IM session (replaces gRPC [Session] from v1.pb.dart).
@freezed
abstract class CoreImSession with _$CoreImSession {
  const factory CoreImSession({
    @Default(0) int talkerId,
    @Default(0) int sessionType,
    @Default(0) int unreadCount,
    @Default(0) int ackSeqno,
    @Default('') String sessionName,
    @Default(false) bool isPinned,
  }) = _CoreImSession;
}

/// Keyword blocking item (replaces gRPC [KeywordBlockingItem]).
@freezed
abstract class CoreImKeywordBlockingItem with _$CoreImKeywordBlockingItem {
  const factory CoreImKeywordBlockingItem({
    @Default('') String keyword,
    @Default(0) int id,
  }) = _CoreImKeywordBlockingItem;
}

// ──────────────────────────── Reply types ──────────────────────

/// Response from sending a message (replaces gRPC [RspSendMsg]).
@freezed
abstract class CoreImRspSendMsg with _$CoreImRspSendMsg {
  const factory CoreImRspSendMsg({
    @Default(0) int msgKey,
    @Default('') String msgContent,
    @Default(0) int seqno,
  }) = _CoreImRspSendMsg;
}

/// Response for share list (replaces gRPC [RspShareList]).
@freezed
abstract class CoreImRspShareList with _$CoreImRspShareList {
  const factory CoreImRspShareList({
    @Default([]) List<CoreImShareSessionInfo> sessionList,
    @Default(0) int isAddressListEmpty,
  }) = _CoreImRspShareList;
}

/// Response for session messages (replaces gRPC [RspSessionMsg]).
@freezed
abstract class CoreImRspSessionMsg with _$CoreImRspSessionMsg {
  const factory CoreImRspSessionMsg({
    @Default([]) List<CoreImMsg> messages,
    @Default(0) int hasMore,
    @Default(0) int minSeqno,
    @Default(0) int maxSeqno,
  }) = _CoreImRspSessionMsg;
}

/// Session main list reply (replaces gRPC [SessionMainReply]).
@freezed
abstract class CoreImSessionMainReply with _$CoreImSessionMainReply {
  const factory CoreImSessionMainReply({
    @Default(false) bool hasMore,
    @Default([]) List<CoreImSession> sessions,
  }) = _CoreImSessionMainReply;
}

/// Session secondary list reply (replaces gRPC [SessionSecondaryReply]).
@freezed
abstract class CoreImSessionSecondaryReply with _$CoreImSessionSecondaryReply {
  const factory CoreImSessionSecondaryReply({
    @Default(false) bool hasMore,
    @Default([]) List<CoreImSession> sessions,
  }) = _CoreImSessionSecondaryReply;
}

/// Clear unread response (replaces gRPC [ClearUnreadReply]).
@freezed
abstract class CoreImClearUnreadReply with _$CoreImClearUnreadReply {
  const factory CoreImClearUnreadReply() = _CoreImClearUnreadReply;
}

/// Session update response (replaces gRPC [SessionUpdateReply]).
@freezed
abstract class CoreImSessionUpdateReply with _$CoreImSessionUpdateReply {
  const factory CoreImSessionUpdateReply({
    CoreImSession? session,
  }) = _CoreImSessionUpdateReply;
}

/// Pin session response (replaces gRPC [PinSessionReply]).
@freezed
abstract class CoreImPinSessionReply with _$CoreImPinSessionReply {
  const factory CoreImPinSessionReply({
    @Default(0) int sequenceNumber,
    @Default(0) int code,
    @Default('') String message,
  }) = _CoreImPinSessionReply;
}

/// Unpin session response (replaces gRPC [UnPinSessionReply]).
@freezed
abstract class CoreImUnPinSessionReply with _$CoreImUnPinSessionReply {
  const factory CoreImUnPinSessionReply({
    @Default(0) int sequenceNumber,
  }) = _CoreImUnPinSessionReply;
}

/// Delete session list response (replaces gRPC [DeleteSessionListReply]).
@freezed
abstract class CoreImDeleteSessionListReply
    with _$CoreImDeleteSessionListReply {
  const factory CoreImDeleteSessionListReply() = _CoreImDeleteSessionListReply;
}

/// Get IM settings response (replaces gRPC [GetImSettingsReply]).
@freezed
abstract class CoreImGetImSettingsReply with _$CoreImGetImSettingsReply {
  const factory CoreImGetImSettingsReply({
    @Default('') String pageTitle,
    @Default({}) Map<int, CoreImSetting> settings,
  }) = _CoreImGetImSettingsReply;
}

/// Set IM settings response (replaces gRPC [SetImSettingsReply]).
@freezed
abstract class CoreImSetImSettingsReply with _$CoreImSetImSettingsReply {
  const factory CoreImSetImSettingsReply({
    @Default('') String toast,
  }) = _CoreImSetImSettingsReply;
}

/// Keyword blocking list response (replaces gRPC [KeywordBlockingListReply]).
@freezed
abstract class CoreImKeywordBlockingListReply
    with _$CoreImKeywordBlockingListReply {
  const factory CoreImKeywordBlockingListReply({
    @Default([]) List<CoreImKeywordBlockingItem> items,
    @Default(0) int listLimit,
    @Default(0) int charLimit,
    @Default('') String listLimitText,
  }) = _CoreImKeywordBlockingListReply;
}

/// Keyword blocking add response (replaces gRPC [KeywordBlockingAddReply]).
@freezed
abstract class CoreImKeywordBlockingAddReply
    with _$CoreImKeywordBlockingAddReply {
  const factory CoreImKeywordBlockingAddReply({
    @Default('') String toast,
    CoreImKeywordBlockingItem? item,
  }) = _CoreImKeywordBlockingAddReply;
}

/// Keyword blocking delete response (replaces gRPC [KeywordBlockingDeleteReply]).
@freezed
abstract class CoreImKeywordBlockingDeleteReply
    with _$CoreImKeywordBlockingDeleteReply {
  const factory CoreImKeywordBlockingDeleteReply({
    @Default('') String toast,
  }) = _CoreImKeywordBlockingDeleteReply;
}

/// Total unread response (replaces gRPC [RspTotalUnread]).
@freezed
abstract class CoreImRspTotalUnread with _$CoreImRspTotalUnread {
  const factory CoreImRspTotalUnread({
    @Default(0) int totalUnread,
    Map<String, int>? msgFeedUnread,
  }) = _CoreImRspTotalUnread;
}

/// Session detail info (replaces gRPC [SessionInfo] from type.pb.dart).
@freezed
abstract class CoreImSessionInfo with _$CoreImSessionInfo {
  const factory CoreImSessionInfo({
    @Default(0) int talkerId,
    @Default(0) int sessionType,
    @Default(0) int unreadCount,
    @Default('') String groupName,
    @Default('') String groupCover,
    @Default(0) int ackSeqno,
    @Default(0) int atSeqno,
  }) = _CoreImSessionInfo;
}
