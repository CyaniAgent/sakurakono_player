import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/utils/subtitle_utils.dart';

/// Abstract interface for video data operations.
///
/// Mirrors the methods of [VideoHttp] as instance methods. All data-fetching
/// methods return [LoadingState] for async results that may be loading,
/// successful, or failed. Report/heartbeat methods return bare [Future]<[void]>.
abstract class VideoRepository {
  // ---------------------------------------------------------------------------
  // Home / Recommend
  // ---------------------------------------------------------------------------

  /// Web-end recommended video list.
  Future<LoadingState<List<CoreRcmdVideoItemModel>>> rcmdVideoList({
    required int ps,
    required int freshIdx,
  });

  /// App-end recommended video list.
  Future<LoadingState<List<CoreRcmdVideoItemAppModel>>> rcmdVideoListApp({
    required int freshIdx,
  });

  /// Hot / popular video list.
  Future<LoadingState<List<CoreHotVideoItemModel>>> hotVideoList({
    required int pn,
    required int ps,
  });

  // ---------------------------------------------------------------------------
  // Video detail / play
  // ---------------------------------------------------------------------------

  /// Get video playback URL.
  Future<LoadingState<CorePlayUrlModel>> videoUrl({
    int? avid,
    String? bvid,
    required int cid,
    int? qn,
    Object? epid,
    Object? seasonId,
    required bool tryLook,
    required CoreVideoType videoType,
    String? language,
    bool voiceBalance = false,
  });

  /// Get video introduction (title, description, etc.).
  Future<LoadingState<CoreVideoDetailData>> videoIntro({
    required String bvid,
  });

  /// Get video relation (like, coin, fav status).
  Future<LoadingState<CoreVideoRelation>> videoRelation({
    required String bvid,
  });

  /// Get related video list.
  Future<LoadingState<List<CoreHotVideoItemModel>?>> relatedVideoList({
    required String bvid,
  });

  // ---------------------------------------------------------------------------
  // Interactions
  // ---------------------------------------------------------------------------

  /// Get PGC like / coin / fav status.
  Future<LoadingState<CorePgcLCF>> pgcLikeCoinFav({
    required Object epId,
  });

  /// Coin (tip) a video.
  Future<LoadingState<void>> coinVideo({
    required String bvid,
    required int multiply,
    int selectLike = 0,
  });

  /// PGC triple (like + coin + fav).
  Future<LoadingState<CorePgcTriple>> pgcTriple({
    required Object epId,
    Object? seasonId,
  });

  /// UGC triple (like + coin + fav).
  Future<LoadingState<CoreUgcTriple>> ugcTriple({
    required String bvid,
  });

  /// (Un)like a video.
  Future<LoadingState<String>> likeVideo({
    required String bvid,
    required bool type,
  });

  /// (Un)dislike a video.
  Future<LoadingState<void>> dislikeVideo({
    required String bvid,
    required bool type,
  });

  /// Modify user relationship (follow/unfollow).
  Future<LoadingState<void>> relationMod({
    required int mid,
    required int act,
    required int reSrc,
  });

  /// Report a feed item as disliked / not interested.
  Future<LoadingState<void>> feedDislike({
    required String goto,
    required int id,
    int? reasonId,
    int? feedbackId,
  });

  /// Cancel a feed dislike report.
  Future<LoadingState<void>> feedDislikeCancel({
    required String goto,
    required int id,
    int? reasonId,
    int? feedbackId,
  });

  // ---------------------------------------------------------------------------
  // Comments
  // ---------------------------------------------------------------------------

  /// Add a reply (comment).
  Future<LoadingState<CoreReplyInfo?>> replyAdd({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    List? pictures,
    bool syncToDynamic = false,
    Map<String, int>? atNameToMid,
  });

  /// Delete a reply (comment).
  Future<LoadingState<void>> replyDel({
    required int type,
    required int oid,
    required int rpid,
  });

  // ---------------------------------------------------------------------------
  // PGC follow / unfollow
  // ---------------------------------------------------------------------------

  /// Follow a PGC (season).
  Future<LoadingState<String>> pgcAdd({int? seasonId});

  /// Unfollow a PGC (season).
  Future<LoadingState<String>> pgcDel({int? seasonId});

  /// Update PGC follow status.
  Future<LoadingState<String>> pgcUpdate({
    required String seasonId,
    required int status,
  });

  // ---------------------------------------------------------------------------
  // Stats / discovery
  // ---------------------------------------------------------------------------

  /// Get concurrent viewer count.
  Future<LoadingState<String>> onlineTotal({
    int? aid,
    String? bvid,
    required int cid,
  });

  /// Get AI-generated conclusion for a video.
  Future<LoadingState<CoreAiConclusionData>> aiConclusion({
    required String bvid,
    required int cid,
    int? upMid,
  });

  /// Get video playback info (quality, codec, etc.).
  Future<LoadingState<CorePlayInfoData>> playInfo({
    String? aid,
    String? bvid,
    required int cid,
    Object? seasonId,
    dynamic epId,
  });

  /// Get VTT subtitles.
  Future<String?> vttSubtitles(
    String subtitleUrl, {
    SubtitleFormat format = SubtitleFormat.vtt,
  });

  /// Get ranked video list for a region.
  Future<LoadingState<List<CoreHotVideoItemModel>>> getRankVideoList(int rid);

  /// Get PGC rank list.
  Future<LoadingState<List<CorePgcRankItemModel>?>> pgcRankList({
    int day = 3,
    required int seasonType,
  });

  /// Get PGC season rank list.
  Future<LoadingState<List<CorePgcRankItemModel>?>> pgcSeasonRankList({
    int day = 3,
    required int seasonType,
  });

  /// Get video shot (thumbnail sprite).
  Future<LoadingState<CoreVideoShotData>> videoshot({
    required String bvid,
    required int cid,
  });

  /// Get video note list.
  Future<LoadingState<CoreVideoNoteData>> getVideoNoteList({
    Object? oid,
    int? uperMid,
    required int page,
  });

  // ---------------------------------------------------------------------------
  // Popular
  // ---------------------------------------------------------------------------

  /// Get popular series list.
  Future<LoadingState<List<CorePopularSeriesListItem>?>> popularSeriesList();

  /// Get a specific popular series.
  Future<LoadingState<CorePopularSeriesOneData>> popularSeriesOne({
    required int number,
  });

  /// Get precious (elite) popular content.
  Future<LoadingState<CorePopularPreciousData>> popularPrecious({
    required int page,
  });

  // ---------------------------------------------------------------------------
  // Report / heartbeat
  // ---------------------------------------------------------------------------

  /// Report video playback history.
  Future<void> historyReport({
    required Object aid,
    required Object type,
  });

  /// Send playback heartbeat.
  Future<void> heartBeat({
    Object? aid,
    Object? bvid,
    required Object cid,
    required Object progress,
    Object? epid,
    Object? seasonId,
    Object? subType,
    required CoreVideoType videoType,
  });

  /// Report room entry action (live).
  Future<void> roomEntryAction({required Object roomId});

  /// Report medialist (playlist) history.
  Future<void> medialistHistory({
    required int desc,
    required Object oid,
    required Object upperMid,
  });

  /// Get TV/DLNA playback URL.
  Future<LoadingState<CorePlayUrlModel>> tvPlayUrl({
    required int cid,
    required int objectId,
    required int playurlType,
    int? qn,
  });
}
