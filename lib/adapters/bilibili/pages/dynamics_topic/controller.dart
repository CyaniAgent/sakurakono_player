import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class DynTopicController
    extends CommonListController<CoreTopicCardList?, CoreTopicCardItem> {
  final topicId = Get.parameters['id']!;
  String topicName = Get.parameters['name'] ?? '';

  int sortBy = 0;
  String? offset;
  final topicSortByConf = Rxn<CoreTopicSortByConf>();

  double? appbarOffset;

  // top
  final isFav = false.obs;
  final isLike = false.obs;
  Rx<LoadingState<CoreTopDetails?>> topState =
      LoadingState<CoreTopDetails?>.loading().obs;

  late final isLogin = Accounts.main.isLogin;

  @override
  void onInit() {
    super.onInit();
    queryTop();
    queryData();
  }

  Future<void> queryTop() async {
    final result = await Get.find<DynamicsRepository>().topicTop(topicId: topicId);
    topState.value = switch (result) {
      Loading _ => LoadingState<CoreTopDetails?>.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
    if (topState.value case Success(:final response)) {
      final topicItem = response!.topicItem!;
      topicName = topicItem.name;
      isFav.value = topicItem.isFav ?? false;
      isLike.value = topicItem.isLike ?? false;
    }
  }

  @override
  List<CoreTopicCardItem>? getDataList(CoreTopicCardList? response) {
    if (response != null) {
      offset = response.offset;
      topicSortByConf.value = response.topicSortByConf;
      sortBy = response.topicSortByConf?.showSortBy ?? 0;
      if (response.hasMore == false) {
        isEnd = true;
      }
      return response.items;
    }
    return null;
  }

  @override
  Future<void> onRefresh() {
    offset = '';
    queryTop();
    return super.onRefresh();
  }

  @override
  Future<void> onReload() {
    if (appbarOffset != null) {
      if (scrollController.hasClients &&
          scrollController.offset > appbarOffset!) {
        scrollController.jumpTo(appbarOffset!);
      }
    } else {
      scrollController.jumpToTop();
    }
    return super.onReload();
  }

  @override
  Future<LoadingState<CoreTopicCardList?>> customGetData() async {
    final result = await Get.find<DynamicsRepository>().topicFeed(
      topicId: topicId,
      offset: offset,
      sortBy: sortBy,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  void onSort(int sortBy) {
    this.sortBy = sortBy;
    onReload();
  }

  Future<void> onFav() async {
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final isFav = this.isFav.value;
    final res = isFav
        ? await Get.find<FavRepository>().delFavTopic(topicId)
        : await Get.find<FavRepository>().addFavTopic(topicId);
    if (res.isSuccess) {
      if (isFav) {
        topState.value.data!.topicItem!.fav -= 1;
      } else {
        topState.value.data!.topicItem!.fav += 1;
      }
      this.isFav.toggle();
    } else {
      res.toast();
    }
  }

  Future<void> onLike() async {
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final isLike = this.isLike.value;
    final res = await Get.find<FavRepository>().likeTopic(topicId, isLike);
    if (res.isSuccess) {
      if (isLike) {
        topState.value.data!.topicItem!.like -= 1;
      } else {
        topState.value.data!.topicItem!.like += 1;
      }
      this.isLike.toggle();
    } else {
      res.toast();
    }
  }

  Future<void> topicFold() async {
    final result = await Get.find<DynamicsRepository>().topicFold(topicId: topicId, sortBy: sortBy);
    if (result case Success(:final response)) {
      if (response?.items case final items? when items.isNotEmpty) {
        loadingState.value.data!
          ..removeLast()
          ..addAll(items);
        loadingState.refresh();
      }
    }
  }
}