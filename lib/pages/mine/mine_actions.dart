import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/fav_types.dart';

/// mine 页菜单项（导航动作由调用方注入）。
class MineMenuItem {
  const MineMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.loginRequired = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  /// 点击前需处于登录态（B站: 观看记录/我的订阅/稍后再看）。
  final bool loginRequired;
}

/// mine 域导航/账号动作契约（页面通用，动作由适配器注入）。
///
/// mine 页渲染通用菜单框架（用户信息 + 菜单行 + 收藏行 + 头部按钮）；
/// 菜单项、路由跳转与账号操作均来自 [MineActions.of()] 的实现：
/// - Bilibili: [BiliMineActions]（bridge `register()` 注入）
/// - OttoHub: [OttoMineActions]（stub，导航复用共享路由表）
abstract class MineActions {
  static MineActions of() => Get.find<MineActions>();

  // ---- 菜单项（页面渲染通用框架，菜单由调用方注入）----

  /// 菜单项列表（离线缓存/观看记录/我的订阅/稍后再看等）。
  List<MineMenuItem> get menuItems;

  // ---- 主框架状态 ----

  /// 主框架是否含首页 tab（为 true 时隐藏搜索/消息入口）。
  bool get hasHome;

  /// 当前主 tab 是否为 mine 页（决定滚动通知是否生效）。
  bool get isMainMineTab;

  /// 消息角标（B站: `home/view.dart` 的 `msgBadge(MainController)`）。
  Widget? buildMsgBadge();

  // ---- 头部按钮 ----

  /// 打开搜索页。
  void openSearch();

  /// 打开评论记录页。
  void openReply();

  /// 打开设置页。
  void openSetting();

  /// 切换账号对话框（B站: `LoginPageController.switchAccountDialog`）。
  Future<void>? switchAccountDialog(BuildContext context);

  /// 打开登录页。
  void openLoginPage();

  /// 打开个人主页。
  void openMemberPage(int? mid);

  /// 打开用户页（动态/关注/粉丝）。
  void openUserPage(String name, int mid);

  // ---- 收藏 ----

  /// 打开收藏页（返回路由 Future，供 `whenComplete` 刷新）。
  Future<dynamic>? openFav();

  /// 打开收藏夹详情页。
  void openFavDetail(
    CoreFavFolderInfo item,
    String heroTag,
    VoidCallback onPop,
  );

  // ---- 账号操作 ----

  /// 退出登录（B站: `Accounts.deleteAll({Accounts.main})`）。
  Future<void> logout();

  /// 无痕模式是否可切换（未登录时 false）。
  bool get canToggleAnonymity;

  /// 无痕模式当前状态。
  bool get isAnonymity;

  /// 设置无痕模式（B站: `Accounts.set(AccountType.heartbeat, ...)`）。
  void setAnonymity(bool on, {bool permanent = false});

  // ---- 主题 ----

  /// 大会员昵称颜色（B站: `colorScheme.vipColor`；无则返回 null）。
  Color? vipNameColor(ThemeData theme);
}
