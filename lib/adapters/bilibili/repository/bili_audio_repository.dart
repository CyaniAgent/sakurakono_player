import 'package:fixnum/fixnum.dart';
import 'package:skf/adapters/bilibili/grpc/audio.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/app/listener/v1.pb.dart';

import 'package:skf/core/models/audio_types.dart';
import 'package:skf/core/repository/audio_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [AudioRepository] that delegates to [AudioGrpc].
class BiliAudioRepository implements AudioRepository {
  // ---- conversion helper ----

  LoadingState<T> _toCore<T, A>(LoadingState<A> state, T Function(A) convert) {
    return switch (state) {
      Success<A>(:final response) => Success<T>(convert(response)),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
      Loading() => LoadingState<T>.loading(),
    };
  }

  @override
  Future<LoadingState<CoreAudioPlayUrlResp>> audioPlayUrl({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
    int qn = 80,
    int fnval = 4048,
  }) async {
    return _toCore(
      await AudioGrpc.audioPlayUrl(
        oid: oid,
        subId: subId,
        itemType: itemType,
        qn: qn,
        fnval: fnval,
      ),
      (data) => CoreAudioPlayUrlResp.fromJson(data.writeToJsonMap()),
    );
  }

  @override
  Future<LoadingState<CoreAudioPlaylistResp>> audioPlayList({
    CoreAudioPlaylistSource? from,
    required Int64 id,
    Int64? oid,
    List<Int64>? subId,
    int? itemType,
    CoreAudioPageOption? pageOpt,
    Int64? extraId,
    String? next,
    int qn = 80,
    int fnval = 4048,
    CoreAudioListOrder order = CoreAudioListOrder.orderNormal,
  }) async {
    return _toCore(
      await AudioGrpc.audioPlayList(
        from: from != null ? PlaylistSource.valueOf(from.value) : null,
        id: id,
        oid: oid,
        subId: subId,
        itemType: itemType,
        pageOpt: pageOpt != null
            ? PageOption(
                pageSize: pageOpt.pageSize,
                direction: pageOpt.direction != null
                    ? PageOption_Direction.valueOf(pageOpt.direction!.value)
                    : null,
              )
            : null,
        extraId: extraId,
        next: next,
        qn: qn,
        fnval: fnval,
        order: ListOrder.valueOf(order.value)!,
      ),
      (data) => CoreAudioPlaylistResp.fromJson(data.writeToJsonMap()),
    );
  }

  @override
  Future<LoadingState<CoreAudioThumbUpResp>> audioThumbUp({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
    required CoreAudioThumbType type,
  }) async {
    return _toCore(
      await AudioGrpc.audioThumbUp(
        oid: oid,
        subId: subId,
        itemType: itemType,
        type: ThumbUpReq_ThumbType.valueOf(type.value)!,
      ),
      (data) => CoreAudioThumbUpResp.fromJson(data.writeToJsonMap()),
    );
  }

  @override
  Future<LoadingState<CoreAudioTripleLikeResp>> audioTripleLike({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
  }) async {
    return _toCore(
      await AudioGrpc.audioTripleLike(
        oid: oid,
        subId: subId,
        itemType: itemType,
      ),
      (data) => CoreAudioTripleLikeResp.fromJson(data.writeToJsonMap()),
    );
  }

  @override
  Future<LoadingState<CoreAudioCoinAddResp>> audioCoinAdd({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
    required int num,
    bool thumbUp = false,
  }) async {
    return _toCore(
      await AudioGrpc.audioCoinAdd(
        oid: oid,
        subId: subId,
        itemType: itemType,
        num: num,
        thumbUp: thumbUp,
      ),
      (data) => CoreAudioCoinAddResp.fromJson(data.writeToJsonMap()),
    );
  }
}