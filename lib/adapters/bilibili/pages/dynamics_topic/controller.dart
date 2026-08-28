import 'package:skf/core/repository/repository_providers.dart';

import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:skf/core/container/app_container.dart';

class DynTopicController
    extends CommonListControllerRiverpod<CoreTopicCardList?, CoreTopicCardItem> {
  final topicId = Get.parameters['id']!;
  String topicName = Get.parameters['name'] ?? '';

  int sortBy = 0;
  String? offset;
  CoreTopicSortByConf? topicSortByConf;

  double? appbarOffset;

  // top
  bool isFav = false;
  bool isLike = false;
  LoadingState<CoreTopDetails?> topState =
      LoadingState<CoreTopDetails?>.loading();

  late final isLogin = Accounts.main.isLogin;

  DynTopicController() {
    queryTop();
    queryData();
  }

  Future<void> queryTop() async {
    final result = await (appRead(dynamicsRepositoryProvider)).topicTop(topicId: topicId);
    topState = switch (result) {
      Loading _ => LoadingState<CoreTopDetails?>.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
    if (topState case Success(:final response)) {
      final topicItem = response!.topicItem!;
      topicName = topicItem.name;
      isFav = topicItem.isFav ?? false;
      isLike = topicItem.isLike ?? false;
    }
  }

  @override
  List<CoreTopicCardItem>? getDataList(CoreTopicCardList? response) {
    if (response != null) {
      offset = response.offset;
      topicSortByConf = response.topicSortByConf;
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
    final result = await (appRead(dynamicsRepositoryProvider)).topicFeed(
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
    final isFav = this.isFav;
    final res = isFav
        ? await (appRead(favRepositoryProvider)).delFavTopic(topicId)
        : await (appRead(favRepositoryProvider)).addFavTopic(topicId);
    if (res.isSuccess) {
      if (isFav) {
        topState.data!.topicItem!.fav -= 1;
      } else {
        topState.data!.topicItem!.fav += 1;
      }
      this.isFav = !this.isFav;
      notifyListeners();
    } else {
      res.toast();
    }
  }

  Future<void> onLike() async {
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final isLike = this.isLike;
    final res = await (appRead(favRepositoryProvider)).likeTopic(topicId, isLike);
    if (res.isSuccess) {
      if (isLike) {
        topState.data!.topicItem!.like -= 1;
      } else {
        topState.data!.topicItem!.like += 1;
      }
      this.isLike = !this.isLike;
      notifyListeners();
    } else {
      res.toast();
    }
  }

  Future<void> topicFold() async {
    final result = await (appRead(dynamicsRepositoryProvider)).topicFold(topicId: topicId, sortBy: sortBy);
    if (result case Success(:final response)) {
      if (response?.items case final items? when items.isNotEmpty) {
        loadingState.data!
          ..removeLast()
          ..addAll(items);
        notifyListeners();
      }
    }
  }
}