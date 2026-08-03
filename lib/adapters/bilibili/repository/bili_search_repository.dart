import 'package:flutter/material.dart';
import 'package:skf/adapters/bilibili/http/search.dart';

import 'package:skf/adapters/bilibili/models/common/search/search_type.dart'
    show SearchType;
import 'package:skf/adapters/bilibili/models/search/result.dart'
    show SearchAllData, SearchNumData;
import 'package:skf/adapters/bilibili/models/search/suggest.dart'
    show SearchSuggestModel;
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_topic_pub_search/data.dart'
    show TopicPubSearchData;
import 'package:skf/adapters/bilibili/models_new/pgc/pgc_info_model/result.dart'
    show PgcInfoModel;
import 'package:skf/adapters/bilibili/models_new/search/search_rcmd/data.dart'
    show SearchRcmdData;
import 'package:skf/adapters/bilibili/models_new/search/search_trending/data.dart'
    show SearchTrendingData;
import 'package:skf/adapters/bilibili/models_new/video/video_detail/dimension.dart'
    show Dimension;
import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Bilibili implementation of [SearchRepository].
///
/// Delegates all methods to [SearchHttp] static methods, converting
/// the adapter-specific [LoadingState] to the core
/// [LoadingState] type.
class BiliSearchRepository implements SearchRepository {
  @override
  Future<LoadingState<CoreSearchSuggestModel>> searchSuggest({
    required String term,
  }) async {
    return _toCore(
      await SearchHttp.searchSuggest(term: term),
      _convertSuggestModel,
    );
  }

  Future<LoadingState<R>> searchByType<R extends SearchNumData<dynamic>>({
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
  }) async {
    final result = await SearchHttp.searchByType<R>(
      searchType: _toSearchType(searchType),
      keyword: keyword,
      page: page,
      order: order,
      duration: duration,
      tids: tids,
      orderSort: orderSort,
      userType: userType,
      categoryId: categoryId,
      pubBegin: pubBegin,
      pubEnd: pubEnd,
      gaiaVtoken: gaiaVtoken,
      onSuccess: onSuccess,
    );
    return result;
  }

  @override
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
  }) async {
    return _toCore(
      await SearchHttp.searchAll(
        keyword: keyword,
        page: page,
        order: order,
        duration: duration,
        tids: tids,
        orderSort: orderSort,
        userType: userType,
        categoryId: categoryId,
        pubBegin: pubBegin,
        pubEnd: pubEnd,
      ),
      _convertSearchAllData,
    );
  }

  @override
  Future<int?> ab2c({
    dynamic aid,
    dynamic bvid,
    int? part,
  }) {
    return SearchHttp.ab2c(aid: aid, bvid: bvid, part: part);
  }

  @override
  Future<({int? cid, CoreDimension? dimension})?> ab2cWithDimension({
    dynamic aid,
    dynamic bvid,
    int? part,
  }) async {
    final result = await SearchHttp.ab2cWithDimension(
      aid: aid,
      bvid: bvid,
      part: part,
    );
    if (result == null) return null;
    return (
      cid: result.cid,
      dimension: result.dimension != null
          ? _convertDimension(result.dimension!)
          : null,
    );
  }

  @override
  Future<LoadingState<CorePgcInfoModel>> pgcInfo({
    dynamic seasonId,
    dynamic epId,
  }) async {
    return _toCore(
      await SearchHttp.pgcInfo(
        seasonId: seasonId,
        epId: epId,
      ),
      _convertPgcInfoModel,
    );
  }

  @override
  Future<LoadingState<CorePgcInfoModel>> pugvInfo({
    dynamic seasonId,
    dynamic epId,
  }) async {
    return _toCore(
      await SearchHttp.pugvInfo(
        seasonId: seasonId,
        epId: epId,
      ),
      _convertPgcInfoModel,
    );
  }

  @override
  Future<LoadingState<CoreSearchTrendingData>> searchTrending({
    int limit = 30,
    bool needsTop = false,
  }) async {
    return _toCore(
      await SearchHttp.searchTrending(
        limit: limit,
        needsTop: needsTop,
      ),
      _convertSearchTrendingData,
    );
  }

  @override
  Future<LoadingState<CoreSearchRcmdData>> searchRecommend() async {
    return _toCore(
      await SearchHttp.searchRecommend(),
      _convertSearchRcmdData,
    );
  }

  @override
  Future<LoadingState<CoreTopicPubSearchData>> topicPubSearch({
    required String keywords,
    String content = '',
    required int pageNum,
  }) async {
    return _toCore(
      await SearchHttp.topicPubSearch(
        keywords: keywords,
        content: content,
        pageNum: pageNum,
      ),
      _convertTopicPubSearchData,
    );
  }
}

