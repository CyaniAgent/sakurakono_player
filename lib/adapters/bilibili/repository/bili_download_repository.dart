import 'package:skf/adapters/bilibili/http/download.dart';
import 'package:skf/adapters/bilibili/models_new/download/bili_download_entry_info.dart';
import 'package:skf/adapters/bilibili/models_new/download/bili_download_media_file_info.dart'
    as adapter;
import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/repository/download_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [DownloadRepository] that delegates to [DownloadHttp].
class BiliDownloadRepository implements DownloadRepository {
  @override
  Future<LoadingState<BiliDownloadMediaInfo>> getVideoUrl({
    required CoreBiliDownloadEntryInfo entry,
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

  BiliDownloadMediaInfo _toCoreMediaInfo(adapter.BiliDownloadMediaInfo info) {
    return switch (info) {
      adapter.Type1 t => CoreType1.fromJson(t.toJson()),
      adapter.Type2 t => CoreType2.fromJson(t.toJson()),
      adapter.None t => CoreNone(message: t.message),
    };
  }
}
