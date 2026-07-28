import 'package:skf/adapters/bilibili/grpc/bilibili/community/service/dm/v1.pb.dart';
import 'package:skf/adapters/bilibili/grpc/dm.dart';
import 'package:skf/adapters/bilibili/http/danmaku.dart';

import 'package:skf/adapters/bilibili/models_new/danmaku/post.dart';
import 'package:skf/core/models/danmaku_types.dart';
import 'package:skf/core/repository/danmaku_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [DanmakuRepository] that delegates to [DanmakuHttp] and [DmGrpc].
class BiliDanmakuRepository implements DanmakuRepository {
  // ---- conversion helpers ----

  LoadingState<T> _toCore<T, A>(LoadingState<A> state, T Function(A) convert) {
    return switch (state) {
      Success<A>(:final response) => Success<T>(convert(response)),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
      Loading() => LoadingState<T>.loading(),
    };
  }

  @override
  Future<LoadingState<CoreDanmakuPost>> shootDanmaku({
    int type = 1,
    required int oid,
    required String msg,
    int mode = 1,
    required String bvid,
    int? progress,
    int? color,
    int? fontSize,
    int? pool,
    bool colorful = false,
    int? checkboxType,
  }) async {
    return _toCore(
      await DanmakuHttp.shootDanmaku(
        type: type,
        oid: oid,
        msg: msg,
        mode: mode,
        bvid: bvid,
        progress: progress,
        color: color,
        fontSize: fontSize,
        pool: pool,
        colorful: colorful,
        checkboxType: checkboxType,
      ),
      (data) => CoreDanmakuPost(dmid: data.dmid),
    );
  }

  @override
  Future<LoadingState<void>> danmakuLike({
    required bool isLike,
    required int cid,
    required int id,
  }) async {
    return await DanmakuHttp.danmakuLike(
      isLike: isLike,
      cid: cid,
      id: id,
    );
  }

  @override
  Future<LoadingState<void>> danmakuReport({
    required int reason,
    required int cid,
    required int id,
    bool block = false,
    String? content,
  }) async {
    return await DanmakuHttp.danmakuReport(
      reason: reason,
      cid: cid,
      id: id,
      block: block,
      content: content,
    );
  }

  @override
  Future<LoadingState<String?>> danmakuRecall({
    required int cid,
    required int id,
  }) async {
    return await DanmakuHttp.danmakuRecall(
      cid: cid,
      id: id,
    );
  }

  @override
  Future<LoadingState<String?>> danmakuEditState({
    required int oid,
    required Iterable<int> ids,
    required int state,
  }) async {
    return await DanmakuHttp.danmakuEditState(
      oid: oid,
      ids: ids,
      state: state,
    );
  }

  @override
  Future<LoadingState<CoreDanmakuSegmentReply>> dmSegMobile({
    required int cid,
    required int segmentIndex,
    int type = 1,
  }) async {
    return _toCore(
      await DmGrpc.dmSegMobile(
        cid: cid,
        segmentIndex: segmentIndex,
        type: type,
      ),
      (data) => CoreDanmakuSegmentReply.fromJson(data.writeToJsonMap()),
    );
  }

  @override
  Future<LoadingState<CoreDanmakuViewReply>> dmView(int aid, int cid) async {
    return _toCore(
      await DmGrpc.dmView(aid, cid),
      (data) => CoreDanmakuViewReply.fromJson(data.writeToJsonMap()),
    );
  }
}