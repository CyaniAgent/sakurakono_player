import 'package:fixnum/fixnum.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/app/dynamic/v2.pb.dart'
    show OpusSpaceFlowResp;
import 'package:skf/adapters/bilibili/grpc/bilibili/app/interfaces/v1.pb.dart'
    show SearchArchiveReply;
import 'package:skf/adapters/bilibili/grpc/space.dart';

import 'package:skf/core/models/space_types.dart';
import 'package:skf/core/repository/space_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [SpaceRepository] that delegates to [SpaceGrpc].
class BiliSpaceRepository implements SpaceRepository {
  @override
  Future<LoadingState<CoreOpusSpaceFlowResp>> opusSpaceFlow({
    required int hostMid,
    String? next,
    required String filterType,
  }) async {
    return _toCore(
      await SpaceGrpc.opusSpaceFlow(
        hostMid: hostMid,
        next: next,
        filterType: filterType,
      ),
      _convertOpusSpaceFlowResp,
    );
  }

  @override
  Future<LoadingState<CoreSearchArchiveReply>> searchArchive({
    required String keyword,
    required Int64 mid,
    required int pn,
    required Int64 ps,
  }) async {
    return _toCore(
      await SpaceGrpc.searchArchive(
        keyword: keyword,
        mid: mid,
        pn: pn,
        ps: ps,
      ),
      _convertSearchArchiveReply,
    );
  }
}

/// Converts an adapter [LoadingState] to the core [LoadingState].
LoadingState<T> _toCore<T, A>(LoadingState<A> state, T Function(A) convert) {
  return switch (state) {
    Success<A>(:final response) => Success<T>(convert(response)),
    Error(:final errMsg, :final code) => Error(errMsg, code: code),
    Loading() => LoadingState<T>.loading(),
  };
}

// ── Model conversion helpers ───────────────────────────────────────────

CoreOpusSpaceFlowResp _convertOpusSpaceFlowResp(OpusSpaceFlowResp resp) {
  return CoreOpusSpaceFlowResp(
    itemList: resp.itemList as List<dynamic>?,
    nextPage: resp.nextPage,
    hostUpOpusCollection: resp.hostUpOpusCollection,
    hostUpNoteNavBar: resp.hostUpNoteNavBar,
  );
}

CoreSearchArchiveReply _convertSearchArchiveReply(SearchArchiveReply reply) {
  return CoreSearchArchiveReply(
    total: reply.total.toInt(),
    archives: reply.archives as List<dynamic>?,
  );
}