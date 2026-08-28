import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/adapters/bilibili/models/search/result.dart';
import 'package:skf/adapters/bilibili/pages/search_panel/controller.dart';
import 'package:skf/adapters/bilibili/utils/app_scheme.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:skf/core/container/app_container.dart';

class SearchAllController
    extends SearchPanelController<SearchAllData, dynamic> {
  SearchAllController({
    required super.keyword,
    required super.searchType,
    required super.tag,
  }) {
    jump2Video();
  }

  late bool hasJump2Video = false;


  @override
  List? getDataList(response) {
    return response.list;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success response) {
    searchResultController?.count[searchType.index] =
        response.response.numResults ?? 0;
    if (searchType == CoreSearchType.video && !hasJump2Video && isRefresh) {
      hasJump2Video = true;
      onPushDetail(response.response.list);
    }
    return false;
  }

  @override
  Future<LoadingState<SearchAllData>> customGetData() async {
    // searchAll returns CoreSearchAllData, but the controller still uses
    // the adapter type SearchAllData. Both share the same shape (numResults, list),
    // making the cast safe.
    final result = await (appRead(searchRepositoryProvider)).searchAll(
      keyword: keyword,
      page: page,
      order: order,
      duration: null,
      tids: videoZoneType?.tids,
      orderSort: userOrderType?.orderSort,
      userType: userType?.index,
      categoryId: articleZoneType?.categoryId,
      pubBegin: pubBegin,
      pubEnd: pubEnd,
    ) as LoadingState<SearchAllData>;
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  void onPushDetail(dynamic resultList) {
    try {
      int? aid = int.tryParse(keyword);
      if (aid != null && resultList.first.aid == aid) {
        PiliScheme.videoPush(aid, null, showDialog: false);
      }
    } catch (_) {}
  }

  void jump2Video() {
    if (IdUtils.avRegexExact.hasMatch(keyword)) {
      hasJump2Video = true;
      PiliScheme.videoPush(
        int.parse(keyword.substring(2)),
        null,
        showDialog: false,
      );
    } else if (IdUtils.bvRegexExact.hasMatch(keyword)) {
      hasJump2Video = true;
      PiliScheme.videoPush(null, keyword, showDialog: false);
    }
  }
}
