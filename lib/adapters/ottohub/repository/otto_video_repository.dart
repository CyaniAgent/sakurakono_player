import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/utils/subtitle_utils.dart';

/// Implementation of [VideoRepository] that delegates to [IVideoApi].
class OttoVideoRepository implements VideoRepository {
  final OttohubClient _client;

  OttoVideoRepository(this._client);

  IVideoApi get _api => _client.video;

  // ---- conversion helpers ----

  LoadingState<T> _ok<T>(T value) => Success(value);

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  // ---- Core model conversion ----

  /// Parse a publish-date or timestamp string into a Unix timestamp (seconds).
  ///
  /// Accepts ISO 8601 strings (e.g. "2024-01-15T10:30:00Z") or numeric
  /// timestamps. Falls back to 0 if neither format is recognised.
  static int _parsePubdate(String time) {
    if (time.isEmpty) return 0;
    final ts = int.tryParse(time);
    if (ts != null) return ts;
    try {
      return DateTime.parse(time).millisecondsSinceEpoch ~/ 1000;
    } catch (e) {
      debugPrint('OttoVideoRepository._parsePubdate error: $e');
      return 0;
    }
  }

  /// Safely convert a count value to a non-empty string.
  /// Returns '0' for null or empty input.
  static String _safeCount(int? count) {
    if (count == null) return '0';
    final s = count.toString();
    return s.isEmpty ? '0' : s;
  }

  CoreVideoDetailData _toCoreVideoDetail(VideoDetail d) => CoreVideoDetailData(
    bvid: d.vid,
    aid: int.tryParse(d.vid),
    pic: d.coverUrl,
    title: d.title,
    desc: d.intro ?? '',
    duration: d.duration,
    pubdate: _parsePubdate(d.time),
    owner: <String, dynamic>{
      'mid': int.tryParse(d.uid) ?? 0,
      'name': d.username,
      'face': d.avatarUrl ?? '',
    },
    stat: <String, dynamic>{
      'view': d.viewCount,
      'like': d.likeCount,
      'favorite': d.favoriteCount,
      'danmu': d.commentCount ?? 0,
    },
    cid: int.tryParse(d.vid) ?? 0,
  );

  CoreHotVideoItemModel _toCoreHotVideo(VideoSummary s) =>
      CoreHotVideoItemModel(
        aid: s.vid,
        bvid: s.vid.toString(),
        cid: s.vid,
        cover: s.coverUrl,
        title: s.title,
        duration: s.duration,
        pubdate: _parsePubdate(s.time),
        owner: <String, dynamic>{
          'mid': s.uid,
          'name': s.username,
          'face': s.avatarUrl ?? '',
        },
        stat: <String, dynamic>{
          'view': int.tryParse(_safeCount(s.viewCount)) ?? 0,
          'like': int.tryParse(_safeCount(s.likeCount)) ?? 0,
          'favorite': int.tryParse(_safeCount(s.favoriteCount)) ?? 0,
        },
      );

  CorePlayUrlModel _toCorePlayUrl(VideoDetail d) => CorePlayUrlModel(
    durl: <Map<String, dynamic>>[
      if (d.videoUrl != null)
        <String, dynamic>{'url': d.videoUrl},
      if (d.videoM3u8Url != null)
        <String, dynamic>{'url': d.videoM3u8Url},
    ],
    quality: d.videoWidth ?? 0,
    timeLength: d.duration,
  );

