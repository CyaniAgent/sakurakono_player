import 'package:flutter/material.dart';
import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract repository interface for search operations.
///
/// Defines the contract for search data access. Implementations
/// (e.g. [SearchHttp]) provide adapter-specific logic.
abstract class SearchRepository {
  /// Get search suggestions for the given [term].
  Future<LoadingState<CoreSearchSuggestModel>> searchSuggest({
    required String term,
  });

  /// Search by type (video, user, live, etc.).
  Future<LoadingState<R>> searchByType<R extends CoreSearchNumData>({
    required CoreSearchType searchType,
    required String keyword,
    required int page,
    String? order,
    int? duration,
    int? tids,
    int? orderSort,
    int? userType,
    int? categoryId,
    int? pubBegin,
    int? pubEnd,
    String? gaiaVtoken,
    required ValueChanged<String> onSuccess,
  });

  /// Search all types (comprehensive search).
  Future<LoadingState<CoreSearchAllData>> searchAll({
    required String keyword,
    required int page,
    String? order,
    int? duration,
    int? tids,
    int? orderSort,
    int? userType,
    int? categoryId,
    int? pubBegin,
    int? pubEnd,
  });

  /// Resolve aid/bvid to cid.
  Future<int?> ab2c({
    dynamic aid,
    dynamic bvid,
    int? part,
  });

  /// Resolve aid/bvid to cid with dimension data.
  Future<({int? cid, CoreDimension? dimension})?> ab2cWithDimension({
    dynamic aid,
    dynamic bvid,
    int? part,
  });

  /// Get PGC (番剧/影视) info.
  Future<LoadingState<CorePgcInfoModel>> pgcInfo({
    dynamic seasonId,
    dynamic epId,
  });

  /// Get PUGV (课程) info.
  Future<LoadingState<CorePgcInfoModel>> pugvInfo({
    dynamic seasonId,
    dynamic epId,
  });

  /// Get trending search terms.
  Future<LoadingState<CoreSearchTrendingData>> searchTrending({
    int limit = 30,
    bool needsTop = false,
  });

  /// Get search recommendations.
  Future<LoadingState<CoreSearchRcmdData>> searchRecommend();

  /// Search topics for publishing.
  Future<LoadingState<CoreTopicPubSearchData>> topicPubSearch({
    required String keywords,
    String content = '',
    required int pageNum,
  });
}
