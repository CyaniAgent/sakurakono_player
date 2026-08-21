import 'dart:async';

import 'package:skf/adapters/bilibili/models/common/rank_type.dart'; // ignore: adapter import (no core equivalent for RankType)
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/adapters/bilibili/pages/rank/zone/controller.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

class RankState {
  const RankState({this.tabIndex = 0});

  final int tabIndex;

  RankState copyWith({int? tabIndex}) =>
      RankState(tabIndex: tabIndex ?? this.tabIndex);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class RankNotifier extends StateNotifier<RankState> {
  RankNotifier() : super(const RankState());

  /// Current tab index stored statically so home_tab_helper can access it.
  static int currentTabIndex = 0;

  void setTabIndex(int index) {
    currentTabIndex = index;
    state = state.copyWith(tabIndex: index);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final rankProvider =
    StateNotifierProvider.autoDispose<RankNotifier, RankState>(
  (ref) => RankNotifier(),
);

// ---------------------------------------------------------------------------
// GetX bridge for home_tab_helper compatibility
// ---------------------------------------------------------------------------

/// Lightweight bridge that implements [ScrollOrRefreshMixin] for the home tab
/// system. Registered with GetX so home_tab_helper can find it.
///
/// Delegates scroll/refresh operations to the current ZoneController.
class RankScrollBridge implements ScrollOrRefreshMixin {
  RankScrollBridge();

  ZoneController get _currentController {
    final index = RankNotifier.currentTabIndex;
    if (index < 0 || index >= RankType.values.length) {
      // Fallback to first zone
      final item = RankType.values.first;
      return Get.find<ZoneController>(tag: '${item.rid}${item.seasonType}');
    }
    final item = RankType.values[index];
    return Get.find<ZoneController>(tag: '${item.rid}${item.seasonType}');
  }

  @override
  ScrollController get scrollController => _currentController.scrollController;

  @override
  Future<void> onRefresh() => _currentController.onRefresh();

  @override
  void animateToTop() => scrollController.animToTop();

  @override
  void toTopOrRefresh() {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels == 0) {
        onRefresh();
      } else {
        animateToTop();
      }
    }
  }
}
