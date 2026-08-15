import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/mine/mine_actions.dart';

/// OttoHub 的 mine 域导航/账号动作契约实现。
///
/// OttoHub 复用 Bilibili 路由表（`routes => BiliBridge.registerRoutes()`），
/// 导航类动作直接走共享路由；账号类操作（切换账号/退出/无痕模式）无 SDK
/// API，抛 `not_implemented`（与 OttoHub stub 契约一致）。
class OttoMineActions implements MineActions {
  Never _err() => throw UnimplementedError('not_implemented');

  @override
  List<MineMenuItem> get menuItems => const <MineMenuItem>[];

  @override
  bool get hasHome => false;

  @override
  bool get isMainMineTab => false;

  @override
  Widget? buildMsgBadge() => null;

  @override
  void openSearch() => Get.toNamed('/search');

  @override
  void openReply() => Get.toNamed('/myReply');

  @override
  void openSetting() => Get.toNamed('/setting', preventDuplicates: false);

  @override
  Future<void>? switchAccountDialog(BuildContext context) => _err();

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
  Future<void> logout() => _err();

  @override
  bool get canToggleAnonymity => false;

  @override
  bool get isAnonymity => false;

  @override
  void setAnonymity(bool on, {bool permanent = false}) => _err();

  @override
  Color? vipNameColor(ThemeData theme) => null;
}