/// Converts an adapter [LoadingState] to the core [LoadingState].
LoadingState<T> _toCore<T, A>(LoadingState<A> state, T Function(A) convert) {
  return switch (state) {
    Success<A>(:final response) => Success<T>(convert(response)),
    Error(:final errMsg, :final code) => Error(errMsg, code: code),
    Loading() => LoadingState<T>.loading(),
  };
}

// ── SearchType conversion ──────────────────────────────────────────────

SearchType _toSearchType(CoreSearchType type) {
  return switch (type) {
    CoreSearchType.video => SearchType.video,
    CoreSearchType.media_bangumi => SearchType.media_bangumi,
    CoreSearchType.media_ft => SearchType.media_ft,
    CoreSearchType.live_room => SearchType.live_room,
    CoreSearchType.bili_user => SearchType.bili_user,
    CoreSearchType.article => SearchType.article,
  };
}

// ── Model conversion helpers ───────────────────────────────────────────

CoreSearchSuggestModel _convertSuggestModel(SearchSuggestModel model) {
  return CoreSearchSuggestModel(
    tag: model.tag
        ?.map((item) => CoreSearchSuggestItem(
              term: item.term,
              textRich: item.textRich,
            ))
        .toList(),
  );
}

CoreSearchAllData _convertSearchAllData(SearchAllData data) {
  return CoreSearchAllData(numResults: data.numResults);
}

CorePgcInfoModel _convertPgcInfoModel(PgcInfoModel model) {
  return CorePgcInfoModel(
    actors: model.actors,
    cover: model.cover,
    evaluate: model.evaluate,
    mediaId: model.mediaId,
    seasonId: model.seasonId,
    seasonTitle: model.seasonTitle,
    subtitle: model.subtitle,
    title: model.title,
    type: model.type,
  );
}

CoreSearchTrendingData _convertSearchTrendingData(SearchTrendingData data) {
  return CoreSearchTrendingData(
    list: data.list
        ?.map((item) => CoreSearchTrendingItemModel(
              keyword: item.keyword,
              icon: item.icon,
              showLiveIcon: item.showLiveIcon,
              recommendReason: item.recommendReason,
            ))
        .toList(),
  );
}

CoreSearchRcmdData _convertSearchRcmdData(SearchRcmdData data) {
  return CoreSearchRcmdData(
    list: data.list
        ?.map((item) => CoreSearchTrendingItemModel(
              keyword: item.keyword,
              icon: item.icon,
              showLiveIcon: item.showLiveIcon,
              recommendReason: item.recommendReason,
            ))
        .toList(),
  );
}

CoreTopicPubSearchData _convertTopicPubSearchData(TopicPubSearchData data) {
  return CoreTopicPubSearchData(
    topicItems: data.topicItems
        ?.map((item) => CoreTopicItem(
              id: item.id,
              name: item.name,
              view: item.view,
              discuss: item.discuss,
              fav: item.fav,
              like: item.like,
              description: item.description,
              isFav: item.isFav,
              isLike: item.isLike,
            ))
        .toList(),
    pageInfo: data.pageInfo != null
        ? CorePageInfo(hasMore: data.pageInfo!.hasMore)
        : null,
  );
}

CoreDimension _convertDimension(Dimension dimension) {
  return CoreDimension(width: dimension.width, height: dimension.height);
}