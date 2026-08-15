import 'package:protobuf/protobuf.dart' show PbMap;

import 'package:skf/adapters/bilibili/grpc/bilibili/app/im/v1.pb.dart' hide SessionInfo;
import 'package:skf/adapters/bilibili/grpc/bilibili/im/interfaces/v1.pb.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/im/type.pb.dart';

import 'package:skf/adapters/bilibili/grpc/im.dart';
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:fixnum/fixnum.dart';

// ────────────────────────────────────────────
// LoadingState mapping helper
// ────────────────────────────────────────────

LoadingState<R> _mapSuccess<T, R>(
  LoadingState<T> state,
  R Function(T) mapper,
) =>
    switch (state) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(mapper(response)),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };

// ────────────────────────────────────────────
// gRPC → CoreIm* extensions
// ────────────────────────────────────────────

extension _RspSendMsgToCore on RspSendMsg {
  CoreImRspSendMsg toCore() => CoreImRspSendMsg(
        msgKey: msgKey.toInt(),
        msgContent: msgContent,
        seqno: seqno.toInt(),
      );
}

extension _RspShareListToCore on RspShareList {
  CoreImRspShareList toCore() => CoreImRspShareList(
        sessionList: sessionList.map((s) => s.toCore()).toList(),
        isAddressListEmpty: isAddressListEmpty,
      );
}

extension _ShareSessionInfoToCore on ShareSessionInfo {
  CoreImShareSessionInfo toCore() => CoreImShareSessionInfo(
        talkerId: talkerId.toInt(),
        talkerUname: talkerUname,
        talkerIcon: talkerIcon,
      );
}

extension _RspSessionMsgToCore on RspSessionMsg {
  CoreImRspSessionMsg toCore() => CoreImRspSessionMsg(
        hasMore: hasMore,
        minSeqno: minSeqno.toInt(),
        maxSeqno: maxSeqno.toInt(),
      );
}

extension _SessionMainReplyToCore on SessionMainReply {
  CoreImSessionMainReply toCore() => CoreImSessionMainReply(
        hasMore: hasPaginationParams() && paginationParams.hasMore
            ? paginationParams.hasMore
            : false,
        sessions: sessions.map((s) => s.toCore()).toList(),
      );
}

extension _SessionSecondaryReplyToCore on SessionSecondaryReply {
  CoreImSessionSecondaryReply toCore() => CoreImSessionSecondaryReply(
        hasMore: hasPaginationParams() && paginationParams.hasMore
            ? paginationParams.hasMore
            : false,
        sessions: sessions.map((s) => s.toCore()).toList(),
      );
}

extension _SessionToCore on Session {
  CoreImSession toCore() {
    int talkerId = 0;
    if (id.hasPrivateId()) {
      talkerId = id.privateId.talkerUid.toInt();
    }

    return CoreImSession(
      talkerId: talkerId,
      sessionType: 0,
      sessionName: hasSessionInfo() ? sessionInfo.sessionName : '',
      unreadCount: hasUnread() ? unread.number.toInt() : 0,
      ackSeqno: 0,
      isPinned: isPinned,
    );
  }
}

extension _ClearUnreadReplyToCore on ClearUnreadReply {
  CoreImClearUnreadReply toCore() => const CoreImClearUnreadReply();
}

extension _SessionUpdateReplyToCore on SessionUpdateReply {
  CoreImSessionUpdateReply toCore() => CoreImSessionUpdateReply(
        session: hasSession() ? session.toCore() : null,
      );
}

extension _PinSessionReplyToCore on PinSessionReply {
  CoreImPinSessionReply toCore() => CoreImPinSessionReply(
        sequenceNumber: sequenceNumber.toInt(),
        code: code.toInt(),
        message: message,
      );
}

extension _UnPinSessionReplyToCore on UnPinSessionReply {
  CoreImUnPinSessionReply toCore() =>
      CoreImUnPinSessionReply(sequenceNumber: sequenceNumber.toInt());
}

extension _DeleteSessionListReplyToCore on DeleteSessionListReply {
  CoreImDeleteSessionListReply toCore() =>
      const CoreImDeleteSessionListReply();
}

extension _GetImSettingsReplyToCore on GetImSettingsReply {
  CoreImGetImSettingsReply toCore() => CoreImGetImSettingsReply(
        pageTitle: pageTitle,
        settings: {for (final e in settings.entries) e.key: e.value.toCore()},
      );
}

