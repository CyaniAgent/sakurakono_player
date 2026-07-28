import 'package:fixnum/fixnum.dart';
import 'package:skf/core/models/audio_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for audio playback operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class AudioRepository {
  /// Get the playback URL for an audio item.
  Future<LoadingState<CoreAudioPlayUrlResp>> audioPlayUrl({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
    int qn = 80,
    int fnval = 4048,
  });

  /// Get the playlist for audio items.
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
  });

  /// Thumb up (like) an audio item.
  Future<LoadingState<CoreAudioThumbUpResp>> audioThumbUp({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
    required CoreAudioThumbType type,
  });

  /// Triple-like (like, coin, fav) an audio item.
  Future<LoadingState<CoreAudioTripleLikeResp>> audioTripleLike({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
  });

  /// Add coins to an audio item.
  Future<LoadingState<CoreAudioCoinAddResp>> audioCoinAdd({
    required Int64 oid,
    required List<Int64> subId,
    required int itemType,
    required int num,
    bool thumbUp = false,
  });
}
