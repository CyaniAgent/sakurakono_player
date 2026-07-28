import 'package:skf/common/widgets/pair.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:skf/adapters/bilibili/services/account_service.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter/widgets.dart' show ScrollController;
import 'package:get/get.dart';

class LiveController extends CommonListController with AccountMixin {
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  int? count;

  // area
  int? areaId;
  String? sortType;
  int? parentAreaId;
  final RxInt areaIndex = 0.obs;

  // tag
  final RxInt tagIndex = 0.obs;
  List<CoreLiveSecondTag>? newTags;

  final Rx<Pair<CoreLiveCardList?, CoreLiveCardList?>> topState =
      Pair<CoreLiveCardList?, CoreLiveCardList?>(first: null, second: null).obs;

  final followController = ScrollController();

  bool showFirstFrame = false;

  @override
  void checkIsEnd(int length) {
    if (count != null && length >= count!) {
      isEnd = true;
    }
  }

  @override
  List? getDataList(response) {
    return response.cardList;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success response) {
    if (isRefresh) {
      final res = response.response;
      if (res is CoreLiveIndexData) {
        if (res.hasMore == 0) {
          isEnd = true;
        }
        topState.value = Pair(
          first: res.followItem,
          second: res.areaItem,
        );
      } else if (res is CoreLiveSecondData) {
        count = res.count;
        newTags = res.newTags;
        if (sortType != null) {
          tagIndex.value =
              newTags?.indexWhere((e) => e.sortType == sortType) ?? -1;
        }
      }
    }
    return false;
  }

  @override
  Future<LoadingState> customGetData() async {
    final LoadingState biliResult;
    if (areaIndex.value != 0) {
      biliResult = await Get.find<LiveRepository>().liveSecondList(
        pn: page,
        areaId: areaId,
        parentAreaId: parentAreaId,
        sortType: sortType,
      );
    } else {
      biliResult = await Get.find<LiveRepository>().liveFeedIndex(pn: page);
    }
    return switch (biliResult) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  Future<void> onRefresh() {
    count = null;
    page = 1;
    isEnd = false;
    if (areaIndex.value != 0) {
      queryTop().whenComplete(followController.jumpToTop);
      return queryData();
    }
    return queryData().whenComplete(followController.jumpToTop);
  }

  Future<void> queryTop() async {
    final biliResult = await Get.find<LiveRepository>().liveFeedIndex(pn: page, moduleSelect: true);
    final res = switch (biliResult) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
    if (res case Success(:final response)) {
      topState.value = Pair(
        first: response.followItem,
        second: response.areaItem,
      );
      areaIndex.value =
          (response.areaItem?.cardData?.areaEntranceV3?.list?.indexWhere(
                (e) => e.areaV2Id == areaId && e.areaV2ParentId == parentAreaId,
              ) ??
              -2) +
          1;
    }
  }

  void onSelectArea(int index, CoreCardLiveItem? cardLiveItem) {
    if (isLoading) {
      return; // areaIndex conflict
    }
    if (index == areaIndex.value) {
      return;
    }
    tagIndex.value = 0;
    newTags = null;
    sortType = null;
    areaIndex.value = index;
    areaId = cardLiveItem?.areaV2Id;
    parentAreaId = cardLiveItem?.areaV2ParentId;

    count = null;
    page = 1;
    isEnd = false;
    queryData();
  }

  void onSelectTag(int index, String? sortType) {
    if (isLoading) {
      return;
    }
    tagIndex.value = index;
    this.sortType = sortType;

    count = null;
    page = 1;
    isEnd = false;
    queryData();
  }

  @override
  void onChangeAccount(bool isLogin) => onReload();

  @override
  void onClose() {
    followController.dispose();
    super.onClose();
  }
}
