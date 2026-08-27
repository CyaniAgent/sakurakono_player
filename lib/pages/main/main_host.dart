import 'package:flutter/widgets.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/pages/common/bar_hide_type.dart';
import 'package:skf/pages/common/common_controller.dart';
import 'package:skf/pages/common/msg_unread_type.dart';
import 'package:skf/pages/providers.dart';

/// Main shell host — tab list + tab pages + shell behaviors injected by adapter.
///
/// The generic main shell (`lib/pages/main/`) renders a tab framework
/// (NavigationRail / NavigationDrawer / BottomNavigationBar); the tab set,
/// per-tab pages, home subtabs and adapter-specific behaviors all come from
/// the active adapter's [MainHost] implementation:
/// - Bilibili: [BiliMainHost]（`lib/adapters/bilibili/common/main_host.dart`）
///   maps `NavigationBarType` → tabs and `HomeTabType` + home_tab_helper →
///   home subtabs.
/// - OttoHub: [OttoMainHost]（`lib/adapters/ottohub/services/otto_main_host.dart`）
///   provides its own simplified tab set.
///
/// 接入方式（与 W3 member/mine/video host 一致）：双端 bridge register() 里
/// `Get.lazyPut<MainHost>(() => BiliMainHost())`，外壳用 `MainHost.of()` 获取。
abstract class MainHost {
  static MainHost of() => appRead(mainHostProvider);

  /// 主框架导航 tab 列表（B站: 首页/动态/我的）。
  List<MainTab> get tabs;

  /// 顶栏隐藏方式（B站: `BiliPref.barHideType`）。
  BarHideType get barHideType;

  /// 消息角标类型集合（B站: `BiliPref.msgUnReadTypeV2`；无消息域返回空集）。
  Set<MsgUnReadType> get msgUnReadTypes;

  /// 未读动态数（B站: `DynGrpc.dynRed()`；无动态域返回 null）。
  Future<int?> fetchUnreadDynamic();

  /// 自动更新检查（B站: `Update.checkUpdate()`；无更新通道时 no-op）。
  void checkAppUpdate();

  /// 移动端 URL scheme 监听初始化（B站: `PiliScheme.init()`）。
  void initScheme();

  /// 释放 scheme 监听（B站: `PiliScheme.listener?.cancel()`）。
  void disposeScheme();

  // ---- 首页子 tab（B站: HomeTabType + home_tab_helper；OttoHub: 自定）----

  /// 首页子 tab 列表（B站: `HomeTabType.values`）。
  List<HomeTabItem> get homeTabs;

  /// 首页默认子 tab id（B站: rcmd）。
  String get defaultHomeTabId;

  /// 子 tab 控制器查询（B站: home_tab_helper 的 `homeTabCtrFor`）。
  ScrollOrRefreshMixin homeTabCtrFor(HomeTabItem tab);

  /// 子 tab 页面构建（B站: home_tab_helper 的 `homeTabPageFor`）。
  Widget homeTabPageFor(HomeTabItem tab);

  /// 首页搜索框默认词（B站: `Api.searchDefault` + `WbiSign`；无则返回空串）。
  Future<String> fetchDefaultSearchWord();
}

/// 主框架导航 tab 的稳定 id（外壳按 id 区分语义 tab）。
abstract final class MainTabIds {
  static const home = 'home';
  static const dynamics = 'dynamics';
  static const mine = 'mine';
}

/// 主框架导航 tab（label/图标/页面由适配器注入）。
class MainTab {
  const MainTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  /// 稳定 id（`MainTabIds`）。
  final String id;
  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final Widget page;
}

/// 首页子 tab 描述（B站: HomeTabType 镜像）。
class HomeTabItem {
  const HomeTabItem({required this.id, required this.label});

  /// 稳定 id（B站: `HomeTabType.name`）。
  final String id;
  final String label;
}
