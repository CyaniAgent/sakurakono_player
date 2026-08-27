import 'package:flutter/material.dart';
import 'package:skf/adapters/bilibili/common/setting_providers.dart';
import 'package:skf/adapters/bilibili/pages/rcmd/view.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/pages/common/bar_hide_type.dart';
import 'package:skf/pages/common/common_controller.dart';
import 'package:skf/pages/common/msg_unread_type.dart';
import 'package:skf/pages/home/view.dart';
import 'package:skf/pages/main/main_host.dart';
import 'package:skf/pages/mine/view.dart';

/// OttoHub MainHost：Otto 侧自定 tab 集（首页/我的），首页子 tab 用共享
/// RcmdController/RcmdPage（走 core VideoRepository——OttoHub 已实现
/// `rcmdVideoList`，非 stub）。外壳专属行为（未读动态/更新/scheme）无对应
/// 域，返回 no-op/空值。
class OttoMainHost implements MainHost {
  @override
  List<MainTab> get tabs => const [
        MainTab(
          id: MainTabIds.home,
          label: '首页',
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          page: HomePage(),
        ),
        MainTab(
          id: MainTabIds.mine,
          label: '我的',
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          page: MinePage(),
        ),
      ];

  @override
  BarHideType get barHideType => BarHideType.sync;

  @override
  Set<MsgUnReadType> get msgUnReadTypes => const {};

  @override
  Future<int?> fetchUnreadDynamic() async => null;

  @override
  void checkAppUpdate() {}

  @override
  void initScheme() {}

  @override
  void disposeScheme() {}

  @override
  List<HomeTabItem> get homeTabs => const [
        HomeTabItem(id: 'rcmd', label: '推荐'),
      ];

  @override
  String get defaultHomeTabId => 'rcmd';

  @override
  ScrollOrRefreshMixin homeTabCtrFor(HomeTabItem tab) =>
      appRead(rcmdControllerProvider);

  @override
  Widget homeTabPageFor(HomeTabItem tab) => const RcmdPage();

  @override
  Future<String> fetchDefaultSearchWord() async => '';
}
