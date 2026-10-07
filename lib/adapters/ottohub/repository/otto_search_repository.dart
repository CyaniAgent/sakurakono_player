import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [SearchRepository] that delegates to [IVideoApi.search].
///
/// **searchAll** — implemented via `_client.video.search()` (maps to
/// `/video/search`). Supports keyword, pagination, and uid filtering.
/// **ab2c / ab2cWithDimension** — identity mapping: in OttoHub, bvid/aid/cid
/// are all the same numeric value (`vid` as string → `int`). Returns the
/// parsed integer or `null` if unparseable.
/// All other methods (suggestions, trending, recommendations, PGC/PUGV info,
/// topic search) are stubbed because the OttoHub SDK has no equivalent API.
class OttoSearchRepository implements SearchRepository {
  final OttohubClient _client;

  OttoSearchRepository(this._client);

  IVideoApi get _api => _client.video;

  LoadingState<T> _ok<T>(T value) => Success(value);

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  // ---------------------------------------------------------------------------
  // searchAll — the primary search path
  // ---------------------------------------------------------------------------

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
    try {
      final result = await _api.search(
        searchTerm: keyword,
        offset: (page - 1) * 30,
        num: 30,
      );
      // 键名对齐 CoreHotVideoItemModel.fromJson(嵌套 owner/stat)。
      return _ok(CoreSearchAllData(
        numResults: result.totalCount,
        list: result.videoList.map((v) => <String, dynamic>{
          'title': v.title,
          'desc': v.intro ?? '',
          'cover': v.coverUrl,
          'bvid': v.vid.toString(),
          'aid': v.vid,
          'cid': v.vid,
          'duration': v.duration,
          // pubdate 为秒级时间戳(int);v.time 是日期字符串需转换。
          'pubdate':
              (DateTime.tryParse(v.time)?.millisecondsSinceEpoch ?? 0) ~/ 1000,
          'owner': {'mid': v.uid, 'name': v.username},
          'stat': {
            'view': v.viewCount,
            'like': v.likeCount,
            'favorite': v.favoriteCount,
          },
        }).toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoSearchRepository.searchAll ApiException: ${e.errorCode}');
      return _err(e);
    } on TypeError catch (e) {
      debugPrint('OttoSearchRepository TypeError: $e');
      return const Error('data_format_error');
    }
  }

  // ---------------------------------------------------------------------------
  // ab2c / ab2cWithDimension — identity mapping for OttoHub's flat-ID model
  // ---------------------------------------------------------------------------

  @override
  Future<int?> ab2c({int? aid, String? bvid, int? part}) async {
    final id = aid ?? int.tryParse(bvid ?? '');
    return id;
  }

  @override
  Future<({int? cid, CoreDimension? dimension})?> ab2cWithDimension({
    int? aid,
    String? bvid,
    int? part,
  }) async {
    final id = aid ?? int.tryParse(bvid ?? '');
    return (cid: id, dimension: null);
  }

  // ---------------------------------------------------------------------------
  // Stubs — OttoHub SDK has no equivalent APIs
  // ---------------------------------------------------------------------------

  @override
  // OttoHub 无搜索联想 API:返回空数据让联想区优雅隐藏(而非报错)。
  Future<LoadingState<CoreSearchSuggestModel>> searchSuggest({
    required String term,
  }) async =>
      _ok(CoreSearchSuggestModel());

  @override
  Future<LoadingState<CorePgcInfoModel>> pgcInfo({
    Object? seasonId,
    Object? epId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CorePgcInfoModel>> pugvInfo({
    Object? seasonId,
    Object? epId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  // OttoHub 无热搜 API:返回空数据让热搜区优雅隐藏。
  Future<LoadingState<CoreSearchTrendingData>> searchTrending({
    int limit = 30,
    bool needsTop = false,
  }) async =>
      _ok(CoreSearchTrendingData());

  @override
  // OttoHub 无搜索发现 API:返回空数据让发现区优雅隐藏。
  Future<LoadingState<CoreSearchRcmdData>> searchRecommend() async =>
      _ok(CoreSearchRcmdData());

  @override
  Future<LoadingState<CoreTopicPubSearchData>> topicPubSearch({
    required String keywords,
    String content = '',
    required int pageNum,
  }) async =>
      _err(const ApiException('not_implemented'));
}