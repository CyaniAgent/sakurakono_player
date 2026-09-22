import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/repository/app_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// [AppRepository] for OttoHub.
///
/// OttoHub has no update mechanism — there is no release channel to check,
/// so [checkUpdate] always reports "no update". The slideshow comes from the
/// old system module (`/system/slideshow`).
class OttoAppRepository implements AppRepository {
  OttoAppRepository(this._api);

  final OttohubClient _api;

  @override
  Future<LoadingState<CoreUpdateInfo>> checkUpdate({
    String? currentVersion,
  }) async =>
      const Success(CoreUpdateInfo(hasUpdate: false));

  @override
  Future<LoadingState<List<CoreSlide>>> slideshow() async {
    try {
      final slides = await _api.oldSystem.getSlideshow();
      return Success(
        slides
            .map(
              (s) => CoreSlide(
                imgUrl: s.imgUrl,
                title: s.title,
                href: s.href,
              ),
            )
            .toList(),
      );
    } on ApiException catch (e) {
      return Error(e.errorCode, code: e.httpStatus);
    } catch (e) {
      // SDK 对非 success 响应直接解包 data(可能抛类型错误):统一降级错误态。
      return Error(e.toString());
    }
  }
}
