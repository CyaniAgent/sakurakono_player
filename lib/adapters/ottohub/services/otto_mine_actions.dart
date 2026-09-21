import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/common/widgets/custom_icon.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/mine/mine_actions.dart';
import 'package:skf/router/app_navigator.dart';

/// OttoHub 的 mine 域导航/账号动作契约实现。
///
/// 导航类动作走共享路由(OttoBridge.routes);菜单项含 离线缓存/
/// 历史记录/我的收藏/动态。账号类操作(切换账号/退出)无 SDK API,
/// 降级为 toast 提示(防御性降级,不抛异常)。
class OttoMineActions implements MineActions {

  @override
  List<MineMenuItem> get menuItems => <MineMenuItem>[
    MineMenuItem(
      icon: CustomIcons.folderDownloadOutline,
      title: '离线缓存',
      onTap: () => AppNavigator.toNamed('/download'),
    ),
    MineMenuItem(
      icon: CustomIcons.history,
      title: '历史记录',
      loginRequired: true,
      onTap: () => AppNavigator.toNamed('/history'),
    ),
    MineMenuItem(
      icon: CustomIcons.star_favorite_line,
      title: '我的收藏',
      loginRequired: true,
      onTap: () => AppNavigator.toNamed('/fav'),
    ),
    MineMenuItem(
      icon: CustomIcons.motion_photos_on,
      title: '动态',
      loginRequired: true,
      onTap: () => AppNavigator.toNamed('/dynamics'),
    ),
  ];

  @override
  bool get hasHome => false;

  @override
  bool get isMainMineTab => false;

  @override
  Widget? buildMsgBadge() => null;

  @override
  void openSearch() => AppNavigator.toNamed('/search');

  @override
  void openReply() => AppNavigator.toNamed('/replyMe');

  @override
  void openSetting() => AppNavigator.toNamed('/setting', preventDuplicates: false);

  @override
  Future<void>? switchAccountDialog(BuildContext context) {
    SmartDialog.showToast('暂不支持切换账号');
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
  Future<void> logout() => SmartDialog.showToast('请在 OttoHub 客户端退出登录');

  @override
  bool get canToggleAnonymity => false;

  @override
  bool get isAnonymity => false;

  @override
  void setAnonymity(bool on, {bool permanent = false}) {}

  @override
  Color? vipNameColor(ThemeData theme) => null;
}
