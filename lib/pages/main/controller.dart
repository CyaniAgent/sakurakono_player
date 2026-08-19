import 'dart:async';

import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/bar_hide_type.dart';
import 'package:skf/pages/common/common_page.dart';
import 'package:skf/pages/common/dynamic_badge_mode.dart';
import 'package:skf/pages/common/msg_unread_type.dart';
import 'package:skf/pages/dynamics/controller.dart';
import 'package:skf/pages/home/controller.dart';
import 'package:skf/pages/main/main_host.dart';
import 'package:skf/pages/mine/view.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/extension/get_ext.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';


// ---------------------------------------------------------------------------
// Riverpod StateNotifier pattern
// ---------------------------------------------------------------------------

/// Immutable state snapshot for the main shell controller.
class MainState {
  const MainState({
    this.selectedIndex = 0,
    this.navigationBars = const [],
    this.dynCount = 0,
    this.msgUnReadCount = '',
    this.useBottomNav = false,
    this.barOffset,
    this.showBottomBar,
    this.isPlaying = false,
  });

  final int selectedIndex;
  final List<MainTab> navigationBars;
  final int dynCount;
  final String msgUnReadCount;
  final bool useBottomNav;
  final double? barOffset;
  final bool? showBottomBar;
  final bool isPlaying;

  MainState copyWith({
    int? selectedIndex,
    List<MainTab>? navigationBars,
    int? dynCount,
    String? msgUnReadCount,
    bool? useBottomNav,
    double? barOffset,
    bool clearBarOffset = false,
    bool? showBottomBar,
    bool clearShowBottomBar = false,
    bool? isPlaying,
  }) => MainState(
    selectedIndex: selectedIndex ?? this.selectedIndex,
    navigationBars: navigationBars ?? this.navigationBars,
    dynCount: dynCount ?? this.dynCount,
    msgUnReadCount: msgUnReadCount ?? this.msgUnReadCount,
    useBottomNav: useBottomNav ?? this.useBottomNav,
    barOffset: clearBarOffset ? null : (barOffset ?? this.barOffset),
    showBottomBar: clearShowBottomBar ? null : (showBottomBar ?? this.showBottomBar),
    isPlaying: isPlaying ?? this.isPlaying,
  );
}

