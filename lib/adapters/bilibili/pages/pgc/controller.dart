import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/repository/pgc_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/models/common/home_tab_type.dart';
import 'package:skf/core/models/pgc_types.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:skf/core/account/account_mixin.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter/widgets.dart' show ScrollController;

class PgcController
    extends CommonListController<List<CorePgcIndexItem>?, CorePgcIndexItem>
    with AccountMixin {
  PgcController({required this.tabType})
    : indexType = tabType == HomeTabType.cinema ? 102 : null;

  final HomeTabType tabType;
  final int? indexType;

  late final showPgcTimeline =
      tabType == HomeTabType.bangumi && Pref.showPgcTimeline;

  @override
  void onInit() {
    super.onInit();

    queryData();
    queryPgcFollow();
    if (showPgcTimeline) {
      queryPgcTimeline();
    }
  }

  @override
  Future<void> onRefresh() {
    if (accountService.isLogin) {
      _refreshPgcFollow();
    }
    if (showPgcTimeline) {
      queryPgcTimeline();
    }
    return super.onRefresh();
  }

  void _refreshPgcFollow() {
    followPage = 1;
    followEnd = false;
    queryPgcFollow();
  }

  // follow
  late int followPage = 1;
  late RxInt followCount = (-1).obs;
  late bool followLoading = false;
  late bool followEnd = false;
  late Rx<LoadingState<List<CoreFavPgcItemModel>?>> followState =
      LoadingState<List<CoreFavPgcItemModel>?>.loading().obs;
  final followController = ScrollController();

  // timeline
  late Rx<LoadingState<List<CoreTimelineResult>?>> timelineState =
      LoadingState<List<CoreTimelineResult>?>.loading().obs;

  Future<void> queryPgcTimeline() async {
    final res = await Future.wait([
Get.find<PgcRepository>().pgcTimeline(types: 1, before: 6, after: 6),
   Get.find<PgcRepository>().pgcTimeline(types: 4, before: 6, after: 6),
    ]);
    final list1 = res.first.dataOrNull;
    final list2 = res[1].dataOrNull;
    if (list1 != null &&
        list2 != null &&
        list1.isNotEmpty &&
        list2.isNotEmpty) {
      for (var i = 0; i < list1.length; i++) {
        list1[i].addAll(list2[i]);
      }
    }
    timelineState.value = Success(list1 ?? list2);
  }

  // 我的订阅
  Future<void> queryPgcFollow([bool isRefresh = true]) async {
    if (!accountService.isLogin ||
        followLoading ||
        (!isRefresh && followEnd)) {
      return;
    }
    followLoading = true;
    final res = await Get.find<FavRepository>().favPgc(
      type: tabType == HomeTabType.bangumi ? 1 : 2,
      pn: followPage,
    );

    if (res case Success(:final response)) {
      final list = response.list;
      followCount.value = response.total ?? -1;

      if (list == null || list.isEmpty) {
        followEnd = true;
        if (isRefresh) {
          followState.value = Success(list);
        }
        followLoading = false;
        return;
      }

      if (isRefresh) {
        if (list.length >= followCount.value) {
          followEnd = true;
        }
        followState.value = Success(list);
        followController.jumpToTop();
      } else if (followState.value case Success(:final response)) {
        final currentList = response!..addAll(list);
        if (currentList.length >= followCount.value) {
          followEnd = true;
        }
        followState.refresh();
      }
      followPage++;
    } else if (isRefresh) {
      followState.value = switch (res) {
        Error(:final errMsg, :final code) => Error(errMsg, code: code),
        _ => LoadingState.loading(),
      };
    }
    followLoading = false;
  }

  @override
  Future<LoadingState<List<CorePgcIndexItem>?>> customGetData() async {
    final result = await Get.find<PgcRepository>().pgcIndex(
      page: page,
      indexType: indexType,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void onClose() {
    followController.dispose();
    super.onClose();
  }

  @override
  void onChangeAccount(bool isLogin) {
    if (isLogin) {
      _refreshPgcFollow();
    } else {
      followState.value = LoadingState.loading();
    }
  }
}
