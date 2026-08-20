import 'dart:io' show Platform;
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/core/container/app_container.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/adapters/bilibili/common/widgets/dialog/report_member.dart';
import 'package:skf/adapters/bilibili/pages/coin_log/controller.dart';
import 'package:skf/adapters/bilibili/pages/exp_log/controller.dart';
import 'package:skf/adapters/bilibili/pages/log_table/view.dart';
import 'package:skf/adapters/bilibili/pages/login_devices/view.dart';
import 'package:skf/adapters/bilibili/pages/login_log/controller.dart';
import 'package:skf/adapters/bilibili/pages/member_cheese/view.dart';
import 'package:skf/adapters/bilibili/pages/member_contribute/controller.dart';
import 'package:skf/adapters/bilibili/pages/member_contribute/view.dart';
import 'package:skf/adapters/bilibili/pages/member_dynamics/view.dart';
import 'package:skf/adapters/bilibili/pages/member_favorite/view.dart';
import 'package:skf/adapters/bilibili/pages/member_guard/view.dart';
import 'package:skf/adapters/bilibili/pages/member_home/view.dart';
import 'package:skf/adapters/bilibili/pages/member_pgc/view.dart';
import 'package:skf/adapters/bilibili/pages/member_shop/view.dart';
import 'package:skf/adapters/bilibili/pages/member_upower_rank/view.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/archive/view.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/season_series/view.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/app_scheme.dart';
import 'package:skf/adapters/bilibili/utils/bili_storage_pref.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/adapters/bilibili/utils/request_utils.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/member/member_host.dart';
import 'package:skf/pages/member/widget/medal_wall.dart';
import 'package:skf/utils/android/android_helper.dart';
import 'package:skf/utils/cache_manager.dart';
import 'package:skf/utils/extension/string_ext.dart';
import 'package:skf/utils/share_utils.dart';

/// Bilibili implementation of [MemberHost].
///
/// Bridges the generic member page to B站-specific pages/APIs:
/// sub-page tabs, follow/block feedback, report dialog, live medal wall,
/// login devices/logs, home-screen shortcut, deep URL routing.
class BiliMemberHost implements MemberHost {
  /// Medal wall cache keyed by mid (never shared across users), with a TTL
  /// so repeated opens of the same mid reuse the data but eventually refresh.
  static const Duration _medalCacheTtl = Duration(minutes: 5);
  final Map<int, ({CoreMedalWallData data, DateTime fetchedAt})> _medalCache =
      {};

  @override
  int get currentUserId => Accounts.main.mid;

  @override
  List<CoreSpaceTab2> filterTabs(List<CoreSpaceTab2> tabs) {
    tabs.retainWhere((item) => MemberTabType.contains(item.param ?? ''));
    return tabs;
  }

  @override
  String? get preferredTabParam {
    final memberTab = BiliPref.memberTab;
    return memberTab == MemberTabType.def ? null : memberTab.name;
  }

  @override
  Widget buildTab({
    required String param,
    String? title,
    required String heroTag,
    required int mid,
    required RxInt contributeInitialIndex,
  }) {
    return switch (param) {
      'home' => MemberHome(heroTag: heroTag),
      'dynamic' => MemberDynamicsPage(mid: mid),
      'contribute' => Obx(
          () => MemberContribute(
            heroTag: heroTag,
            initialIndex: contributeInitialIndex.value,
            mid: mid,
          ),
        ),
      'bangumi' => MemberBangumi(heroTag: heroTag, mid: mid),
      'favorite' => MemberFavorite(heroTag: heroTag, mid: mid),
      'cheese' => MemberCheese(heroTag: heroTag, mid: mid),
      'shop' => MemberShop(heroTag: heroTag, mid: mid),
      _ => Center(child: Text(title ?? '')),
    };
  }

  @override
  bool canToWebArchive(String heroTag) =>
      MemberContributeNotifier.isRegistered(heroTag);

