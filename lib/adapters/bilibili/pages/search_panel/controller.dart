import 'dart:async' show StreamSubscription;

import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/models/common/search/article_search_type.dart';
import 'package:skf/adapters/bilibili/models/common/search/user_search_type.dart';
import 'package:skf/adapters/bilibili/models/common/search/video_search_type.dart';
import 'package:skf/adapters/bilibili/models/search/result.dart';
import 'package:skf/adapters/bilibili/repository/bili_search_repository.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/pages/search_result/controller.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class SearchPanelController<R extends SearchNumData<T>, T>
    extends CommonListControllerRiverpod<R, T> {
  SearchPanelController({
    required this.keyword,
    required this.searchType,
    required this.tag,
  }) {
    try {
      searchResultController = Get.find<SearchResultController>(tag: tag);
      _listener = searchResultController!.toTopIndex.listen((index) {
        if (index == searchType.index) {
          scrollController.animToTop();
        }
      });
    } catch (_) {}
    queryData();
  }
  final String tag;
  final String keyword;
  final CoreSearchType searchType;

  // sort
  // common
  String order = '';

  // video
  VideoDurationType? videoDurationType; // int duration
  VideoZoneType? videoZoneType; // int? tids;
  int? pubBegin;
  int? pubEnd;

  // user
  UserOrderType? userOrderType;
  UserType? userType;

  // article
  ArticleZoneType? articleZoneType; // int? categoryId;

  SearchResultController? searchResultController;

  void onSortSearch({
    bool getBack = true,
    String? label,
  }) {
    if (getBack) Get.back();
    SmartDialog.dismiss();
    if (label != null) {
      SmartDialog.showToast("「」的筛选结果");
    }
    SmartDialog.showLoading(msg: 'loading');
    onReload().whenComplete(SmartDialog.dismiss);
  }

  StreamSubscription? _listener;

  void cancelListener() {
    _listener?.cancel();
  }


  @override
  List<T>? getDataList(R response) {
    return response.list;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<R> response) {
    if (isRefresh) {
      searchResultController?.updateCount(
        searchType.index,
        response.response.numResults ?? 0,
      );
    }
    return false;
  }

  String? gaiaVtoken;

  @override
  Future<LoadingState<R>> customGetData() async {
    final result = await Get.find<BiliSearchRepository>().searchByType<R>(
      searchType: searchType,
      keyword: keyword,
      page: page,
      order: order,
      duration: videoDurationType?.index,
      tids: videoZoneType?.tids,
      orderSort: userOrderType?.orderSort,
      userType: userType?.index,
      categoryId: articleZoneType?.categoryId,
      pubBegin: pubBegin,
      pubEnd: pubEnd,
      gaiaVtoken: gaiaVtoken,
      onSuccess: (String gaiaVtoken) {
        this.gaiaVtoken = gaiaVtoken;
        queryData(page == 1);
      },
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  Future<void> onReload() {
    scrollController.jumpToTop();
    return super.onReload();
  }
}
