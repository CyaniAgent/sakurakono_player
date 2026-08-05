import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/music_types.dart';
import 'package:skf/core/repository/music_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Stub [MusicRepository] — OttoHub SDK has no BGM/music API.
class OttoMusicRepository implements MusicRepository {
  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<LoadingState<CoreMusicDetail>> bgmDetail(String musicId) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> wishUpdate(String musicId, bool hasLike) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<List<CoreBgmRecommend>?>> bgmRecommend(
      String musicId) async =>
      _err(const ApiException('not_implemented'));
}