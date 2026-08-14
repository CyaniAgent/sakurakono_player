import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for download/video URL data operations.
abstract class DownloadRepository {
  /// Get the video URL info for a download entry.
  Future<LoadingState<CoreDownloadMediaInfo>> getVideoUrl({
    required CoreDownloadEntryInfo entry,
    CoreSourceInfo? source,
    CorePageInfo? pageData,
    CoreEpInfo? ep,
  });

  /// List all completed download entries.
  Future<LoadingState<List<CoreDownloadEntryInfo>>> downloadList();

  /// Enqueue a new download entry.
  Future<LoadingState<void>> addDownload(CoreDownloadEntryInfo entry);

  /// Remove a download entry (and its files) by its entry directory path.
  Future<LoadingState<void>> removeDownload(String entryDirPath);

  /// Remove all completed download entries (and their files).
  Future<LoadingState<void>> clearCompletedDownloads();
}