  @override
  void toWebArchive({
    required String heroTag,
    required int mid,
    required String username,
  }) {
    try {
      final state = MemberContributeNotifier.getState(heroTag);
      final item = state?.items?[state.currentIndex];
      if (item != null) {
        final id = item.seasonId ?? item.seriesId;
        if (id != null) {
          MemberSSWeb.toMemberSSWeb(
            type: item.seasonId != null ? .season : .series,
            id: id,
            mid: mid,
            name: username,
          );
          return;
        }
      }
      MemberVideoWeb.toMemberVideoWeb(mid: mid, name: username);
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  @override
  void actionRelationMod(
    BuildContext context, {
    required int mid,
    required bool isFollow,
    required ValueChanged<int> afterMod,
  }) {
    RequestUtils.actionRelationMod(
      context: context,
      mid: mid,
      isFollow: isFollow,
      afterMod: afterMod,
    );
  }

  @override
  void shareUser(int mid) {
    ShareUtils.shareText('https://space.bilibili.com/$mid');
  }

  @override
  void openLoginDevices() => AppNavigator.to(const CoreLoginDevicesPage());

  @override
  void openLoginLog() => AppNavigator.to(
        const LogPage(),
        arguments: LoginLogController(),
      );

  @override
  void openCoinLog() => AppNavigator.to(
        const LogPage(),
        arguments: CoinLogController(),
      );

  @override
  void openExpLog() => AppNavigator.to(
        const LogPage(),
        arguments: ExpLogController(),
      );

  @override
  void showReportDialog(
    BuildContext context, {
    required String? name,
    required int mid,
  }) {
    showMemberReportDialog(context, name: name, mid: mid);
  }

  @override
  Future<void> showLiveMedalWall(int mid) async {
    void onShow(CoreMedalWallData data) {
      final context = AppNavigator.context;
      if (context == null) return;
      showDialog(
        context: context,
        builder: (_) => MedalWall(response: data),
      );
    }

    final cached = _medalCache[mid];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _medalCacheTtl) {
      onShow(cached.data);
      return;
    }
    SmartDialog.showLoading();
    final res = await appRead(liveRepositoryProvider).liveMedalWall(mid: mid);
    SmartDialog.dismiss();
    if (res case Success(:final response)) {
      _medalCache[mid] = (data: response, fetchedAt: DateTime.now());
      onShow(response);
    } else {
      res.toast();
    }
  }

  @override
  void createShortcut({
    required int mid,
    required String name,
    required String avatar,
  }) {
    if (Platform.isIOS) {
      PageUtils.launchURL(
        'https://www.bilibili.com/blackboard/disablelink/go-to-up-space.html?mid=$mid',
      );
    } else if (Platform.isAndroid) {
      _createShortcutAndroid(mid, name, avatar);
    }
  }

  Future<void> _createShortcutAndroid(
    int mid,
    String name,
    String avatar,
  ) async {
    try {
      SmartDialog.showLoading();
      final file = await CacheManager.manager.getSingleFile(
        '$avatar@200w_200h.webp'.http2https,
      );
      SmartDialog.dismiss();
      PiliAndroidHelper.createShortcut(
        mid.toString(),
        'bilibili://space/$mid',
        name,
        file.path,
      );
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  @override
  void pushDynFromId(String? id) => PageUtils.pushDynFromId(id: id);

  @override
  void handleWebview(String url) => PageUtils.handleWebview(url);

  @override
  void pushFromUri(String uri) => PiliScheme.routePushFromUrl(uri);

  @override
  void openMemberGuard({
    required int mid,
    required String name,
    required Object? count,
  }) {
    MemberGuard.toMemberGuard(mid: mid, name: name, count: count);
  }

  @override
  void openUpowerRank({
    required int mid,
    required String name,
    required Object? count,
  }) {
    UpowerRankPage.toUpowerRank(mid: mid, name: name, count: count);
  }
}
