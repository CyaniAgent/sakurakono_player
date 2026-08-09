import 'package:dio/dio.dart';

import 'package:skf/adapters/bilibili/http/msg.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// {@template bili_msg_repository}
/// Implementation of [MsgRepository] that delegates to [MsgHttp].
/// {@endtemplate}
class BiliMsgRepository implements MsgRepository {
  @override
  Future<LoadingState<CoreMsgReplyData>> msgFeedReplyMe({
    int? cursor,
    int? cursorTime,
  }) async {
    final result = await MsgHttp.msgFeedReplyMe(
      cursor: cursor,
      cursorTime: cursorTime,
    );
    if (result case Success(:final response)) {
      return Success(CoreMsgReplyData.fromJson(response.toJson()));
    }
    return result as LoadingState<CoreMsgReplyData>;
  }

  @override
  Future<LoadingState<CoreMsgAtData>> msgFeedAtMe({
    int? cursor,
    int? cursorTime,
  }) async {
    final result = await MsgHttp.msgFeedAtMe(
      cursor: cursor,
      cursorTime: cursorTime,
    );
    if (result case Success(:final response)) {
      return Success(CoreMsgAtData.fromJson(response.toJson()));
    }
    return result as LoadingState<CoreMsgAtData>;
  }

  @override
  Future<LoadingState<CoreMsgLikeData>> msgFeedLikeMe({
    int? cursor,
    int? cursorTime,
  }) async {
    final result = await MsgHttp.msgFeedLikeMe(
      cursor: cursor,
      cursorTime: cursorTime,
    );
    if (result case Success(:final response)) {
      return Success(CoreMsgLikeData.fromJson(response.toJson()));
    }
    return result as LoadingState<CoreMsgLikeData>;
  }

  @override
  Future<LoadingState<CoreMsgLikeDetailData>> msgLikeDetail({
    required String cardId,
    required int pn,
    Object lastMid = 0,
  }) async {
    final result = await MsgHttp.msgLikeDetail(
      cardId: cardId,
      pn: pn,
      lastMid: lastMid,
    );
    if (result case Success(:final response)) {
      return Success(CoreMsgLikeDetailData.fromJson(response.toJson()));
    }
    return result as LoadingState<CoreMsgLikeDetailData>;
  }

  @override
  Future<LoadingState<List<CoreMsgSysItem>?>> msgFeedNotify({
    int? cursor,
    int pageSize = 20,
  }) async {
    final result = await MsgHttp.msgFeedNotify(
      cursor: cursor,
      pageSize: pageSize,
    );
    if (result case Success(:final response)) {
      return Success(
        response?.map((e) => CoreMsgSysItem.fromJson(e.toJson())).toList(),
      );
    }
    return result as LoadingState<List<CoreMsgSysItem>?>;
  }

  @override
  Future<LoadingState<void>> msgSysUpdateCursor(int cursor) {
    return MsgHttp.msgSysUpdateCursor(cursor);
  }

  @override
  Future<LoadingState<Map>> uploadImage({
    required dynamic path,
    required String bucket,
    required String dir,
  }) {
    return MsgHttp.uploadImage(
      path: path,
      bucket: bucket,
      dir: dir,
    );
  }

  @override
  Future<LoadingState<CoreUploadBfsResData>> uploadBfs({
    required String path,
    String? category,
    String? biz,
    CancelToken? cancelToken,
  }) async {
    final result = await MsgHttp.uploadBfs(
      path: path,
      category: category,
      biz: biz,
      cancelToken: cancelToken,
    );
    if (result case Success(:final response)) {
      return Success(CoreUploadBfsResData.fromJson(response.toJson()));
    }
    return result as LoadingState<CoreUploadBfsResData>;
  }

  @override
  Future<LoadingState<void>> createTextDynamic(Object content) {
    return MsgHttp.createTextDynamic(content);
  }

  @override
  Future<LoadingState<void>> removeDynamic({
    required String dynIdStr,
    Object? dynType,
    Object? ridStr,
  }) {
    return MsgHttp.removeDynamic(
      dynIdStr: dynIdStr,
      dynType: dynType,
      ridStr: ridStr,
    );
  }

