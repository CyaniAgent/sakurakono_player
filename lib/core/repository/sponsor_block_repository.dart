import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for SponsorBlock operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class SponsorBlockRepository {
  /// Get skip segments for a video.
  Future<LoadingState<List<CoreSegmentItemModel>>> getSkipSegments({
    required String bvid,
    required int cid,
  });

  /// Vote on a sponsor time segment.
  Future<LoadingState<void>> voteOnSponsorTime({
    required String uuid,
    int? type,
    CoreSegmentType? category,
  });

  /// Mark a sponsor time as viewed.
  Future<LoadingState<void>> viewedVideoSponsorTime(String uuid);

  /// Check uptime status of the SponsorBlock server.
  Future<LoadingState<void>> uptimeStatus();

  /// Get user info from SponsorBlock.
  Future<LoadingState<CoreUserInfo>> userInfo(
    List<String> query, {
    String? userId,
  });

  /// Post skip segments for a video.
  Future<LoadingState<List<CoreSegmentItemModel>>> postSkipSegments({
    required String bvid,
    required int cid,
    required double videoDuration,
    required List<CorePostSegmentModel> segments,
  });

  /// Get port video mapping.
  Future<LoadingState<String>> getPortVideo({
    required String bvid,
    required int cid,
  });

  /// Post port video mapping.
  Future<LoadingState<String>> postPortVideo({
    required String bvid,
    required int cid,
    required String ytbId,
    required int videoDuration,
  });
}
