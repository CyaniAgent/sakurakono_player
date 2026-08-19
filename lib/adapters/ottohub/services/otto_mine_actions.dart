import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/mine/mine_actions.dart';
import 'package:skf/router/app_navigator.dart';

/// OttoHub 的 mine 域导航/账号动作契约实现。
///
/// OttoHub 复用 Bilibili 路由表（`routes => BiliBridge.registerRoutes()`），
/// 导航类动作直接走共享路由；账号类操作（切换账号/退出/无痕模式）无 SDK
/// API，降级为 toast 提示/空操作（防御性降级，不抛异常）。
class OttoMineActions implements MineActions {

  @override
  List<MineMenuItem> get menuItems => const <MineMenuItem>[];

  @override
  bool get hasHome => false;

  @override
  bool get isMainMineTab => false;

  @override
  Widget? buildMsgBadge() => null;

  @override
  void openSearch() => AppNavigator.toNamed('/search');

  @override
  void openReply() => AppNavigator.toNamed('/myReply');

  @override
  void openSetting() => AppNavigator.toNamed('/setting', preventDuplicates: false);

  @override
  Future<void>? switchAccountDialog(BuildContext context) {
    SmartDialog.showToast('OttoHub 暂不支持');
    return null;
  }

  @override
  void openLoginPage() => AppNavigator.toNamed('/loginPage');

  @override
  void openMemberPage(int? mid) => AppNavigator.toNamed('/member?mid=$mid');

  @override
  void openUserPage(String name, int mid) => AppNavigator.toNamed('/$name?mid=$mid');

  @override
  Future<dynamic>? openFav() => AppNavigator.toNamed('/fav');

  @override
  void openFavDetail(
    CoreFavFolderInfo item,
    String heroTag,
    VoidCallback onPop,
  ) =>
      AppNavigator.toNamed(
        '/favDetail',
        arguments: item,
        parameters: {
          'mediaId': item.id.toString(),
          'heroTag': heroTag,
        },
      )?.whenComplete(onPop);

  @override
  Future<void> logout() => SmartDialog.showToast('OttoHub 暂不支持');

  @override
  bool get canToggleAnonymity => false;

  @override
  bool get isAnonymity => false;

  @override
  void setAnonymity(bool on, {bool permanent = false}) {}

  @override
  Color? vipNameColor(ThemeData theme) => null;
}
