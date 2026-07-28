import 'package:skf/core/models/music_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for BGM (music) data operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class MusicRepository {
  /// Get detailed info for a BGM by its id.
  Future<LoadingState<CoreMusicDetail>> bgmDetail(String musicId);

  /// Update the wish/like state for a BGM.
  Future<LoadingState<void>> wishUpdate(String musicId, bool hasLike);

  /// Get BGM recommendations for a given music id.
  Future<LoadingState<List<CoreBgmRecommend>?>> bgmRecommend(String musicId);
}
