import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/repository/download_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [DownloadRepository] that delegates to OttoHub SDK APIs.
///
/// Uses [IVideoApi.getDetail] — the SDK exposes a single direct MP4 URL
/// (`VideoDetail.videoUrl`) or an HLS stream (`videoM3u8Url`), so the result
/// is always a single-segment [CoreType1] (mirrors the bilibili durl branch).
/// When neither URL is present the media is not playable → [CoreNone].
class OttoDownloadRepository implements DownloadRepository {
  final OttohubClient _client;

  /// Optional client for DI parity; the bridge registers this repo via
  /// `OttoDownloadRepository.new`, so a standalone client is created when
  /// none is injected (getDetail works token-less for playable URLs).
  OttoDownloadRepository([OttohubClient? client])
      : _client = client ?? OttohubClient();

  @override
  Future<LoadingState<BiliDownloadMediaInfo>> getVideoUrl({
    required CoreBiliDownloadEntryInfo entry,
    CoreSourceInfo? source,
    CorePageInfo? pageData,
    CoreEpInfo? ep,
  }) async {
    try {
      final detail = await _client.video.getDetail(entry.avid);
      final url = detail.videoUrl ?? detail.videoM3u8Url;
      if (url == null) {
        return const Success(CoreNone(message: 'no playable url'));
      }
      final isHls = url.toLowerCase().endsWith('.m3u8');
      return Success(CoreType1(
        from: pageData?.from ?? ep?.from,
        format: isHls ? 'm3u8' : 'mp4',
        description: '',
        playerCodecConfigList: const [],
        segmentList: [
          CoreType1Segment(
            backupUrls: const [],
            bytes: 0,
            md5: '',
            metaUrl: '',
            order: 0,
            url: url,
          ),
        ],
        parseTimestampMilli: DateTime.now().millisecondsSinceEpoch,
        availablePeriodMilli: 0,
        isDownloaded: false,
        isResolved: true,
        timeLength: detail.duration,
        marlinToken: '',
        videoCodecId: 0,
        videoProject: false,
        playerError: 0,
        quality: 0,
        needVip: false,
        needLogin: false,
        intact: false,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoDownloadRepository.getVideoUrl ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }
}
