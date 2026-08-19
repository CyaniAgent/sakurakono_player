import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/pages/main/main_host.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';

/// Riverpod-based state for the home tab controller.
///
/// Mirrors the essential tab-related state from the existing GetX
/// [HomeController] without any GetX dependency.
class HomeTabState {
  const HomeTabState({
    this.selectedTab = 0,
    this.tabList = const [],
  });

  /// Currently selected home sub-tab index.
  final int selectedTab;

  /// Ordered list of home sub-tabs.
  final List<HomeTabItem> tabList;

  HomeTabState copyWith({
    int? selectedTab,
    List<HomeTabItem>? tabList,
  }) => HomeTabState(
        selectedTab: selectedTab ?? this.selectedTab,
        tabList: tabList ?? this.tabList,
      );
}

/// StateNotifier that manages the home tab selection and tab list.
///
/// Reads [MainHost] via `MainHost.of()` (GetX service locator) to obtain the
/// adapter-provided tab configuration. This is the only coupling to the
/// existing DI layer; no GetX controller base class is used.
class HomeTabController extends StateNotifier<HomeTabState> {
  HomeTabController() : super(const HomeTabState()) {
    loadTabs();
  }

  /// Load (or reload) the home sub-tab list from the active adapter.
  ///
  /// Reads the persisted sort order from Hive [SettingBoxKey.tabBarSort].
  /// Falls back to the adapter default when no saved order exists.
  void loadTabs() {
    final host = MainHost.of();
    final savedOrder = GStorage.setting.get(SettingBoxKey.tabBarSort) as List?;

    final List<HomeTabItem> tabs;
    if (savedOrder != null) {
      tabs = savedOrder.map((i) => host.homeTabs[i]).toList();
    } else {
      tabs = host.homeTabs;
    }

    final defaultIndex = max(
      0,
      tabs.indexWhere((t) => t.id == host.defaultHomeTabId),
    );

    state = state.copyWith(
      tabList: tabs,
      selectedTab: defaultIndex,
    );
  }

  /// Switch to the tab at [index].
  void switchTab(int index) {
    if (index >= 0 && index < state.tabList.length) {
      state = state.copyWith(selectedTab: index);
    }
  }
}

/// Provides the [HomeTabController] notifier.
///
/// Usage:
/// ```dart
/// final tabState = ref.watch(homeTabProvider);
/// ref.read(homeTabProvider.notifier).switchTab(2);
/// ```
final homeTabProvider =
    StateNotifierProvider<HomeTabController, HomeTabState>((ref) {
  return HomeTabController();
});
