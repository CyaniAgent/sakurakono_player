import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';

import 'package:skf/common/widgets/pair.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter/widgets.dart' show ScrollController;

class LiveController extends CommonListControllerRiverpod {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  LiveController() { queryData(); }

  int? count;

  // area
  int? areaId;
  String? sortType;
  int? parentAreaId;
  int areaIndex = 0;

  // tag
  int tagIndex = 0;
  List<CoreLiveSecondTag>? newTags;

  Pair<CoreLiveCardList?, CoreLiveCardList?> topState =
      Pair<CoreLiveCardList?, CoreLiveCardList?>(first: null, second: null);

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
        topState = Pair(
          first: res.followItem,
          second: res.areaItem,
        );
      } else if (res is CoreLiveSecondData) {
        count = res.count;
        newTags = res.newTags;
        if (sortType != null) {
        tagIndex =
            newTags?.indexWhere((e) => e.sortType == sortType) ?? -1;
        }
      }
    }
    return false;
  }

  @override
  Future<LoadingState> customGetData() async {
    final LoadingState biliResult;
    if (areaIndex != 0) {
      biliResult = await (_ref!.read(liveRepositoryProvider)).liveSecondList(
        pn: page,
        areaId: areaId,
        parentAreaId: parentAreaId,
        sortType: sortType,
      );
    } else {
      biliResult = await (_ref!.read(liveRepositoryProvider)).liveFeedIndex(pn: page);
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
    if (areaIndex != 0) {
      queryTop().whenComplete(followController.jumpToTop);
      return queryData();
    }
    return queryData().whenComplete(followController.jumpToTop);
  }

  Future<void> queryTop() async {
    final biliResult = await (_ref!.read(liveRepositoryProvider)).liveFeedIndex(pn: page, moduleSelect: true);
    final res = switch (biliResult) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
    if (res case Success(:final response)) {
      topState = Pair(
        first: response.followItem,
        second: response.areaItem,
      );
      areaIndex =
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
    if (index == areaIndex) {
      return;
    }
    tagIndex = 0;
    newTags = null;
    sortType = null;
    areaIndex = index;
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
    tagIndex = index;
    this.sortType = sortType;

    count = null;
    page = 1;
    isEnd = false;
    queryData();
  }

  void onChangeAccount(bool isLogin) => onReload();

  @override
  void dispose() {
    followController.dispose();
    super.dispose();
  }
}

/// Live page controller (single instance).
final liveControllerProvider = Provider<LiveController>((ref) => LiveController());
