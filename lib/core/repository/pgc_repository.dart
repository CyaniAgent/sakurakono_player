import 'package:skf/core/models/pgc_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for PGC (番剧/bangumi/anime) data operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class PgcRepository {
  /// Get PGC index result (paginated season list with filters).
  Future<LoadingState<CorePgcIndexResult>> pgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    seasonType,
    type,
    indexType,
  });

  /// Get PGC index filter conditions.
  Future<LoadingState<CorePgcIndexConditionData>> pgcIndexCondition({
    Object? seasonType,
    required Object type,
    Object? indexType,
  });

  /// Get PGC index list (simplified, with preset filters).
  Future<LoadingState<List<CorePgcIndexItem>?>> pgcIndex({
    int? page,
    int? indexType,
  });

  /// Get PGC timeline (broadcast schedule).
  Future<LoadingState<List<CoreTimelineResult>?>> pgcTimeline({
    int types = 1,
    required int before,
    required int after,
  });

  /// Get PGC reviews.
  Future<LoadingState<CorePgcReviewData>> pgcReview({
    required CorePgcReviewType type,
    required mediaId,
    int sort = 0,
    String? next,
  });

  /// Like a PGC review.
  Future<LoadingState<void>> pgcReviewLike({
    required Object mediaId,
    required Object reviewId,
  });

  /// Dislike a PGC review.
  Future<LoadingState<void>> pgcReviewDislike({
    required Object mediaId,
    required Object reviewId,
  });

  /// Post a new PGC review.
  Future<LoadingState<void>> pgcReviewPost({
    required Object mediaId,
    required int score,
    required String content,
    bool shareFeed = false,
  });

  /// Modify an existing PGC review.
  Future<LoadingState<void>> pgcReviewMod({
    required Object mediaId,
    required int score,
    required String content,
    required reviewId,
  });

  /// Delete a PGC review.
  Future<LoadingState<void>> pgcReviewDel({
    required Object mediaId,
    required Object reviewId,
  });

  /// Get season status (subscription info).
  Future<LoadingState<Map>> seasonStatus(Object seasonId);
}
