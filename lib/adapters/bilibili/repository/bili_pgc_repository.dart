import 'package:skf/adapters/bilibili/http/pgc.dart';
import 'package:skf/adapters/bilibili/models/common/pgc_review_type.dart';
import 'package:skf/core/models/pgc_types.dart';
import 'package:skf/core/repository/pgc_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [PgcRepository] that delegates to [PgcHttp].
class BiliPgcRepository implements PgcRepository {
  @override
  Future<LoadingState<CorePgcIndexResult>> pgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    seasonType,
    type,
    indexType,
  }) async {
    final result = await PgcHttp.pgcIndexResult(
      page: page,
      params: params,
      seasonType: seasonType,
      type: type,
      indexType: indexType,
    );
    if (result case Success(response: final r)) {
      return Success(CorePgcIndexResult.fromJson(r.toJson()));
    }
    return result as LoadingState<CorePgcIndexResult>;
  }

  @override
  Future<LoadingState<CorePgcIndexConditionData>> pgcIndexCondition({
    Object? seasonType,
    required int type,
    Object? indexType,
  }) async {
    final result = await PgcHttp.pgcIndexCondition(
      seasonType: seasonType,
      type: type,
      indexType: indexType,
    );
    if (result case Success(response: final r)) {
      return Success(CorePgcIndexConditionData.fromJson(r.toJson()));
    }
    return result as LoadingState<CorePgcIndexConditionData>;
  }

  @override
  Future<LoadingState<List<CorePgcIndexItem>?>> pgcIndex({
    int? page,
    int? indexType,
  }) async {
    final result = await PgcHttp.pgcIndex(
      page: page,
      indexType: indexType,
    );
    if (result case Success(response: final r)) {
      return Success(
        r?.map((item) => CorePgcIndexItem.fromJson(item.toJson())).toList(),
      );
    }
    return result as LoadingState<List<CorePgcIndexItem>?>;
  }

  @override
  Future<LoadingState<List<CoreTimelineResult>?>> pgcTimeline({
    int types = 1,
    required int before,
    required int after,
  }) async {
    final result = await PgcHttp.pgcTimeline(
      types: types,
      before: before,
      after: after,
    );
    if (result case Success(response: final r)) {
      return Success(
        r?.map((item) => CoreTimelineResult.fromJson(item.toJson())).toList(),
      );
    }
    return result as LoadingState<List<CoreTimelineResult>?>;
  }

  @override
  Future<LoadingState<CorePgcReviewData>> pgcReview({
    required CorePgcReviewType type,
    required mediaId,
    int sort = 0,
    String? next,
  }) async {
    final result = await PgcHttp.pgcReview(
      type: _adaptPgcReviewType(type),
      mediaId: mediaId,
      sort: sort,
      next: next,
    );
    if (result case Success(response: final r)) {
      return Success(CorePgcReviewData.fromJson(r.toJson()));
    }
    return result as LoadingState<CorePgcReviewData>;
  }

  @override
  Future<LoadingState<void>> pgcReviewLike({
    required String mediaId,
    required String reviewId,
  }) {
    return PgcHttp.pgcReviewLike(
      mediaId: mediaId,
      reviewId: reviewId,
    );
  }

  @override
  Future<LoadingState<void>> pgcReviewDislike({
    required String mediaId,
    required String reviewId,
  }) {
    return PgcHttp.pgcReviewDislike(
      mediaId: mediaId,
      reviewId: reviewId,
    );
  }

  @override
  Future<LoadingState<void>> pgcReviewPost({
    required String mediaId,
    required int score,
    required String content,
    bool shareFeed = false,
  }) {
    return PgcHttp.pgcReviewPost(
      mediaId: mediaId,
      score: score,
      content: content,
      shareFeed: shareFeed,
    );
  }

  @override
  Future<LoadingState<void>> pgcReviewMod({
    required String mediaId,
    required int score,
    required String content,
    required reviewId,
  }) {
    return PgcHttp.pgcReviewMod(
      mediaId: mediaId,
      score: score,
      content: content,
      reviewId: reviewId,
    );
  }

  @override
  Future<LoadingState<void>> pgcReviewDel({
    required String mediaId,
    required String reviewId,
  }) {
    return PgcHttp.pgcReviewDel(
      mediaId: mediaId,
      reviewId: reviewId,
    );
  }

  @override
  Future<LoadingState<Map>> seasonStatus(Object seasonId) {
    return PgcHttp.seasonStatus(seasonId);
  }

  static PgcReviewType _adaptPgcReviewType(CorePgcReviewType type) =>
      switch (type) {
        CorePgcReviewType.long => PgcReviewType.long,
        CorePgcReviewType.short => PgcReviewType.short,
      };
}