  @override
  Future<LoadingState<void>> removeMsg(Object talkerId) {
    return MsgHttp.removeMsg(talkerId);
  }

  @override
  Future<LoadingState<void>> delMsgfeed(int tp, dynamic id) {
    return MsgHttp.delMsgfeed(tp, id);
  }

  @override
  Future<LoadingState<void>> delSysMsg(Object id) {
    return MsgHttp.delSysMsg(id);
  }

  @override
  Future<LoadingState<void>> setTop({
    required int talkerId,
    required int opType,
  }) {
    return MsgHttp.setTop(
      talkerId: talkerId,
      opType: opType,
    );
  }

  @override
  Future<LoadingState<void>> ackSessionMsg({
    required int talkerId,
    required int ackSeqno,
  }) {
    return MsgHttp.ackSessionMsg(
      talkerId: talkerId,
      ackSeqno: ackSeqno,
    );
  }

  @override
  Future<LoadingState<void>> msgSetNotice({
    required String id,
    required int noticeState,
  }) {
    return MsgHttp.msgSetNotice(
      id: id,
      noticeState: noticeState,
    );
  }

  @override
  Future<LoadingState<void>> setMsgDnd({
    required int uid,
    required int setting,
    required dndUid,
  }) {
    return MsgHttp.setMsgDnd(
      uid: uid,
      setting: setting,
      dndUid: dndUid,
    );
  }

  @override
  Future<LoadingState<void>> setPushSs({
    required int setting,
    required talkerUid,
  }) {
    return MsgHttp.setPushSs(
      setting: setting,
      talkerUid: talkerUid,
    );
  }

  @override
  Future<LoadingState<List<CoreImUserInfosData>?>> imUserInfos({
    required String uids,
  }) async {
    final result = await MsgHttp.imUserInfos(
      uids: uids,
    );
    if (result case Success(:final response)) {
      return Success(
        response?.map((e) => CoreImUserInfosData.fromJson(e.toJson())).toList(),
      );
    }
    return result as LoadingState<List<CoreImUserInfosData>?>;
  }

  @override
  Future<LoadingState<CoreSessionSsData>> getSessionSs({
    required int talkerUid,
  }) async {
    final result = await MsgHttp.getSessionSs(
      talkerUid: talkerUid,
    );
    if (result case Success(:final response)) {
      return Success(CoreSessionSsData.fromJson(response.toJson()));
    }
    return result as LoadingState<CoreSessionSsData>;
  }

  @override
  Future<LoadingState<List<CoreUidSetting>?>> getMsgDnd({
    required String uidsStr,
  }) async {
    final result = await MsgHttp.getMsgDnd(
      uidsStr: uidsStr,
    );
    if (result case Success(:final response)) {
      return Success(
        response?.map((e) => CoreUidSetting.fromJson(e.toJson())).toList(),
      );
    }
    return result as LoadingState<List<CoreUidSetting>?>;
  }

  @override
  Future<LoadingState<CoreSingleUnreadData>> msgUnread() async {
    final result = await MsgHttp.msgUnread();
    if (result case Success(:final response)) {
      return Success(CoreSingleUnreadData.fromJson(response.toJson()));
    }
    return result as LoadingState<CoreSingleUnreadData>;
  }

  @override
  Future<LoadingState<CoreMsgFeedUnreadData>> msgFeedUnread() async {
    final result = await MsgHttp.msgFeedUnread();
    if (result case Success(:final response)) {
      return Success(CoreMsgFeedUnreadData.fromJson(response.toJson()));
    }
    return result as LoadingState<CoreMsgFeedUnreadData>;
  }

  @override
  Future<LoadingState<void>> imMsgReport({
    required int accusedUid,
    required int reasonType,
    required String reasonDesc,
    required Map comment,
    required Map extra,
  }) {
    return MsgHttp.imMsgReport(
      accusedUid: accusedUid,
      reasonType: reasonType,
      reasonDesc: reasonDesc,
      comment: comment,
      extra: extra,
    );
  }
}