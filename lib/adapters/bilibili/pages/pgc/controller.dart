import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/adapters/bilibili/models/common/home_tab_type.dart';
import 'package:skf/core/models/pgc_types.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter/widgets.dart' show ScrollController;

class PgcController
    extends CommonListControllerRiverpod<List<CorePgcIndexItem>?, CorePgcIndexItem> {
  void attachRef(ProviderContainer ref) {}
  final HomeTabType tabType;
  final int? indexType;
  late final showPgcTimeline =
      tabType == HomeTabType.bangumi && Pref.showPgcTimeline;

  AccountNotifier get accountService => appRead(accountProvider.notifier);

  PgcController({required this.tabType}) : indexType = tabType == HomeTabType.cinema ? 102 : null {
    accountService.onAuthStateChanged();
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
  int _followCount = -1; int get followCount => _followCount; set followCount(int v) { _followCount = v; notifyListeners(); }
  late bool followLoading = false;
  late bool followEnd = false;
  LoadingState<List<CoreFavPgcItemModel>?> _followState = LoadingState<List<CoreFavPgcItemModel>?>.loading();
  LoadingState<List<CoreFavPgcItemModel>?> get followState => _followState;
  set followState(LoadingState<List<CoreFavPgcItemModel>?> v) { _followState = v; notifyListeners(); }
  final followController = ScrollController();

  // timeline
  LoadingState<List<CoreTimelineResult>?> _timelineState = LoadingState<List<CoreTimelineResult>?>.loading();
  LoadingState<List<CoreTimelineResult>?> get timelineState => _timelineState;
  set timelineState(LoadingState<List<CoreTimelineResult>?> v) { _timelineState = v; notifyListeners(); }

  Future<void> queryPgcTimeline() async {
    final res = await Future.wait([
(appRead(pgcRepositoryProvider)).pgcTimeline(types: 1, before: 6, after: 6),
  (appRead(pgcRepositoryProvider)).pgcTimeline(types: 4, before: 6, after: 6),
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
    timelineState = Success(list1 ?? list2);
  }

  // 我的订阅
  Future<void> queryPgcFollow([bool isRefresh = true]) async {
    if (!accountService.isLogin ||
        followLoading ||
        (!isRefresh && followEnd)) {
      return;
    }
    followLoading = true;
    final res = await (appRead(favRepositoryProvider)).favPgc(
      type: tabType == HomeTabType.bangumi ? 1 : 2,
      pn: followPage,
    );

    if (res case Success(:final response)) {
      final list = response.list;
      followCount = response.total ?? -1;

      if (list == null || list.isEmpty) {
        followEnd = true;
        if (isRefresh) {
          followState = Success(list);
        }
        followLoading = false;
        return;
      }

      if (isRefresh) {
        if (list.length >= followCount) {
          followEnd = true;
        }
        followState = Success(list);
        followController.jumpToTop();
      } else if (followState case Success(:final response)) {
        final currentList = response!..addAll(list);
        if (currentList.length >= followCount) {
          followEnd = true;
        }
        notifyListeners();
      }
      followPage++;
    } else if (isRefresh) {
      followState = switch (res) {
        Error(:final errMsg, :final code) => Error(errMsg, code: code),
        _ => LoadingState.loading(),
      };
    }
    followLoading = false;
  }

  @override
  Future<LoadingState<List<CorePgcIndexItem>?>> customGetData() async {
    final result = await (appRead(pgcRepositoryProvider)).pgcIndex(
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
  void dispose() {
    followController.dispose();
    super.dispose();
  }

  void onChangeAccount(bool isLogin) {
    if (isLogin) {
      _refreshPgcFollow();
    } else {
      followState = LoadingState.loading();
    }
  }
}

/// 每实例注册表 — pgc 页 view 创建后登记，按 tab 名（tabType.name）经
/// [pgcControllerProvider] 读取（替代 GetX tag 注册）。
final Map<String, PgcController> pgcControllerRegistry = {};

final pgcControllerProvider = Provider.family<PgcController, String>(
  (ref, key) => pgcControllerRegistry[key] ??
      (throw StateError('PgcController not registered for key: $key')),
);
