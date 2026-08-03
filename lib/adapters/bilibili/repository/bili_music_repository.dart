
import 'package:skf/adapters/bilibili/http/music.dart';
import 'package:skf/core/models/music_types.dart';
import 'package:skf/core/repository/music_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [MusicRepository] that delegates to [MusicHttp].
class BiliMusicRepository implements MusicRepository {
  @override
  Future<LoadingState<CoreMusicDetail>> bgmDetail(String musicId) async {
    final result = await MusicHttp.bgmDetail(musicId);
    if (result case Success(:final response)) {
      return Success(CoreMusicDetail.fromJson(response.toJson()));
    }
    return result as LoadingState<CoreMusicDetail>;
  }

  @override
  Future<LoadingState<void>> wishUpdate(
    String musicId,
    bool hasLike,
  ) {
    return MusicHttp.wishUpdate(musicId, hasLike);
  }

  @override
  Future<LoadingState<List<CoreBgmRecommend>?>> bgmRecommend(
    String musicId,
  ) async {
    final result = await MusicHttp.bgmRecommend(musicId);
    if (result case Success(:final response)) {
      return Success(
        response?.map((e) => CoreBgmRecommend.fromJson(e.toJson())).toList(),
      );
    }
    return result as LoadingState<List<CoreBgmRecommend>?>;
  }
}