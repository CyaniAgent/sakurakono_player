
import 'package:skf/adapters/bilibili/grpc/dyn.dart';
import 'package:skf/adapters/bilibili/http/api.dart';
import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/adapters/bilibili/models/common/home_tab_type.dart';
import 'package:skf/adapters/bilibili/pages/common/home_tab_helper.dart'
    as home_tab_helper;
import 'package:skf/adapters/bilibili/utils/app_scheme.dart';
import 'package:skf/adapters/bilibili/utils/bili_storage_pref.dart';
import 'package:skf/adapters/bilibili/utils/update.dart';
import 'package:skf/adapters/bilibili/utils/wbi_sign.dart';
import 'package:skf/pages/common/common_controller.dart';
import 'package:skf/pages/main/main_host.dart';
import 'package:flutter/widgets.dart';

/// B站 MainHost：把 `NavigationBarType`（首页/动态/我的）映射为通用 tab，
/// 首页子 tab（live/rcmd/hot/rank/bangumi/cinema）经 home_tab_helper 注入，
/// 外壳专属行为（未读动态 gRPC、自动更新、URL scheme）在此收敛。
class BiliMainHost implements MainHost {
  @override
  List<MainTab> get tabs => [
        for (final t in NavigationBarType.values)
          MainTab(
            id: t.name,
            label: t.label,
            icon: t.icon,
            selectedIcon: t.selectIcon,
            page: t.page,
          ),
      ];

  @override
  BarHideType get barHideType => BiliPref.barHideType;

  @override
  Set<MsgUnReadType> get msgUnReadTypes => BiliPref.msgUnReadTypeV2;

  @override
  Future<int?> fetchUnreadDynamic() => DynGrpc.dynRed();

  @override
  void checkAppUpdate() => Update.checkUpdate();

  @override
  void initScheme() => PiliScheme.init();

  @override
  void disposeScheme() => PiliScheme.listener?.cancel();

  @override
  List<HomeTabItem> get homeTabs => [
        for (final t in HomeTabType.values)
          HomeTabItem(id: t.name, label: t.label),
      ];

  @override
  String get defaultHomeTabId => HomeTabType.rcmd.name;

  @override
  ScrollOrRefreshMixin homeTabCtrFor(HomeTabItem tab) =>
      home_tab_helper.homeTabCtrFor(_homeTabTypeFor(tab));

  @override
  Widget homeTabPageFor(HomeTabItem tab) =>
      home_tab_helper.homeTabPageFor(_homeTabTypeFor(tab));

  @override
  Future<String> fetchDefaultSearchWord() async {
    try {
      final res = await Request().get(
        Api.searchDefault,
        queryParameters: await WbiSign.makSign({'web_location': 333.1365}),
      );
      if (res.data['code'] == 0) {
        return res.data['data']?['name'] ?? '';
      }
    } catch (_) {}
    return '';
  }

  /// Hive `tabBarSort` 可能存旧索引/未知值——未知 id 回退默认 tab（rcmd），
  /// 避免 `HomeTabType.values.byName` 对未知 name 抛 ArgumentError 崩首页。
  HomeTabType _homeTabTypeFor(HomeTabItem tab) => HomeTabType.values.firstWhere(
        (e) => e.name == tab.id,
        orElse: () => HomeTabType.rcmd,
      );
}
