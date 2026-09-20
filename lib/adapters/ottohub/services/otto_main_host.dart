import 'package:flutter/material.dart';
import 'package:skf/common/widgets/custom_icon.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/pages/common/bar_hide_type.dart';
import 'package:skf/pages/common/common_controller.dart';
import 'package:skf/pages/common/msg_unread_type.dart';
import 'package:skf/pages/dynamics/view.dart';
import 'package:skf/pages/home/view.dart';
import 'package:skf/pages/main/main_host.dart';
import 'package:skf/pages/mine/view.dart';
import 'package:skf/pages/rcmd/controller.dart';
import 'package:skf/pages/rcmd/view.dart';

/// OttoHub MainHost：主 tab 集（首页/动态/我的,与原版三 tab 一致）。
/// 首页子 tab 用共享 RcmdController/RcmdPage（走 core VideoRepository——
/// OttoHub 已实现 `rcmdVideoList`，非 stub）；动态 tab 走共享 DynamicsPage
/// （博客流,经 DynamicsRepository.followDynamic）。外壳专属行为
/// （未读动态/更新/scheme）无对应域，返回 no-op/空值。
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
          id: MainTabIds.dynamics,
          label: '动态',
          icon: Icon(CustomIcons.motion_photos_on_outlined),
          selectedIcon: Icon(CustomIcons.motion_photos_on),
          page: DynamicsPage(),
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
  // OttoHub 未读数是单一 total(getNewMessageNum),映射在 sysMsg 上;
  // 只启用 sysMsg 避免与 pm 映射重复累加。
  Set<MsgUnReadType> get msgUnReadTypes => const {MsgUnReadType.sysMsg};

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
