import 'dart:async';
import 'dart:math';

import 'package:skf/core/account/account_provider.dart';
import 'package:skf/pages/common/bar_hide_type.dart';
import 'package:skf/pages/common/common_controller.dart';
import 'package:skf/pages/common/common_page.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/pages/main/main_host.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';


// ---------------------------------------------------------------------------
// Riverpod StateNotifier pattern
// ---------------------------------------------------------------------------

/// Immutable state snapshot for the home tab controller.
class HomeState {
  const HomeState({
    this.tabs = const [],
    this.selectedTab = 0,
    this.hideTopBar = false,
    this.enableSearchWord = true,
    this.defaultSearch = '',
  });

  final List<HomeTabItem> tabs;
  final int selectedTab;
  final bool hideTopBar;
  final bool enableSearchWord;
  final String defaultSearch;

  HomeState copyWith({
    List<HomeTabItem>? tabs,
    int? selectedTab,
    bool? hideTopBar,
    bool? enableSearchWord,
    String? defaultSearch,
  }) => HomeState(
    tabs: tabs ?? this.tabs,
    selectedTab: selectedTab ?? this.selectedTab,
    hideTopBar: hideTopBar ?? this.hideTopBar,
    enableSearchWord: enableSearchWord ?? this.enableSearchWord,
    defaultSearch: defaultSearch ?? this.defaultSearch,
  );
}

/// Riverpod StateNotifier managing home tab state.
///
/// Mirrors the essential state from the GetX [HomeController] without
/// any GetX dependency. TabController lifecycle is managed by the view
/// (ConsumerStatefulWidget provides the TickerProvider).
class HomeControllerNotifier extends StateNotifier<HomeState>
    implements HomeBarState {
  HomeControllerNotifier() : super(const HomeState()) {
    _init();
  }

  late final MainHost _host = MainHost.of();
  late int lateCheckSearchAt = 0;

  // -- HomeBarState implementation --
  @override
  RxBool? showTopBar;

  // -- Tab controller --
  late TabController tabController;

  // -- Config (mutable for settings pages) --
  bool enableSearchWord = Pref.enableSearchWord;
  late final RxString defaultSearch = ''.obs;
  // -- Convenience getters for view compatibility --
  List<HomeTabItem> get tabs => state.tabs;
  bool get hideTopBar => state.hideTopBar;


  // -- Account --
  AccountProvider get accountService => Get.find<AccountProvider>();

  void _init() {
    final hideTopBar = !Pref.useSideBar && Pref.hideTopBar;
    enableSearchWord = Pref.enableSearchWord;

    _loadTabs();

    state = state.copyWith(
      hideTopBar: hideTopBar,
      enableSearchWord: enableSearchWord,
    );

    if (hideTopBar) {
      try {
        final mainCtr = Get.find<MainControllerNotifier>();
        switch (mainCtr.barHideType) {
          case BarHideType.instant:
            showTopBar = RxBool(true);
          case BarHideType.sync:
            mainCtr.barOffset ??= RxDouble(0.0);
        }
      } catch (_) {}
    }

    if (enableSearchWord) {
      lateCheckSearchAt = DateTime.now().millisecondsSinceEpoch;
      querySearchDefault();
    }
  }

  void _loadTabs() {
    final savedTabs = GStorage.setting.get(SettingBoxKey.tabBarSort) as List?;
    final List<HomeTabItem> tabs;
    if (savedTabs != null) {
      tabs = savedTabs.map((i) => _host.homeTabs[i]).toList();
    } else {
      tabs = _host.homeTabs;
    }

    final selectedIndex = max(
      0,
      tabs.indexWhere((t) => t.id == _host.defaultHomeTabId),
    );

    state = state.copyWith(
      tabs: tabs,
      selectedTab: selectedIndex,
    );
  }

  /// Switch to the tab at [index].
  void switchTab(int index) {
    if (index >= 0 && index < state.tabs.length) {
      state = state.copyWith(selectedTab: index);
    }
  }

  /// Get the [ScrollOrRefreshMixin] for a specific tab.
  ScrollOrRefreshMixin getControllerForTab(int index) {
    return _host.homeTabCtrFor(state.tabs[index]);
  }

  /// Animate scroll to top for the current tab.
  void animateToTop() {
    getControllerForTab(state.selectedTab).animateToTop();
  }

  /// Refresh the current tab.
  Future<void> onRefresh() async {
    await getControllerForTab(state.selectedTab).onRefresh();
  }

  /// Refresh or scroll to top for the current tab.
  void toTopOrRefresh() {
    getControllerForTab(state.selectedTab).toTopOrRefresh();
  }

  Future<void> querySearchDefault() async {
    try {
      final search = await _host.fetchDefaultSearchWord();
      defaultSearch.value = search;
      state = state.copyWith(defaultSearch: search);
    } catch (_) {}
  }
}

/// Riverpod provider for the home controller.
///
/// Usage:
/// ```dart
/// final homeState = ref.watch(homeControllerProvider);
/// ref.read(homeControllerProvider.notifier).switchTab(2);
/// ```
final homeControllerProvider =
    StateNotifierProvider<HomeControllerNotifier, HomeState>((ref) {
  return HomeControllerNotifier();
});
