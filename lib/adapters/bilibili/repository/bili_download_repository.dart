import 'package:collection/collection.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/adapters/bilibili/common/setting_providers.dart';
import 'package:skf/adapters/bilibili/http/download.dart';
import 'package:skf/adapters/bilibili/models_new/download/bili_download_entry_info.dart';
import 'package:skf/adapters/bilibili/models_new/download/bili_download_media_file_info.dart'
    as adapter;
import 'package:skf/adapters/bilibili/services/download/download_service.dart';
import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/repository/download_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [DownloadRepository] that delegates to [DownloadHttp]
/// and [DownloadService].
class BiliDownloadRepository implements DownloadRepository {
  @override
  Future<LoadingState<CoreDownloadMediaInfo>> getVideoUrl({
    required CoreDownloadEntryInfo entry,
    CoreSourceInfo? source,
    CorePageInfo? pageData,
    CoreEpInfo? ep,
  }) async {
    try {
      final adapterEntry = BiliDownloadEntryInfo.fromJson(entry.toJson());
      final adapterSource =
          source != null ? SourceInfo.fromJson(source.toJson()) : null;
      final adapterPageData =
          pageData != null ? PageInfo.fromJson(pageData.toJson()) : null;
      final adapterEp = ep != null ? EpInfo.fromJson(ep.toJson()) : null;

      final result = await DownloadHttp.getVideoUrl(
        entry: adapterEntry,
        source: adapterSource,
        pageData: adapterPageData,
        ep: adapterEp,
      );
      return Success(_toCoreMediaInfo(result));
    } catch (e) {
      return Error(e.toString());
    }
  }

  CoreDownloadMediaInfo _toCoreMediaInfo(adapter.BiliDownloadMediaInfo info) {
    return switch (info) {
      adapter.Type1 t => CoreType1.fromJson(t.toJson()),
      adapter.Type2 t => CoreType2.fromJson(t.toJson()),
      adapter.None t => CoreNone(message: t.message),
    };
  }

  @override
  Future<LoadingState<List<CoreDownloadEntryInfo>>> downloadList() async {
    try {
      final service = appRead(downloadServiceProvider);
      return Success([
        for (final e in service.downloadList)
          CoreDownloadEntryInfo.fromJson(e.toJson())
            ..pageDirPath = e.pageDirPath
            ..entryDirPath = e.entryDirPath,
      ]);
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<void>> addDownload(CoreDownloadEntryInfo entry) async {
    // DownloadService has no public API to enqueue an arbitrary entry — only
    // downloadVideo()/downloadBangumi() which build entries from page/season
    // data. A DownloadService.addEntry() API is missing; do not fake it.
    return const Error('not_implemented');
  }

  @override
  Future<LoadingState<void>> removeDownload(String entryDirPath) async {
    try {
      final service = appRead(downloadServiceProvider);
      final entry = service.downloadList
              .where((e) => e.entryDirPath == entryDirPath)
              .firstOrNull ??
          service.waitDownloadQueue
              .where((e) => e.entryDirPath == entryDirPath)
              .firstOrNull;
      if (entry == null) {
        return const Error('not_found');
      }
      await service.deleteDownload(
        entry: entry,
        removeList: true,
        removeQueue: true,
      );
      return const Success<void>(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<void>> clearCompletedDownloads() async {
    try {
      final service = appRead(downloadServiceProvider);
      // Snapshot: deleteDownload() mutates downloadList while iterating.
      final completed = List<BiliDownloadEntryInfo>.of(service.downloadList);
      for (final e in completed) {
        await service.deleteDownload(
          entry: e,
          removeList: true,
          removeQueue: false,
          refresh: false,
        );
      }
      service.flagNotifier.refresh();
      return const Success<void>(null);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