extension _SettingToCore on Setting {
  CoreImSetting toCore() {
    if (hasSwitch_1()) {
      return CoreImSetting(switchValue: switch_1.switchOn);
    }
    if (hasText()) {
      return CoreImSetting(textValue: text.text);
    }
    return const CoreImSetting();
  }
}

extension _SetImSettingsReplyToCore on SetImSettingsReply {
  CoreImSetImSettingsReply toCore() =>
      CoreImSetImSettingsReply(toast: toast);
}

extension _KeywordBlockingListReplyToCore on KeywordBlockingListReply {
  CoreImKeywordBlockingListReply toCore() => CoreImKeywordBlockingListReply(
        items: items.map((i) => i.toCore()).toList(),
        listLimit: listLimit,
        charLimit: charLimit,
        listLimitText: listLimitText,
      );
}

extension _KeywordBlockingItemToCore on KeywordBlockingItem {
  CoreImKeywordBlockingItem toCore() =>
      CoreImKeywordBlockingItem(keyword: keyword);
}

extension _KeywordBlockingAddReplyToCore on KeywordBlockingAddReply {
  CoreImKeywordBlockingAddReply toCore() => CoreImKeywordBlockingAddReply(
        toast: toast,
        item: hasItem() ? item.toCore() : null,
      );
}

extension _KeywordBlockingDeleteReplyToCore on KeywordBlockingDeleteReply {
  CoreImKeywordBlockingDeleteReply toCore() =>
      CoreImKeywordBlockingDeleteReply(toast: toast);
}

extension _RspTotalUnreadToCore on RspTotalUnread {
  CoreImRspTotalUnread toCore() => CoreImRspTotalUnread(
        totalUnread: totalUnread,
        msgFeedUnread: hasMsgFeedUnread()
            ? msgFeedUnread.unread.map(
                (k, v) => MapEntry(k, v.toInt()),
              )
            : null,
      );
}

extension _SessionInfoTypeToCore on SessionInfo {
  CoreImSessionInfo toCore() => CoreImSessionInfo(
        talkerId: talkerId.toInt(),
        sessionType: sessionType,
        unreadCount: unreadCount,
        groupName: groupName,
        groupCover: groupCover,
        ackSeqno: ackSeqno.toInt(),
        atSeqno: atSeqno.toInt(),
      );
}

// ────────────────────────────────────────────
// CoreIm* → gRPC helper methods
// ────────────────────────────────────────────

/// Converts [CoreImMsgType] to the gRPC [MsgType] enum.
MsgType _msgTypeToGrpc(CoreImMsgType type) {
  return switch (type) {
    CoreImMsgType.text => MsgType.EN_MSG_TYPE_TEXT,
    CoreImMsgType.pic => MsgType.EN_MSG_TYPE_PIC,
    CoreImMsgType.audio => MsgType.EN_MSG_TYPE_AUDIO,
    CoreImMsgType.share => MsgType.EN_MSG_TYPE_SHARE,
    CoreImMsgType.drawBack => MsgType.EN_MSG_TYPE_DRAW_BACK,
    CoreImMsgType.customFace => MsgType.EN_MSG_TYPE_CUSTOM_FACE,
    CoreImMsgType.shareV2 => MsgType.EN_MSG_TYPE_SHARE_V2,
    CoreImMsgType.sysCancel => MsgType.EN_MSG_TYPE_SYS_CANCEL,
    CoreImMsgType.miniProgram => MsgType.EN_MSG_TYPE_MINI_PROGRAM,
    CoreImMsgType.notifyMsg => MsgType.EN_MSG_TYPE_NOTIFY_MSG,
    CoreImMsgType.videoCard => MsgType.EN_MSG_TYPE_VIDEO_CARD,
    CoreImMsgType.articleCard => MsgType.EN_MSG_TYPE_ARTICLE_CARD,
    CoreImMsgType.pictureCard => MsgType.EN_MSG_TYPE_PICTURE_CARD,
    CoreImMsgType.commonShareCard => MsgType.EN_MSG_TYPE_COMMON_SHARE_CARD,
    CoreImMsgType.textShare => MsgType.EN_MSG_TYPE_TEXT_SHARE,
    CoreImMsgType.tipMessage => MsgType.EN_MSG_TYPE_TIP_MESSAGE,
    CoreImMsgType.gptMessage => MsgType.EN_MSG_TYPE_GPT_MESSAGE,
    CoreImMsgType.bizMsgType => MsgType.EN_MSG_TYPE_BIZ_MSG_TYPE,
    CoreImMsgType.modifyMsgType => MsgType.EN_MSG_TYPE_MODIFY_MSG_TYPE,
    CoreImMsgType.unknown => MsgType.EN_INVALID_MSG_TYPE,
  };
}

