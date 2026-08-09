import 'package:fixnum/fixnum.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart'
    show Mode, ReplyInfo, SearchItemType;
import 'package:skf/adapters/bilibili/grpc/reply.dart';
import 'package:skf/adapters/bilibili/http/reply.dart';
import 'package:skf/adapters/bilibili/http/video.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// {@template bili_reply_repository}
/// Implementation of [ReplyRepository] that delegates to [ReplyGrpc].
/// {@endtemplate}
class BiliReplyRepository implements ReplyRepository {
  @override
  Future<LoadingState<CoreMainListReply>> mainList({
    int type = 1,
    required int oid,
    required CoreMode mode,
    required String? offset,
    required int? cursorNext,
  }) async {
    final result = await ReplyGrpc.mainList(
      type: type,
      oid: oid,
      mode: _modeToProto(mode),
      offset: offset,
      cursorNext: cursorNext != null ? Int64(cursorNext) : null,
    );
    if (result case Success(response: final r)) {
      return Success(CoreMainListReply(
        cursor: r.cursor,
        replies: r.replies,
        subjectControl: r.subjectControl,
        upTop: r.upTop,
        adminTop: r.adminTop,
        voteTop: r.voteTop,
        paginationReply: r.paginationReply,
        mode: CoreMode.valueOf(r.mode.value),
        modeText: r.modeText,
      ));
    }
    return result as LoadingState<CoreMainListReply>;
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
    final result = await ReplyGrpc.detailList(
      type: type,
      oid: oid,
      root: root,
      rpid: rpid,
      mode: _modeToProto(mode),
      offset: offset,
    );
    if (result case Success(response: final r)) {
      return Success(CoreDetailListReply(
        cursor: r.cursor,
        subjectControl: r.subjectControl,
        root: r.root,
        mode: CoreMode.valueOf(r.mode.value),
        paginationReply: r.paginationReply,
      ));
    }
    return result as LoadingState<CoreDetailListReply>;
  }

  @override
  Future<LoadingState<CoreDialogListReply>> dialogList({
    int type = 1,
    required int oid,
    required int root,
    required int dialog,
    required String? offset,
  }) async {
    final result = await ReplyGrpc.dialogList(
      type: type,
      oid: oid,
      root: root,
      dialog: dialog,
      offset: offset,
    );
    if (result case Success(response: final r)) {
      return Success(CoreDialogListReply(
        cursor: r.cursor,
        subjectControl: r.subjectControl,
        replies: r.replies,
        paginationReply: r.paginationReply,
      ));
    }
    return result as LoadingState<CoreDialogListReply>;
  }

  @override
  Future<LoadingState<CoreSearchItemReply>> searchItem({
    required int page,
    required CoreSearchItemType itemType,
    required int oid,
    int type = 1,
    String? keyword,
  }) async {
    final result = await ReplyGrpc.searchItem(
      page: page,
      itemType: _searchItemTypeToProto(itemType),
      oid: oid,
      type: type,
      keyword: keyword,
    );
    if (result case Success(response: final r)) {
      return Success(CoreSearchItemReply(
        cursor: r.cursor,
        items: r.items,
        extra: r.extra,
      ));
    }
    return result as LoadingState<CoreSearchItemReply>;
  }

  @override
  Future<LoadingState<CoreTranslateReplyResp>> translateReply({
    required int type,
    required int oid,
    required int rpid,
  }) async {
    final result = await ReplyGrpc.translateReply(
      type: Int64(type),
      oid: Int64(oid),
      rpid: Int64(rpid),
    );
    if (result case Success(response: final r)) {
      return Success(CoreTranslateReplyResp(
        translatedReplies: r.translatedReplies.map(
          (key, value) => MapEntry(key.toInt(), value),
        ),
      ));
    }
    return result as LoadingState<CoreTranslateReplyResp>;
  }

  @override
  Future<LoadingState<void>> replyTop({
    required int oid,
    required int type,
    required String rpid,
    required bool isUpTop,
  }) {
    return ReplyHttp.replyTop(
      oid: oid,
      type: type,
      rpid: rpid,
      isUpTop: isUpTop,
    );
  }

  @override
  Future<LoadingState<void>> replySubjectModify({
    required int oid,
    required int type,
    required int action,
  }) {
    return ReplyHttp.replySubjectModify(
      oid: oid,
      type: type,
      action: action,
    );
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
    final result = await VideoHttp.replyAdd(
      type: type,
      oid: oid,
      message: message,
      root: root,
      parent: parent,
      pictures: pictures,
      syncToDynamic: syncToDynamic,
      atNameToMid: atNameToMid,
    );
    return _mapState<CoreReplyInfo?, ReplyInfo?>(
      result,
      (r) => r != null ? _toCoreReplyInfo(r) : null,
    );
  }

  @override
  Future<LoadingState<void>> replyDel({
    required int type,
    required int oid,
    required int rpid,
  }) {
    return VideoHttp.replyDel(type: type, oid: oid, rpid: rpid);
  }

  @override
  Future<LoadingState<void>> likeReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  }) {
    return ReplyHttp.likeReply(
      type: type,
      oid: oid,
      rpid: rpid,
      action: action,
    );
  }

  @override
  Future<LoadingState<void>> hateReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  }) {
    return ReplyHttp.hateReply(
      type: type,
      oid: oid,
      rpid: rpid,
      action: action,
    );
  }

  @override
  Future<LoadingState<void>> report({
    required String rpid,
    required String oid,
    required int reasonType,
    bool banUid = true,
    String? reasonDesc,
  }) {
    return ReplyHttp.report(
      rpid: rpid,
      oid: oid,
      reasonType: reasonType,
      banUid: banUid,
      reasonDesc: reasonDesc,
    );
  }

  @override
  Future<LoadingState<dynamic>> getEmoteList({String? business}) {
    return ReplyHttp.getEmoteList(business: business);
  }

  static LoadingState<T> _mapState<T, A>(
    LoadingState<A> source,
    T Function(A data) mapper,
  ) =>
      switch (source) {
        Loading() => LoadingState.loading(),
        Success(data: final data) => Success(mapper(data)),
        Error(errMsg: final msg, code: final code) => Error(msg, code: code),
      };

  static CoreReplyInfo _toCoreReplyInfo(ReplyInfo r) => CoreReplyInfo(
        id: r.id.toInt(),
        oid: r.oid.toInt(),
        type: r.type.toInt(),
        mid: r.mid.toInt(),
        root: r.root.toInt(),
        parent: r.parent.toInt(),
        dialog: r.dialog.toInt(),
        like: r.like.toInt(),
        ctime: r.ctime.toInt(),
        count: r.count.toInt(),
        content: r.content.toProto3Json() as Map<String, dynamic>?,
        member: r.member.toProto3Json() as Map<String, dynamic>?,
        replyControl: r.replyControl.toProto3Json() as Map<String, dynamic>?,
        trackInfo: r.trackInfo,
      );

  static Mode _modeToProto(CoreMode m) =>
      Mode.valueOf(m.value) ?? Mode.DEFAULT_Mode;

  static SearchItemType _searchItemTypeToProto(CoreSearchItemType t) =>
      SearchItemType.valueOf(t.value) ?? SearchItemType.DEFAULT_ITEM_TYPE;
}
