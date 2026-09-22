import 'dart:async';
import 'dart:math';

import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/pages/common/bar_hide_type.dart';
import 'package:skf/pages/common/common_controller.dart';
import 'package:skf/pages/common/common_page.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/pages/main/main_host.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// ---------------------------------------------------------------------------
// Riverpod ChangeNotifier pattern
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

/// Manages home tab state. TabController lifecycle is managed by the view.
class HomeControllerNotifier extends ChangeNotifier
    implements HomeBarState {
  HomeControllerNotifier() {
    _init();
  }

  late final MainHost _host = MainHost.of();
  late int lateCheckSearchAt = 0;

  // -- HomeBarState implementation --
  bool? _showTopBar;
  @override
  bool? get showTopBar => _showTopBar;
  @override
  set showTopBar(bool? value) {
    if (_showTopBar != value) {
      _showTopBar = value;
      notifyListeners();
    }
  }

  // -- Tab controller --
  /// 由页面视图在 initState 注入（vsync 归视图所有，随视图 dispose 释放）。
  late TabController tabController;
  bool _tabControllerReady = false;

  /// 页面 initState 调用：创建 TabController 并把 index 变更同步进 state
  /// （animateToTop/onRefresh 依赖 [HomeState.selectedTab]）。
  void initTabController(TickerProvider vsync) {
    if (_tabControllerReady) return;
    tabController = TabController(
      length: _state.tabs.length,
      initialIndex: _state.selectedTab.clamp(0, _state.tabs.length - 1),
      vsync: vsync,
    );
    _tabControllerReady = true;
    tabController.addListener(_onTabIndexChanged);
  }

  /// 页面 dispose 调用（全局 controller 生命周期长于页面，重进时重建）。
  void disposeTabController() {
    if (!_tabControllerReady) return;
    tabController.removeListener(_onTabIndexChanged);
    tabController.dispose();
    _tabControllerReady = false;
  }

  void _onTabIndexChanged() {
    if (!tabController.indexIsChanging &&
        _state.selectedTab != tabController.index) {
      _state = _state.copyWith(selectedTab: tabController.index);
    }
  }

  // -- State --
  HomeState _state = const HomeState();
  HomeState get state => _state;

  // -- Config (mutable for settings pages) --
  bool enableSearchWord = Pref.enableSearchWord;

  // -- Convenience getters/setters for view compatibility --
  String get defaultSearch => _state.defaultSearch;
  set defaultSearch(String value) {
    _state = _state.copyWith(defaultSearch: value);
    notifyListeners();
  }
  List<HomeTabItem> get tabs => _state.tabs;
  bool get hideTopBar => _state.hideTopBar;


  // -- Account --
  AccountState get accountService => appRead(accountProvider);

  void _init() {
    final hideTopBar = !Pref.useSideBar && Pref.hideTopBar;
    enableSearchWord = Pref.enableSearchWord;

    _loadTabs();

    _state = _state.copyWith(
      hideTopBar: hideTopBar,
      enableSearchWord: enableSearchWord,
    );

    if (hideTopBar) {
      try {
        final mainCtr = appRead(mainControllerProvider);
        switch (mainCtr.barHideType) {
          case BarHideType.instant:
            _showTopBar = true;
          case BarHideType.sync:
            mainCtr.barOffset ??= 0.0;
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
    // 存量偏好可能含越界索引或漏掉新增 tab:过滤后为空则回退全量。
    final List<HomeTabItem> tabs;
    if (savedTabs != null) {
      final bars = savedTabs
          .where((i) => i >= 0 && i < _host.homeTabs.length)
          .map((i) => _host.homeTabs[i])
          .toList();
      tabs = bars.isEmpty ? _host.homeTabs : bars;
    } else {
      tabs = _host.homeTabs;
    }

    final selectedIndex = max(
      0,
      tabs.indexWhere((t) => t.id == _host.defaultHomeTabId),
    );

    _state = _state.copyWith(
      tabs: tabs,
      selectedTab: selectedIndex,
    );
  }

  /// Switch to the tab at [index].
  void switchTab(int index) {
    if (index >= 0 && index < _state.tabs.length) {
      _state = _state.copyWith(selectedTab: index);
      if (_tabControllerReady && tabController.index != index) {
        tabController.animateTo(index);
      }
      notifyListeners();
    }
  }

  /// Get the [ScrollOrRefreshMixin] for a specific tab.
  ScrollOrRefreshMixin getControllerForTab(int index) {
    return _host.homeTabCtrFor(_state.tabs[index]);
  }

  /// Animate scroll to top for the current tab.
  void animateToTop() {
    getControllerForTab(_state.selectedTab).animateToTop();
  }

  /// Refresh the current tab.
  Future<void> onRefresh() async {
    await getControllerForTab(_state.selectedTab).onRefresh();
  }

  /// Refresh or scroll to top for the current tab.
  void toTopOrRefresh() {
    getControllerForTab(_state.selectedTab).toTopOrRefresh();
  }

  Future<void> querySearchDefault() async {
    try {
      final search = await _host.fetchDefaultSearchWord();
      _state = _state.copyWith(defaultSearch: search);
      notifyListeners();
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
    ChangeNotifierProvider<HomeControllerNotifier>((ref) {
  return HomeControllerNotifier();
});
