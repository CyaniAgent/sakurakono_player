import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/repository/download_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Stub [DownloadRepository] — OttoHub SDK has no download API.
class OttoDownloadRepository implements DownloadRepository {
  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<LoadingState<BiliDownloadMediaInfo>> getVideoUrl({
    required CoreBiliDownloadEntryInfo entry,
    CoreSourceInfo? source,
    CorePageInfo? pageData,
    CoreEpInfo? ep,
  }) async =>
      _err(const ApiException('not_implemented'));
}