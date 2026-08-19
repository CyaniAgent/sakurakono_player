import 'dart:convert';

import 'package:archive/archive.dart' show getCrc32;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/adapters/bilibili/models/common/dm_block_type.dart';
import 'package:skf/core/models/danmaku_block.dart';
import 'package:skf/core/repository/danmaku_filter_repository.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';

/// Immutable state for the danmaku block page.
class DanmakuBlockState {
  final List<List<CoreSimpleRule>> rules;

  const DanmakuBlockState({required this.rules});

  factory DanmakuBlockState.initial() => DanmakuBlockState(
        rules: List.generate(DmBlockType.values.length, (_) => []),
      );

  DanmakuBlockState copyWith({List<List<CoreSimpleRule>>? rules}) =>
      DanmakuBlockState(rules: rules ?? this.rules);
}

/// Notifier managing danmaku block rules.
class DanmakuBlockNotifier extends StateNotifier<DanmakuBlockState> {
  final DanmakuFilterRepository _repository;

  DanmakuBlockNotifier(this._repository)
      : super(DanmakuBlockState.initial()) {
    queryDanmakuFilter();
  }

  Future<void> queryDanmakuFilter() async {
    SmartDialog.showLoading(msg: '正在同步弹幕屏蔽规则……');
    final result = await _repository.danmakuFilter();
    SmartDialog.dismiss();
    if (result case Success(:final response)) {
      state = state.copyWith(
        rules: [
          [...response.rule],
          [...response.rule1],
          [...response.rule2],
        ],
      );
      if (response.toast case final toast?) {
        SmartDialog.showToast(toast);
      }
    } else {
      result.toast();
    }
  }

  Future<void> danmakuFilterDel(int tabIndex, int itemIndex, int id) async {
    SmartDialog.showLoading(msg: '正在删除弹幕屏蔽规则……');
    final res = await _repository.danmakuFilterDel(ids: id);
    SmartDialog.dismiss();
    if (res.isSuccess) {
      final newRules =
          state.rules.map(List<CoreSimpleRule>.of).toList();
      newRules[tabIndex].removeAt(itemIndex);
      state = state.copyWith(rules: newRules);
      SmartDialog.showToast('删除成功');
    } else {
      res.toast();
    }
  }

  Future<void> danmakuFilterAdd({
    required String filter,
    required int type,
  }) async {
    if (type == 2) {
      filter = getCrc32(ascii.encode(filter), 0).toRadixString(16);
    }
    SmartDialog.showLoading(msg: '正在添加弹幕屏蔽规则……');
    final res = await _repository.danmakuFilterAdd(
      filter: filter,
      type: type,
    );
    SmartDialog.dismiss();
    if (res case Success(:final response)) {
      final newRules =
          state.rules.map(List<CoreSimpleRule>.of).toList();
      newRules[type].add(response);
      state = state.copyWith(rules: newRules);
      SmartDialog.showToast('添加成功');
    } else {
      res.toast();
    }
  }
}

final danmakuBlockProvider =
    StateNotifierProvider.autoDispose<DanmakuBlockNotifier, DanmakuBlockState>(
  (ref) {
    final repo = ref.watch(danmakuFilterRepositoryProvider);
    return DanmakuBlockNotifier(repo);
  },
);
