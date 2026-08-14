import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/repository/app_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// [AppRepository] for OttoHub.
///
/// OttoHub has no update mechanism — there is no release channel to check,
/// so [checkUpdate] always reports "no update".
class OttoAppRepository implements AppRepository {
  @override
  Future<LoadingState<CoreUpdateInfo>> checkUpdate({
    String? currentVersion,
  }) async =>
      const Success(CoreUpdateInfo(hasUpdate: false));
}
