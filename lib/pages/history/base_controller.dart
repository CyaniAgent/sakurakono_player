import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

class HistoryBaseState {
  const HistoryBaseState({
    this.pauseStatus = false,
    this.enableMultiSelect = false,
    this.checkedCount = 0,
  });

  final bool pauseStatus;
  final bool enableMultiSelect;
  final int checkedCount;

  HistoryBaseState copyWith({
    bool? pauseStatus,
    bool? enableMultiSelect,
    int? checkedCount,
  }) {
    return HistoryBaseState(
      pauseStatus: pauseStatus ?? this.pauseStatus,
      enableMultiSelect: enableMultiSelect ?? this.enableMultiSelect,
      checkedCount: checkedCount ?? this.checkedCount,
    );
  }
}

class HistoryBaseNotifier extends StateNotifier<HistoryBaseState> {
  HistoryBaseNotifier(this._ref) : super(const HistoryBaseState());

  final Ref _ref;

  // 历史接口的 account 参数：core 仓库接受 Object?；B站 http 层在 account 为 null
  // 时内部回退到 Accounts.history（心跳/主账号），因此通用页面直接传 null。
  final Object? account = null;

  void setPauseStatus(bool value) {
    state = state.copyWith(pauseStatus: value);
  }

  void setEnableMultiSelect(bool value) {
    state = state.copyWith(enableMultiSelect: value);
  }

  void setCheckedCount(int value) {
    state = state.copyWith(checkedCount: value);
  }

  // 清空观看历史
  void onClearHistory(BuildContext context, VoidCallback onSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('啊叻？你要清空历史记录功能吗？'),
        actions: [
          TextButton(
            onPressed: AppNavigator.back,
            child: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              AppNavigator.back();
              SmartDialog.showLoading(msg: '请求中');
              final res = await _ref.read(userRepositoryProvider).clearHistory(
                account: account,
              );
              SmartDialog.dismiss();
              if (res.isSuccess) {
                SmartDialog.showToast('清空观看历史');
                onSuccess();
              } else {
                res.toast();
              }
            },
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
  }

  // 暂停观看历史
  void onPauseHistory(BuildContext context) {
    final pauseStatus = !state.pauseStatus;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(
          pauseStatus ? '啊叻？你要暂停历史记录功能吗？' : '啊叻？要恢复历史记录功能吗？',
        ),
        actions: [
          TextButton(
            onPressed: AppNavigator.back,
            child: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              SmartDialog.showLoading(msg: '请求中');
              final res = await _ref.read(userRepositoryProvider).pauseHistory(
                pauseStatus,
                account: account,
              );
              SmartDialog.dismiss();
              if (res.isSuccess) {
                SmartDialog.showToast(
                  pauseStatus ? '暂停观看历史' : '恢复观看历史',
                );
                state = state.copyWith(pauseStatus: pauseStatus);
                GStorage.localCache.put(
                  LocalCacheKey.historyPause,
                  pauseStatus,
                );
              } else {
                res.toast();
              }
              AppNavigator.back();
            },
            child: Text(pauseStatus ? '确认暂停' : '确认恢复'),
          ),
        ],
      ),
    );
  }
}

final historyBaseProvider =
    StateNotifierProvider<HistoryBaseNotifier, HistoryBaseState>((ref) {
      return HistoryBaseNotifier(ref);
    });
