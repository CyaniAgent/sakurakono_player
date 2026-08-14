import 'package:dio/dio.dart';
import 'package:skf/adapters/bilibili/http/api.dart';
import 'package:skf/adapters/bilibili/http/browser_ua.dart';
import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/adapters/bilibili/utils/accounts/account.dart';
import 'package:skf/build_config.dart';
import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/repository/app_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [AppRepository] backed by the GitHub releases API.
///
/// Mirrors the logic of `Update.checkUpdate` (lib/adapters/bilibili/utils/
/// update.dart) without touching it: the newest release is fetched from
/// [Api.latestApp], and an update is reported when its `created_at` is newer
/// than [BuildConfig.buildTime].
class BiliAppRepository implements AppRepository {
  @override
  Future<LoadingState<CoreUpdateInfo>> checkUpdate({
    String? currentVersion,
  }) async {
    try {
      final res = await Request().get(
        Api.latestApp,
        options: Options(
          headers: {'user-agent': BrowserUa.mob},
          extra: {'account': const NoAccount()},
        ),
      );
      final data = res.data;
      if (data is! List || data.isEmpty) {
        return const Error('检查更新失败，GitHub接口未返回数据，请检查网络');
      }
      return Success(_toUpdateInfo(data.first as Map));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// Parses a single GitHub release entry into [CoreUpdateInfo].
  static CoreUpdateInfo _toUpdateInfo(Map data) {
    final int latest =
        DateTime.parse(data['created_at'] as String).millisecondsSinceEpoch ~/
            1000;
    final assets = data['assets'];
    final String? downloadUrl = assets is List && assets.isNotEmpty
        ? (assets.first as Map)['browser_download_url'] as String?
        : null;
    return CoreUpdateInfo(
      hasUpdate: BuildConfig.buildTime < latest,
      latestVersion: data['tag_name'] as String?,
      downloadUrl: downloadUrl,
      releaseNotes: data['body'] as String?,
      publishedAt: data['created_at'] as String?,
    );
  }
}