  // ---------------------------------------------------------------------------
  // Home / Recommend
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<List<CoreRcmdVideoItemModel>>> rcmdVideoList({
    required int ps,
    required int freshIdx,
  }) async {
    try {
      final result = await _api.getRandom(num: ps);
      return _ok(result.videoList.map(_toCoreRcmdVideo).toList());
    } on ApiException catch (e) {
      debugPrint('OttoVideoRepository.rcmdVideoList ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  CoreRcmdVideoItemModel _toCoreRcmdVideo(VideoSummary s) =>
      CoreRcmdVideoItemModel(
        aid: s.vid,
        bvid: s.vid.toString(),
        cid: s.vid,
        cover: s.coverUrl,
        title: s.title,
        duration: s.duration,
        pubdate: _parsePubdate(s.time),
        goto: 'av',
        owner: <String, dynamic>{
          'mid': s.uid,
          'name': s.username,
          'face': s.avatarUrl ?? '',
        },
        stat: <String, dynamic>{
          'view': int.tryParse(_safeCount(s.viewCount)) ?? 0,
          'like': int.tryParse(_safeCount(s.likeCount)) ?? 0,
          'favorite': int.tryParse(_safeCount(s.favoriteCount)) ?? 0,
        },
      );

  @override
  Future<LoadingState<List<CoreRcmdVideoItemAppModel>>> rcmdVideoListApp({
    required int freshIdx,
  }) async {
    try {
      final result = await _api.getRandom(num: 10);
      return _ok(result.videoList.map(_toCoreRcmdVideoApp).toList());
    } on ApiException catch (e) {
      debugPrint('OttoVideoRepository.rcmdVideoListApp ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  CoreRcmdVideoItemAppModel _toCoreRcmdVideoApp(VideoSummary s) =>
      CoreRcmdVideoItemAppModel(
        aid: s.vid,
        bvid: s.vid.toString(),
        cid: s.vid,
        cover: s.coverUrl,
        title: s.title,
        duration: s.duration,
        pubdate: _parsePubdate(s.time),
        goto: 'av',
        owner: <String, dynamic>{
          'mid': s.uid,
          'name': s.username,
          'face': s.avatarUrl ?? '',
        },
        stat: <String, dynamic>{
          'view': int.tryParse(_safeCount(s.viewCount)) ?? 0,
          'like': int.tryParse(_safeCount(s.likeCount)) ?? 0,
          'favorite': int.tryParse(_safeCount(s.favoriteCount)) ?? 0,
        },
      );

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>>> hotVideoList({
    required int pn,
    required int ps,
  }) async {
    try {
      final result = await _api.getPopular(offset: pn, num: ps);
      return _ok(result.videoList.map(_toCoreHotVideo).toList());
    } on ApiException catch (e) {
      debugPrint('OttoVideoRepository.hotVideoList ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Video detail / play
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CorePlayUrlModel>> videoUrl({
    int? avid,
    String? bvid,
    required int cid,
    int? qn,
    String? epid,
    String? seasonId,
    required bool tryLook,
    required CoreVideoType videoType,
    String? language,
    bool voiceBalance = false,
  }) async {
    try {
      final vid = avid ?? int.tryParse(bvid ?? '');
      if (vid == null) return _err(const ApiException('missing_argument'));
      final result = await _api.getDetail(vid);
      return _ok(_toCorePlayUrl(result));
    } on ApiException catch (e) {
      debugPrint('OttoVideoRepository.videoUrl ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreVideoDetailData>> videoIntro({
    required String bvid,
  }) async {
    try {
      final vid = int.tryParse(bvid);
      if (vid == null) return _err(const ApiException('missing_argument'));
      final result = await _api.getDetail(vid);
      return _ok(_toCoreVideoDetail(result));
    } on ApiException catch (e) {
      debugPrint('OttoVideoRepository.videoIntro ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreVideoRelation>> videoRelation({
    required String bvid,
  }) async {
    // TODO(otto): not yet implemented — OttoHub API does not offer a
    // consolidated relation endpoint.
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>?>> relatedVideoList({
    required String bvid,
  }) async {
    try {
      final vid = int.tryParse(bvid);
      if (vid == null) return _err(const ApiException('missing_argument'));
      final result = await _api.getRelated(vid);
      return _ok(result.videoList.map(_toCoreHotVideo).toList());
    } on ApiException catch (e) {
      debugPrint('OttoVideoRepository.relatedVideoList ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Interactions
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CorePgcLCF>> pgcLikeCoinFav({
    required String epId,
  }) async {
    // TODO(otto): not yet implemented — no PGC concept in OttoHub
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> coinVideo({
    required String bvid,
    required int multiply,
    int selectLike = 0,
  }) async {
    // TODO(otto): not yet implemented — OttoHub API does not have coin/tip
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CorePgcTriple>> pgcTriple({
    required String epId,
    String? seasonId,
  }) async {
    // TODO(otto): not yet implemented — no PGC concept in OttoHub
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreUgcTriple>> ugcTriple({
    required String bvid,
  }) async {
    // TODO(otto): not yet implemented — OttoHub API does not have triple action
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<String>> likeVideo({
    required String bvid,
    required bool type,
  }) async {
    try {
      final vid = int.tryParse(bvid);
      if (vid == null) return _err(const ApiException('missing_argument'));
      // The SDK only exposes a toggle, so read the current like state first
      // and only toggle when it differs from the requested direction.
      final desired = type ? 1 : 0;
      final detail = await _api.getDetail(vid);
      if (detail.ifLike != desired) {
        final result = await _api.toggleLike(vid);
        return _ok(result.ifLike.toString());
      }
      return _ok(detail.ifLike.toString());
    } on ApiException catch (e) {
      debugPrint('OttoVideoRepository.likeVideo ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<void>> dislikeVideo({
    required String bvid,
    required bool type,
  }) async {
    // TODO(otto): not yet implemented — OttoHub API does not have dislike
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> relationMod({
    required int mid,
    required int act,
    required int reSrc,
  }) async {
    // TODO(otto): not yet implemented — uses IFollowingApi.toggleFollow
    // which toggles rather than setting a specific act value.
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> feedDislike({
    required String goto,
    required int id,
    int? reasonId,
    int? feedbackId,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> feedDislikeCancel({
    required String goto,
    required int id,
    int? reasonId,
    int? feedbackId,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Comments
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreReplyInfo?>> replyAdd({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    List? pictures,
    bool syncToDynamic = false,
    Map<String, int>? atNameToMid,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> replyDel({
    required int type,
    required int oid,
    required int rpid,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // PGC follow / unfollow
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<String>> pgcAdd({int? seasonId}) async {
    // TODO(otto): not yet implemented — no PGC concept in OttoHub
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<String>> pgcDel({int? seasonId}) async {
    // TODO(otto): not yet implemented — no PGC concept in OttoHub
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<String>> pgcUpdate({
    required String seasonId,
    required int status,
  }) async {
    // TODO(otto): not yet implemented — no PGC concept in OttoHub
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Stats / discovery
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<String>> onlineTotal({
    int? aid,
    String? bvid,
    required int cid,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreAiConclusionData>> aiConclusion({
    required String bvid,
    required int cid,
    int? upMid,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CorePlayInfoData>> playInfo({
    String? aid,
    String? bvid,
    required int cid,
    String? seasonId,
    String? epId,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<String?> vttSubtitles(
    String subtitleUrl, {
    SubtitleFormat format = SubtitleFormat.vtt,
  }) async {
    // TODO(otto): not yet implemented
    return null;
  }

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>>> getRankVideoList(
    int rid,
  ) async {
    // TODO(otto): not yet implemented — OttoHub API does not have ranking by region
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CorePgcRankItemModel>?>> pgcRankList({
    int day = 3,
    required int seasonType,
  }) async {
    // TODO(otto): not yet implemented — no PGC concept in OttoHub
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CorePgcRankItemModel>?>> pgcSeasonRankList({
    int day = 3,
    required int seasonType,
  }) async {
    // TODO(otto): not yet implemented — no PGC concept in OttoHub
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreVideoShotData>> videoshot({
    required String bvid,
    required int cid,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreVideoNoteData>> getVideoNoteList({
    String? oid,
    int? uperMid,
    required int page,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Popular
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<List<CorePopularSeriesListItem>?>>
      popularSeriesList() async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CorePopularSeriesOneData>> popularSeriesOne({
    required int number,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CorePopularPreciousData>> popularPrecious({
    required int page,
  }) async {
    // TODO(otto): not yet implemented
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Report / heartbeat
  // ---------------------------------------------------------------------------

  @override
  Future<void> historyReport({
    required String aid,
    required int type,
  }) async {
    // TODO(otto): not yet implemented
  }

  @override
  Future<void> heartBeat({
    String? aid,
    String? bvid,
    required String cid,
    required int progress,
    String? epid,
    String? seasonId,
    String? subType,
    required CoreVideoType videoType,
  }) async {
    try {
      final vid = int.tryParse(cid.toString());
      final seconds = int.tryParse(progress.toString());
      if (vid != null && seconds != null) {
        await _api.saveWatchHistory(vid, seconds);
      }
    } on ApiException catch (e) {
      debugPrint('OttoVideoRepository.heartBeat ApiException: ${e.errorCode}');
    }
  }

  @override
  Future<void> roomEntryAction({required int roomId}) async {
    // TODO(otto): not yet implemented — no live concept in OttoHub
  }

  @override
  Future<void> medialistHistory({
    required int desc,
    required String oid,
    required int upperMid,
  }) async {
    // TODO(otto): not yet implemented
  }

  @override
  Future<LoadingState<CorePlayUrlModel>> tvPlayUrl({
    required int cid,
    required int objectId,
    required int playurlType,
    int? qn,
  }) async {
    // TODO(otto): not yet implemented — no DLNA/TV concept in OttoHub
    return _err(const ApiException('not_implemented'));
  }
}
