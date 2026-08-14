import 'package:skf/core/models/media_id.dart';
import 'package:skf/core/repository/progress_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/utils/storage.dart';

/// OttoHub [ProgressRepository]: OttoHub has no cid concept, so progress is
/// stored in the generic `GStorage.setting` box under a `progress:<id>` key.
class OttoProgressRepository implements ProgressRepository {
  static String _key(CoreMediaId mediaId) => 'progress:${mediaId.id}';

  @override
  Future<LoadingState<int?>> getProgress(CoreMediaId mediaId) async {
    try {
      return Success(GStorage.setting.get(_key(mediaId)) as int?);
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
      await GStorage.setting.put(_key(mediaId), milliseconds);
      return const Success<void>(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<void>> clearProgress(CoreMediaId mediaId) async {
    try {
      await GStorage.setting.delete(_key(mediaId));
      return const Success<void>(null);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
