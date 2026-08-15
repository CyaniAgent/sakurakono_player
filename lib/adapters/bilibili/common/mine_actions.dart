import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/models/common/account_type.dart';
import 'package:skf/adapters/bilibili/models/common/nav_bar_config.dart';
import 'package:skf/adapters/bilibili/pages/home/view.dart' show msgBadge;
import 'package:skf/adapters/bilibili/pages/login/controller.dart';
import 'package:skf/adapters/bilibili/pages/main/controller.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/accounts/account.dart';
import 'package:skf/adapters/bilibili/utils/extension/theme_ext.dart';
import 'package:skf/common/widgets/custom_icon.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/mine/mine_actions.dart';

/// mine 域导航/账号动作契约的 B站 实现（bridge `register()` 注入）。
class BiliMineActions implements MineActions {
  @override
  List<MineMenuItem> get menuItems => <MineMenuItem>[
    MineMenuItem(
      icon: CustomIcons.folderDownloadOutline,
      title: '离线缓存',
      onTap: () => Get.toNamed('/download'),
    ),
    MineMenuItem(
      icon: CustomIcons.history,
      title: '观看记录',
      loginRequired: true,
      onTap: () => Get.toNamed('/history'),
    ),
    MineMenuItem(
      icon: CustomIcons.subscriptions_outlined,
      title: '我的订阅',
      loginRequired: true,
      onTap: () => Get.toNamed('/subscription'),
    ),
    MineMenuItem(
      icon: CustomIcons.watch_later_outlined,
      title: '稍后再看',
      loginRequired: true,
      onTap: () => Get.toNamed('/later'),
    ),
  ];

  @override
  bool get hasHome => Get.find<MainController>().hasHome;

  @override
  bool get isMainMineTab {
    final mainController = Get.find<MainController>();
    return mainController.navigationBars[0] != NavigationBarType.mine &&
        mainController.selectedIndex.value == 0;
  }

  @override
  Widget? buildMsgBadge() => msgBadge(Get.find<MainController>());

  @override
  void openSearch() => Get.toNamed('/search');

  @override
  void openReply() => Get.toNamed('/myReply');

  @override
  void openSetting() => Get.toNamed('/setting', preventDuplicates: false);

  @override
  Future<void>? switchAccountDialog(BuildContext context) =>
      LoginPageController.switchAccountDialog(context);

  @override
  void openLoginPage() => Get.toNamed('/loginPage');

  @override
  void openMemberPage(int? mid) => Get.toNamed('/member?mid=$mid');

  @override
  void openUserPage(String name, int mid) => Get.toNamed('/$name?mid=$mid');

  @override
  Future<dynamic>? openFav() => Get.toNamed('/fav');

  @override
  void openFavDetail(
    CoreFavFolderInfo item,
    String heroTag,
    VoidCallback onPop,
  ) =>
      Get.toNamed(
        '/favDetail',
        arguments: item,
        parameters: {
          'mediaId': item.id.toString(),
          'heroTag': heroTag,
        },
      )?.whenComplete(onPop);

  @override
  Future<void> logout() => Accounts.deleteAll({Accounts.main});

  @override
  bool get canToggleAnonymity => Accounts.account.isNotEmpty;

  @override
  bool get isAnonymity =>
      Accounts.account.isNotEmpty && !Accounts.heartbeat.isLogin;

  @override
  void setAnonymity(bool on, {bool permanent = false}) {
    if (on) {
      if (permanent) {
        Accounts.set(AccountType.heartbeat, AnonymousAccount());
      } else {
        Accounts.accountMode[AccountType.heartbeat.index] =
            AnonymousAccount();
      }
    } else {
      Accounts.set(AccountType.heartbeat, Accounts.main);
    }
  }

  @override
  Color? vipNameColor(ThemeData theme) => theme.colorScheme.vipColor;
}
