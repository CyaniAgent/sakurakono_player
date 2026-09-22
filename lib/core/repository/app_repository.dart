import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Generic app-level operations (update check, app metadata).
abstract class AppRepository {
  /// Check whether a newer app version is available.
  ///
  /// [currentVersion] is advisory — adapters may ignore it and compare
  /// against their own build metadata instead.
  Future<LoadingState<CoreUpdateInfo>> checkUpdate({String? currentVersion});

  /// Home-page slideshow (carousel) entries. Empty list when the adapter has
  /// no slideshow source — the UI hides the carousel in that case.
  Future<LoadingState<List<CoreSlide>>> slideshow();
}