/// Converts [CoreImSessionPageType] to the gRPC [SessionPageType] enum.
SessionPageType _sessionPageTypeToGrpc(CoreImSessionPageType? type) {
  return switch (type) {
    CoreImSessionPageType.home => SessionPageType.SESSION_PAGE_TYPE_HOME,
    CoreImSessionPageType.unfollowed =>
      SessionPageType.SESSION_PAGE_TYPE_UNFOLLOWED,
    CoreImSessionPageType.stranger =>
      SessionPageType.SESSION_PAGE_TYPE_STRANGER,
    CoreImSessionPageType.dustbin =>
      SessionPageType.SESSION_PAGE_TYPE_DUSTBIN,
    CoreImSessionPageType.group => SessionPageType.SESSION_PAGE_TYPE_GROUP,
    CoreImSessionPageType.huahuo =>
      SessionPageType.SESSION_PAGE_TYPE_HUA_HUO,
    CoreImSessionPageType.ai => SessionPageType.SESSION_PAGE_TYPE_AI,
    CoreImSessionPageType.customer =>
      SessionPageType.SESSION_PAGE_TYPE_CUSTOMER,
    null => SessionPageType.SESSION_PAGE_TYPE_UNKNOWN,
    CoreImSessionPageType.unknown =>
      SessionPageType.SESSION_PAGE_TYPE_UNKNOWN,
  };
}

/// Converts [CoreImSettingType] to the gRPC [IMSettingType] enum.
IMSettingType _imSettingTypeToGrpc(CoreImSettingType? type) {
  return switch (type) {
    CoreImSettingType.needAll => IMSettingType.SETTING_TYPE_NEED_ALL,
    CoreImSettingType.replyMe => IMSettingType.SETTING_TYPE_REPLY_ME,
    // Only the legacy OLD_AT_ME value exists in the gRPC enum.
    CoreImSettingType.atMe => IMSettingType.SETTING_TYPE_OLD_AT_ME,
    CoreImSettingType.newFans => IMSettingType.SETTING_TYPE_NEW_FANS,
    CoreImSettingType.receiveLike => IMSettingType.SETTING_TYPE_RECEIVE_LIKE,
    CoreImSettingType.msgRemind => IMSettingType.SETTING_TYPE_MSG_REMIND,
    CoreImSettingType.msgInterception =>
      IMSettingType.SETTING_TYPE_MSG_INTERCEPTION,
    CoreImSettingType.fansGroupMsg =>
      IMSettingType.SETTING_TYPE_FANS_GROUP_MSG,
    CoreImSettingType.keywordBlocking =>
      IMSettingType.SETTING_TYPE_KEYWORD_BLOCKING,
    null => IMSettingType.SETTING_TYPE_NEED_ALL,
    CoreImSettingType.unknown => IMSettingType.SETTING_TYPE_NEED_ALL,
  };
}

/// Converts a [CoreImSessionId] to a gRPC [SessionId].
SessionId _sessionIdToGrpc(CoreImSessionId? sessionId) {
  final result = SessionId();
  if (sessionId == null) return result;
  if (sessionId.privateTalkerUid != null) {
    result.privateId =
        PrivateId(talkerUid: Int64(sessionId.privateTalkerUid!));
  } else if (sessionId.groupId != null) {
    result.groupId = GroupId(groupId: Int64(sessionId.groupId!));
  }
  return result;
}

/// Converts a [CoreImSetting] to a gRPC [Setting].
Setting _settingToGrpc(CoreImSetting setting) {
  final result = Setting();
  if (setting.switchValue != null) {
    result.switch_1 = SettingSwitch(switchOn: setting.switchValue);
  }
  return result;
}

// ────────────────────────────────────────────
// Implementation
// ────────────────────────────────────────────

