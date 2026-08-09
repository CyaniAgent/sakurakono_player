import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/pgc_types.dart';
import 'package:skf/core/repository/pgc_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Stub [PgcRepository] — OttoHub SDK has no PGC/bangumi API.
class OttoPgcRepository implements PgcRepository {
  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<LoadingState<CorePgcIndexResult>> pgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    seasonType,
    type,
    indexType,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CorePgcIndexConditionData>> pgcIndexCondition({
    Object? seasonType,
    required int type,
    Object? indexType,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<List<CorePgcIndexItem>?>> pgcIndex({
    int? page,
    int? indexType,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<List<CoreTimelineResult>?>> pgcTimeline({
    int types = 1,
    required int before,
    required int after,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CorePgcReviewData>> pgcReview({
    required CorePgcReviewType type,
    required mediaId,
    int sort = 0,
    String? next,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> pgcReviewLike({
    required String mediaId,
    required String reviewId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> pgcReviewDislike({
    required String mediaId,
    required String reviewId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> pgcReviewPost({
    required String mediaId,
    required int score,
    required String content,
    bool shareFeed = false,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> pgcReviewMod({
    required String mediaId,
    required int score,
    required String content,
    required reviewId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> pgcReviewDel({
    required String mediaId,
    required String reviewId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<Map>> seasonStatus(Object seasonId) async =>
      _err(const ApiException('not_implemented'));
}