/// Riverpod StateNotifier managing the main shell tab navigation state.
///
/// Mirrors the essential state from the GetX [MainController] without
/// any GetX dependency. PageController/TabController lifecycle is managed
/// by the view (ConsumerStatefulWidget provides the TickerProvider).
class MainControllerNotifier extends StateNotifier<MainState>
    implements MainBarState {
  MainControllerNotifier() : super(const MainState()) {
    _init();
  }


  late final MainHost _host = MainHost.of();
  late List<MainTab> _navigationBars;

  // -- Read-only config flags exposed as plain getters --
  late bool hideBottomBar;
  late final BarHideType barHideType = _host.barHideType;
  final bool enableMYBar = Pref.enableMYBar;
  final bool floatingNavBar = Pref.floatingNavBar;
  final bool useSideBar = Pref.useSideBar;
  final bool mainTabBarView = Pref.mainTabBarView;
  late final bool optTabletNav = Pref.optTabletNav;
  late bool directExitOnBack = Pref.directExitOnBack;
  late bool showTrayIcon = Pref.showTrayIcon;
  late bool minimizeOnExit = Pref.minimizeOnExit;
  late bool pauseOnMinimize = Pref.pauseOnMinimize;

  late DynamicBadgeMode dynamicBadgeMode;
  late bool checkDynamic = Pref.checkDynamic;
  late int dynamicPeriod = Pref.dynamicPeriod * 60 * 1000;
  late int _lastCheckDynamicAt = 0;
  late bool hasDyn = false;
  late bool hasHome = false;
  late DynamicBadgeMode msgBadgeMode = DynamicBadgeMode.values[Pref.msgBadgeMode];
  late Set<MsgUnReadType> msgUnReadTypes = _host.msgUnReadTypes;
  late int lastCheckUnreadAt = 0;

  // -- MainBarState implementation --
  @override
  RxDouble? barOffset;
  @override
  RxBool? showBottomBar;
  @override
  bool useBottomNav = false;

  // -- Reactive state for Obx widgets --
  final RxInt selectedIndex = 0.obs;
  final RxInt dynCount = 0.obs;
  late final RxString msgUnReadCount = ''.obs;

  // -- Tab/Page controller --
  late dynamic controller;

  // -- Mutable runtime state --
  bool isPlaying = false;
  int _lastSelectTime = 0;

  // -- Account --
  AccountProvider get accountService => Get.find<AccountProvider>();

  // -- Child controllers --
  late final homeController = Get.putOrFind(HomeControllerNotifier.new);
  late final dynamicController = Get.putOrFind(DynamicsController.new);

  void _init() {
    if (Pref.autoUpdate) {
      _host.checkAppUpdate();
    }

    _setNavBarConfig();

    hideBottomBar =
        !useSideBar && _navigationBars.length > 1 && Pref.hideBottomBar;
    if (hideBottomBar) {
      switch (barHideType) {
        case BarHideType.instant:
          showBottomBar = RxBool(true);
        case BarHideType.sync:
          barOffset = RxDouble(0.0);
      }
    }

    dynamicBadgeMode = DynamicBadgeMode.values[Pref.dynamicBadgeMode];
    hasDyn = _navigationBars.any((tab) => tab.id == MainTabIds.dynamics);
    if (dynamicBadgeMode != DynamicBadgeMode.hidden && hasDyn) {
      if (checkDynamic) {
        _lastCheckDynamicAt = DateTime.now().millisecondsSinceEpoch;
      }
      getUnreadDynamic();
    }

    hasHome = _navigationBars.any((tab) => tab.id == MainTabIds.home);
    if (msgBadgeMode != DynamicBadgeMode.hidden && hasHome) {
      lastCheckUnreadAt = DateTime.now().millisecondsSinceEpoch;
      queryUnreadMsg();
    }
  }

  // -- Navigation bars --

  List<MainTab> get navigationBars => _navigationBars;

  // -- Msg & dynamic badge --

  Future<int> _msgUnread() async {
    if (msgUnReadTypes.contains(MsgUnReadType.pm)) {
      final res = await Get.find<MsgRepository>().msgUnread();
      if (res case Success(:final response)) {
        return response.followUnread +
            response.unfollowUnread +
            response.bizMsgFollowUnread +
            response.bizMsgUnfollowUnread +
            response.unfollowPushMsg +
            response.customUnread;
      }
    }
    return 0;
  }

  Future<int> _msgFeedUnread() async {
    int count = 0;
    final remainTypes = Set<MsgUnReadType>.from(msgUnReadTypes)
      ..remove(MsgUnReadType.pm);
    if (remainTypes.isNotEmpty) {
      final res = await Get.find<MsgRepository>().msgFeedUnread();
      if (res case Success(:final response)) {
        for (final item in remainTypes) {
          switch (item) {
            case MsgUnReadType.pm:
              break;
            case MsgUnReadType.reply:
              count += response.reply;
            case MsgUnReadType.at:
              count += response.at;
            case MsgUnReadType.like:
              count += response.like;
            case MsgUnReadType.sysMsg:
              count += response.sysMsg;
          }
        }
      }
    }
    return count;
  }

  Future<void> queryUnreadMsg([bool isChangeType = false]) async {
    if (!hasHome || msgUnReadTypes.isEmpty || msgBadgeMode == DynamicBadgeMode.hidden) {
      msgUnReadCount.value = '';
      return;
    }
    final res = await Future.wait([_msgUnread(), _msgFeedUnread()]);
    final count = res.sum;
    final countStr = count == 0
        ? ''
        : count > 99
        ? '99+'
        : count.toString();
    if (msgUnReadCount.value != countStr || isChangeType) {
      msgUnReadCount.value = countStr;
    }
  }

  void getUnreadDynamic() {
    if (!hasDyn) return;
    unawaited(_host.fetchUnreadDynamic().then((res) {
      if (res != null) setDynCount(res);
    }).catchError((Object _) {}));
  }

  void setDynCount([int count = 0]) {
    if (!hasDyn) return;
    dynCount.value = count;
  }

  void checkUnreadDynamic() {
    if (!hasDyn || dynamicBadgeMode == DynamicBadgeMode.hidden || !checkDynamic) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastCheckDynamicAt >= dynamicPeriod) {
      _lastCheckDynamicAt = now;
      getUnreadDynamic();
    }
  }

  void _setNavBarConfig() {
    List<int>? navBarSort =
        (GStorage.setting.get(SettingBoxKey.navBarSort) as List?)?.fromCast();
    if (navBarSort == null || navBarSort.isEmpty) {
      _navigationBars = _host.tabs;
    } else {
      _navigationBars = navBarSort.map((i) => _host.tabs[i]).toList();
    }
    final defPage = Pref.defaultHomePageIndex;
    selectedIndex.value = defPage.clamp(0, _navigationBars.length - 1);
  }

  // -- Tab selection --

  /// Callback invoked by the view after the PageController/TabController
  /// has been animated/jumped. The notifier only updates state here.
  void onTabChanged(int index) {
    if (index == state.selectedIndex) {
      // Same tab tapped — handled externally (scroll-to-top / refresh).
    } else {
      selectedIndex.value = index;
    }
  }

  bool get hasHomeTab => hasHome;
  bool get hasDynamicsTab => hasDyn;

  // -- Account change --

  void onChangeAccount(bool isLogin) {
    if (isLogin) {
      getUnreadDynamic();
    } else {
      setDynCount();
    }
  }

  void setIndex(int value) {
    feedBack();
    final currentNav = navigationBars[value];
    if (value != selectedIndex.value) {
      selectedIndex.value = value;
      if (mainTabBarView) {
        (controller as TabController).animateTo(value);
      } else {
        (controller as PageController).jumpToPage(value);
      }
      if (currentNav.id == MainTabIds.home) {
        checkDefaultSearch();
        checkUnread();
      } else if (currentNav.id == MainTabIds.dynamics) {
        setDynCount();
      }
    } else {
      int now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastSelectTime < 500) {
        EasyThrottle.throttle(
          'topOrRefresh',
          const Duration(milliseconds: 500),
          () {
            if (currentNav.id == MainTabIds.home) {
              homeController.onRefresh();
            } else if (currentNav.id == MainTabIds.dynamics) {
              dynamicController.onRefresh();
            }
          },
        );
      } else {
        if (currentNav.id == MainTabIds.home) {
          homeController.toTopOrRefresh();
        } else if (currentNav.id == MainTabIds.dynamics) {
          dynamicController.toTopOrRefresh();
        }
      }
      _lastSelectTime = now;
    }
  }

  void checkDefaultSearch([bool shouldCheck = false]) {
    if (hasHome && homeController.state.enableSearchWord) {
      if (shouldCheck &&
          navigationBars[selectedIndex.value].id != MainTabIds.home) {
        return;
      }
      int now = DateTime.now().millisecondsSinceEpoch;
      if (now - homeController.lateCheckSearchAt >= 5 * 60 * 1000) {
        homeController
          ..lateCheckSearchAt = now
          ..querySearchDefault();
      }
    }
  }

  void checkUnread([bool shouldCheck = false]) {
    if (accountService.isLogin &&
        hasHome &&
        msgBadgeMode != DynamicBadgeMode.hidden) {
      if (shouldCheck &&
          navigationBars[selectedIndex.value].id != MainTabIds.home) {
        return;
      }
      int now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastCheckUnreadAt >= 5 * 60 * 1000) {
        lastCheckUnreadAt = now;
        queryUnreadMsg();
      }
    }
  }

  void setSearchBar() {
    if (hasHome) {
      homeController.showTopBar?.value = true;
    }
  }

  int? _mineIndex;
  void toMinePage() {
    _mineIndex ??=
        navigationBars.indexWhere((tab) => tab.id == MainTabIds.mine);
    if (_mineIndex != -1) {
      setIndex(_mineIndex!);
    } else {
      AppNavigator.to(
        const Material(
          child: ViewSafeArea(
            top: true,
            child: MinePage(showBackBtn: true),
          ),
        ),
      );
    }
  }
}

final mainControllerProvider =
    StateNotifierProvider<MainControllerNotifier, MainState>((ref) {
  return MainControllerNotifier();
});
