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

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin, ScrollOrRefreshMixin
    implements HomeBarState {
  late final MainHost _host = MainHost.of();


  late List<HomeTabItem> tabs;
  late TabController tabController;

  @override
  RxBool? showTopBar;
  late final bool hideTopBar;

  bool enableSearchWord = Pref.enableSearchWord;
  late final RxString defaultSearch = ''.obs;
  late int lateCheckSearchAt = 0;

  ScrollOrRefreshMixin get controller =>
      _host.homeTabCtrFor(tabs[tabController.index]);

  @override
  ScrollController get scrollController => controller.scrollController;

  AccountProvider get accountService => Get.find<AccountProvider>();

  @override
  void onInit() {
    super.onInit();

    hideTopBar = !Pref.useSideBar && Pref.hideTopBar;
    if (hideTopBar) {
      final mainCtr = Get.find<MainController>();
      switch (mainCtr.barHideType) {
        case BarHideType.instant:
          showTopBar = RxBool(true);
        case BarHideType.sync:
          mainCtr.barOffset ??= RxDouble(0.0);
      }
    }

    if (enableSearchWord) {
      lateCheckSearchAt = DateTime.now().millisecondsSinceEpoch;
      querySearchDefault();
    }

    setTabConfig();
  }

  @override
  Future<void> onRefresh() {
    return controller.onRefresh().catchError((e) {
      if (kDebugMode) debugPrint(e.toString());
    });
  }

  void setTabConfig() {
    final tabs = GStorage.setting.get(SettingBoxKey.tabBarSort) as List?;
    if (tabs != null) {
      this.tabs = tabs.map((i) => _host.homeTabs[i]).toList();
    } else {
      this.tabs = _host.homeTabs;
    }

    tabController = TabController(
      initialIndex: max(0, this.tabs.indexWhere((t) => t.id == _host.defaultHomeTabId)),
      length: this.tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> querySearchDefault() async {
    try {
      defaultSearch.value = await _host.fetchDefaultSearchWord();
    } catch (_) {}
  }
}

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
class HomeControllerNotifier extends StateNotifier<HomeState> {
  HomeControllerNotifier() : super(const HomeState()) {
    _init();
  }

  late final MainHost _host = MainHost.of();
  late int lateCheckSearchAt = 0;

  void _init() {
    final hideTopBar = !Pref.useSideBar && Pref.hideTopBar;
    final enableSearchWord = Pref.enableSearchWord;

    _loadTabs();

    state = state.copyWith(
      hideTopBar: hideTopBar,
      enableSearchWord: enableSearchWord,
    );

    if (enableSearchWord) {
      lateCheckSearchAt = DateTime.now().millisecondsSinceEpoch;
      _querySearchDefault();
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

  Future<void> _querySearchDefault() async {
    try {
      final defaultSearch = await _host.fetchDefaultSearchWord();
      state = state.copyWith(defaultSearch: defaultSearch);
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
