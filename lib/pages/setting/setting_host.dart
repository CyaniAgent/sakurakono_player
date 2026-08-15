import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 设置页菜单项（渲染与导航由设置框架负责，内容由宿主注入）。
class SettingMenuItem {
  const SettingMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.contentBuilder,
  });

  final Icon icon;
  final String title;
  final String? subtitle;

  /// 内容页构建器：`showAppBar` 为 true 时以独立页推入（竖屏），
  /// false 时内联渲染（横屏右侧栏）。
  final Widget Function(bool showAppBar) contentBuilder;
}

/// 设置域宿主契约：页面框架通用，菜单项与账号/播放链接动作由适配器注入。
///
/// 设置页渲染通用框架（搜索 + 菜单列表 + 播放链接/切换账号/退出登录 +
/// 底部菜单），菜单项、账号操作与纯数字 ID 播放分派均来自
/// [SettingHost.of()] 的实现：
/// - Bilibili: [BiliSettingHost]（bridge `register()` 注入；B站 专属设置项
///   经 [SettingMenuItem.contentBuilder] 提供）
/// - OttoHub: [OttoSettingHost]（通用项，账号操作 stub）
abstract class SettingHost {
  static SettingHost of() => Get.find<SettingHost>();

  /// 主菜单项（隐私/推荐/音视频/播放器/外观/其它/WebDAV 等）。
  List<SettingMenuItem> get menuItems;

  /// 底部菜单项（渲染在「退出登录」之后，B站: 关于）。
  List<SettingMenuItem> get footerItems;

  /// 搜索入口（B站: `/settingsSearch`；无搜索能力的宿主返回 null 隐藏入口）。
  VoidCallback? get searchTap;

  /// 切换账号对话框（B站: `LoginPageController.switchAccountDialog`）。
  Future<void> switchAccountDialog(BuildContext context);

  /// 是否已登录（决定「退出登录」行可见性；B站: `Accounts.account`）。
  bool get hasAccount;

  /// 退出登录（含账号选择/确认对话框，B站: `Accounts`/`LoginHttp`）。
  Future<void> logout(BuildContext context);

  /// 播放链接分派：纯数字 ID 打开视频页
  /// （B站: `PageUtils.toVideoPage`，bvid=aid=cid=数字串）。
  void openVideoById(String id);
}