/// {@template bili_im_repository}
/// Implementation of [ImRepository] that delegates to [ImGrpc].
/// {@endtemplate}
class BiliImRepository implements ImRepository {
  @override
  Future<LoadingState<CoreImRspSendMsg>> sendMsg({
    required int senderUid,
    required int receiverId,
    required String content,
    CoreImMsgType msgType = CoreImMsgType.text,
  }) async {
    final result = await ImGrpc.sendMsg(
      senderUid: senderUid,
      receiverId: receiverId,
      content: content,
      msgType: _msgTypeToGrpc(msgType),
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImRspShareList>> shareList({int size = 10}) async {
    final result = await ImGrpc.shareList(size: size);
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImRspSessionMsg>> syncFetchSessionMsgs({
    required int talkerId,
    int? endSeqno,
    int? beginSeqno,
  }) async {
    final result = await ImGrpc.syncFetchSessionMsgs(
      talkerId: talkerId,
      endSeqno: endSeqno != null ? Int64(endSeqno) : null,
      beginSeqno: beginSeqno != null ? Int64(beginSeqno) : null,
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImSessionMainReply>> sessionMain({
    Map<int, CoreImOffset>? offset,
  }) async {
    final result = await ImGrpc.sessionMain(
      offset: offset
              ?.map(
                (k, v) => MapEntry(
                  k,
                  Offset(
                    normalOffset: Int64(v.normalOffset),
                    topOffset: Int64(v.topOffset),
                  ),
                ),
              )
              .cast<int, Offset>() as PbMap<int, Offset>?,
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImSessionSecondaryReply>> sessionSecondary({
    Map<int, CoreImOffset>? offset,
    CoreImSessionPageType? pageType,
  }) async {
    final result = await ImGrpc.sessionSecondary(
      offset: offset
              ?.map(
                (k, v) => MapEntry(
                  k,
                  Offset(
                    normalOffset: Int64(v.normalOffset),
                    topOffset: Int64(v.topOffset),
                  ),
                ),
              )
              .cast<int, Offset>() as PbMap<int, Offset>?,
      pageType: _sessionPageTypeToGrpc(pageType),
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImClearUnreadReply>> clearUnread({
    CoreImSessionPageType? pageType,
    CoreImSessionId? sessionId,
  }) async {
    final result = await ImGrpc.clearUnread(
      pageType: _sessionPageTypeToGrpc(pageType),
      sessionId: _sessionIdToGrpc(sessionId),
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImSessionUpdateReply>> sessionUpdate({
    CoreImSessionPageType? pageType,
    CoreImSessionId? sessionId,
  }) async {
    final result = await ImGrpc.sessionUpdate(
      pageType: _sessionPageTypeToGrpc(pageType),
      sessionId: _sessionIdToGrpc(sessionId),
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImPinSessionReply>> pinSession({
    CoreImSessionId? sessionId,
    int? topTimeMicros,
  }) async {
    final result = await ImGrpc.pinSession(
      sessionId: _sessionIdToGrpc(sessionId),
      topTimeMicros: topTimeMicros != null ? Int64(topTimeMicros) : null,
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImUnPinSessionReply>> unpinSession({
    CoreImSessionId? sessionId,
  }) async {
    final result = await ImGrpc.unpinSession(
      sessionId: _sessionIdToGrpc(sessionId),
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImDeleteSessionListReply>> deleteSessionList({
    CoreImSessionPageType? pageType,
  }) async {
    final result = await ImGrpc.deleteSessionList(
      pageType: _sessionPageTypeToGrpc(pageType),
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImGetImSettingsReply>> getImSettings({
    CoreImSettingType? type,
  }) async {
    final result = await ImGrpc.getImSettings(
      type: _imSettingTypeToGrpc(type),
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImSetImSettingsReply>> setImSettings({
    Map<int, CoreImSetting>? settings,
  }) async {
    final result = await ImGrpc.setImSettings(
      settings: settings?.map((k, v) => MapEntry(k, _settingToGrpc(v))),
    );
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImKeywordBlockingListReply>>
      keywordBlockingList() async {
    final result = await ImGrpc.keywordBlockingList();
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImKeywordBlockingAddReply>> keywordBlockingAdd(
    String keyword,
  ) async {
    final result = await ImGrpc.keywordBlockingAdd(keyword);
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImKeywordBlockingDeleteReply>> keywordBlockingDelete(
    String keyword,
  ) async {
    final result = await ImGrpc.keywordBlockingDelete(keyword);
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImRspTotalUnread>> getTotalUnread({
    int? unreadType,
  }) async {
    final result = await ImGrpc.getTotalUnread(unreadType: unreadType);
    return _mapSuccess(result, (r) => r.toCore());
  }

  @override
  Future<LoadingState<CoreImSessionInfo>> sessionDetail({
    int? talkerId,
    int? sessionType,
    int? uid,
  }) async {
    final result = await ImGrpc.sessionDetail(
      talkerId: talkerId != null ? Int64(talkerId) : null,
      sessionType: sessionType,
      uid: uid != null ? Int64(uid) : null,
    );
    return _mapSuccess(result, (r) => r.toCore());
  }
}
