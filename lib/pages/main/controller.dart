import 'dart:async';

import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
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
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Riverpod ChangeNotifier managing the main shell tab navigation state.
///
/// Implements [MainBarState] so the generic page layer stays free of
/// adapter imports. PageController/TabController lifecycle is managed
/// by the view (ConsumerStatefulWidget provides the TickerProvider).
class MainControllerNotifier extends ChangeNotifier
    implements MainBarState {
  MainControllerNotifier() {
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
  double? _barOffset;
  @override
  double? get barOffset => _barOffset;
  @override
  set barOffset(double? value) {
    if (_barOffset != value) {
      _barOffset = value;
      notifyListeners();
    }
  }

  bool? _showBottomBar;
  @override
  bool? get showBottomBar => _showBottomBar;
  @override
  set showBottomBar(bool? value) {
    if (_showBottomBar != value) {
      _showBottomBar = value;
      notifyListeners();
    }
  }

  @override
  bool useBottomNav = false;

  // -- Reactive state for ListenableBuilder widgets --
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    if (_selectedIndex != value) {
      _selectedIndex = value;
      notifyListeners();
    }
  }

  int _dynCount = 0;
  int get dynCount => _dynCount;
  set dynCount(int value) {
    if (_dynCount != value) {
      _dynCount = value;
      notifyListeners();
    }
  }

  String _msgUnReadCount = '';
  String get msgUnReadCount => _msgUnReadCount;
  set msgUnReadCount(String value) {
    if (_msgUnReadCount != value) {
      _msgUnReadCount = value;
      notifyListeners();
    }
  }

  // -- Tab/Page controller --
  late dynamic controller;

  // -- Mutable runtime state --
  bool isPlaying = false;
  int _lastSelectTime = 0;

  // -- Account --
  AccountState get accountService => appRead(accountProvider);

  // -- Child controllers --
  late final homeController = appRead(homeControllerProvider);
  late final dynamicController = appRead(dynamicsControllerProvider);

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
          showBottomBar = true;
        case BarHideType.sync:
          barOffset = 0.0;
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
      final res = await appRead(msgRepositoryProvider).msgUnread();
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
      final res = await appRead(msgRepositoryProvider).msgFeedUnread();
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
      msgUnReadCount = '';
      return;
    }
    final res = await Future.wait([_msgUnread(), _msgFeedUnread()]);
    final count = res.sum;
    final countStr = count == 0
        ? ''
        : count > 99
        ? '99+'
        : count.toString();
    if (msgUnReadCount != countStr || isChangeType) {
      msgUnReadCount = countStr;
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
    dynCount = count;
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
    _selectedIndex = defPage.clamp(0, _navigationBars.length - 1);
  }

  // -- Tab selection --

  /// Callback invoked by the view after the PageController/TabController
  /// has been animated/jumped. The notifier only updates state here.
  void onTabChanged(int index) {
    if (index == _selectedIndex) {
      // Same tab tapped — handled externally (scroll-to-top / refresh).
    } else {
      selectedIndex = index;
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
    if (value != _selectedIndex) {
      selectedIndex = value;
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
          navigationBars[_selectedIndex].id != MainTabIds.home) {
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
          navigationBars[_selectedIndex].id != MainTabIds.home) {
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
      homeController.showTopBar = true;
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
    ChangeNotifierProvider<MainControllerNotifier>((ref) {
  return MainControllerNotifier();
});
