import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/adapters/bilibili/pages/about/view.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/pages/setting/setting_host.dart';

/// OttoHub 的设置域宿主实现。
///
/// OttoHub 复用 Bilibili 路由表；设置页框架渲染通用行（播放链接/关于），
/// B站 专属设置项不注入；账号类操作（切换账号/退出）无 SDK API，
/// 降级为 toast 提示（防御性降级，不抛异常）。
class OttoSettingHost implements SettingHost {

  @override
  List<SettingMenuItem> get menuItems => const <SettingMenuItem>[];

  @override
  List<SettingMenuItem> get footerItems => [
    SettingMenuItem(
      icon: const Icon(Icons.info_outline),
      title: '关于',
      contentBuilder: (showAppBar) => AboutPage(showAppBar: showAppBar),
    ),
  ];

  @override
  VoidCallback? get searchTap => null;

  @override
  Future<void> switchAccountDialog(BuildContext context) =>
      SmartDialog.showToast('OttoHub 暂不支持');

  @override
  bool get hasAccount => false;

  @override
  Future<void> logout(BuildContext context) =>
      SmartDialog.showToast('OttoHub 暂不支持');

  @override
  void openVideoById(String id) {
    // OttoHub 播放经共享 bilibili 视频页（设置页「播放链接」统一入口）。
    final vid = int.parse(id);
    PageUtils.toVideoPage(bvid: id, aid: vid, cid: vid);
  }
}
