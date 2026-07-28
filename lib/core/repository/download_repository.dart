import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for download/video URL data operations.
abstract class DownloadRepository {
  /// Get the video URL info for a download entry.
  Future<LoadingState<BiliDownloadMediaInfo>> getVideoUrl({
    required CoreBiliDownloadEntryInfo entry,
    CoreSourceInfo? source,
    CorePageInfo? pageData,
    CoreEpInfo? ep,
  });
}
