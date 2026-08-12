import 'package:fixnum/fixnum.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/audio_types.dart';
import 'package:skf/core/repository/audio_repository.dart';
import 'package:skf/core/result/loading_state.dart';

// impossible — no SDK API (OttoHub 无此域)
/// Stub [AudioRepository] — OttoHub SDK has no audio playback API.
class OttoAudioRepository implements AudioRepository {
  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<LoadingState<CoreAudioPlayUrlResp>> audioPlayUrl({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
    int qn = 80,
    int fnval = 4048,
  }) async =>
      _err(const ApiException('not_implemented'));

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
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreAudioThumbUpResp>> audioThumbUp({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
    required CoreAudioThumbType type,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreAudioTripleLikeResp>> audioTripleLike({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreAudioCoinAddResp>> audioCoinAdd({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
    required int num,
    bool thumbUp = false,
  }) async =>
      _err(const ApiException('not_implemented'));
}