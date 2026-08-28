import 'package:skf/common/widgets/dialog/dialog.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/pages/common/multi_select/multi_select_controller.dart';
import 'package:skf/pages/history/base_controller.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

class HistoryController
    extends MultiSelectController<CoreHistoryData, CoreHistoryItemModel>
    implements TickerProvider {
  HistoryController(this.type) {
    historyStatus();
    queryData();
  }

  Object? get account => null;

  final String? type;
  TabController? tabController;
  List<CoreHistoryTab> _tabs = [];
  List<CoreHistoryTab> get tabs => _tabs;
  set tabs(List<CoreHistoryTab> v) { _tabs = v; notifyListeners(); }

  int? max;
  int? viewAt;

  WidgetRef? _ref;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(WidgetRef ref) { _ref = ref; }

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);

  @override
  Future<void> onRefresh() {
    max = null;
    viewAt = null;
    return super.onRefresh();
  }

  @override
  List<CoreHistoryItemModel>? getDataList(CoreHistoryData response) {
    return response.list;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<CoreHistoryData> response) {
    CoreHistoryData data = response.response;
    isEnd = data.list.isNullOrEmpty;
    max = data.list?.lastOrNull?.history.oid;
    viewAt = data.list?.lastOrNull?.viewAt;

    if (isRefresh && type == null) {
      if (tabs.isEmpty && data.tab?.isNotEmpty == true) {
        tabs = data.tab!;
        tabController = TabController(
          length: data.tab!.length + 1,
          vsync: this,
        );
      }
    }

    return false;
  }

  // 观看历史暂停状态
  Future<void> historyStatus() async {
    final res = await (_ref!.read(userRepositoryProvider)).historyStatus(account: account);
    if (res case Success(:final response)) {
      _ref?.read(historyBaseProvider.notifier).setPauseStatus(response);
      GStorage.localCache.put(LocalCacheKey.historyPause, response);
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  // 删除某条历史记录
  void delHistory(CoreHistoryItemModel item) {
    _onDelete({item});
  }

  // 删除已看历史记录
  void onDelViewedHistory() {
    final viewedList = loadingState.dataOrNull
        ?.where((e) => e.progress == -1)
        .toSet();
    if (viewedList != null && viewedList.isNotEmpty) {
      _onDelete(viewedList);
    } else {
      SmartDialog.showToast('无已看记录');
    }
  }

  Future<void> _onDelete(Set<CoreHistoryItemModel> removeList) async {
    SmartDialog.showLoading(msg: '请求中');
    final res = await (_ref!.read(userRepositoryProvider)).delHistory(
      removeList
          .map((item) => '${item.history.business}_${item.kid}')
          .join(','),
      account: account,
    );
    SmartDialog.dismiss();
    if (res.isSuccess) {
      afterDelete(removeList);
      SmartDialog.showToast('已删除');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  // 删除选中的记录
  @override
  void onRemove() {
    showConfirmDialog(
      context: AppNavigator.context!,
      title: const Text('提示'),
      content: const Text('确认删除所选历史记录吗？'),
      onConfirm: () => _onDelete(allChecked.toSet()),
    );
  }

  @override
  Future<LoadingState<CoreHistoryData>> customGetData() async {
    final result = await (_ref!.read(userRepositoryProvider)).historyList(
    type: type ?? 'all',
    max: max,
    viewAt: viewAt,
    account: account,
  );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Future<void> onReload() {
    scrollController.jumpToTop();
    return super.onReload();
  }
}

/// 每实例注册表 — 历史页 view 创建后登记，按 type（null -> 'all'）经
/// [historyControllerProvider] 读取（替代 GetX tag 注册）。
final Map<String, HistoryController> historyControllerRegistry = {};

final historyControllerProvider = Provider.family<HistoryController, String>(
  (ref, key) => historyControllerRegistry[key] ??
      (throw StateError('HistoryController not registered for key: $key')),
);
