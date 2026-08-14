import 'package:skf/core/models/media_id.dart';
import 'package:skf/core/result/loading_state.dart';

/// Generic watch-progress storage. Replaces adapter-specific progress
/// boxes (e.g. bilibili's GStorage.watchProgress keyed by cid).
abstract class ProgressRepository {
  /// Returns the saved watch progress for [mediaId] in milliseconds,
  /// or null when no progress has been saved yet.
  Future<LoadingState<int?>> getProgress(CoreMediaId mediaId);

  /// Persists [milliseconds] of watch progress for [mediaId].
  Future<LoadingState<void>> setProgress(
    CoreMediaId mediaId,
    int milliseconds,
  );

  /// Removes any saved watch progress for [mediaId].
  Future<LoadingState<void>> clearProgress(CoreMediaId mediaId);
}
