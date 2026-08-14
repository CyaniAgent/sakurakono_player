import 'package:skf/core/models/media_id.dart';
import 'package:skf/core/repository/progress_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/utils/storage.dart';

/// Bilibili [ProgressRepository]: backed by the adapter's existing
/// `GStorage.watchProgress` box, keyed by [CoreMediaId.id] (the cid).
class BiliProgressRepository implements ProgressRepository {
  @override
  Future<LoadingState<int?>> getProgress(CoreMediaId mediaId) async {
    try {
      return Success(GStorage.watchProgress.get(mediaId.id));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<void>> setProgress(
    CoreMediaId mediaId,
    int milliseconds,
  ) async {
    try {
      await GStorage.watchProgress.put(mediaId.id, milliseconds);
      return const Success<void>(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<void>> clearProgress(CoreMediaId mediaId) async {
    try {
      await GStorage.watchProgress.delete(mediaId.id);
      return const Success<void>(null);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
