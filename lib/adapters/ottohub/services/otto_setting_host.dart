import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/pages/about/view.dart';
import 'package:skf/pages/setting/setting_host.dart';
import 'package:skf/pages/setting/pages/display_mode.dart';
import 'package:skf/pages/setting/pages/font_size_select.dart';
import 'package:skf/pages/setting/pages/play_speed_set.dart';
import 'package:skf/pages/setting/pages/bar_set.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/utils.dart';

/// OttoHub 的设置域宿主实现。
///
/// 注入框架级设置子页(播放速度/显示模式/字号/栏位);账号类操作
/// (切换账号/退出)无 SDK API,降级为 toast 提示(防御性降级,不抛异常)。
class OttoSettingHost implements SettingHost {
  @override
  List<SettingMenuItem> get menuItems => [
        SettingMenuItem(
          icon: const Icon(Icons.speed),
          title: '播放速度',
          contentBuilder: (showAppBar) => PlaySpeedPage(showAppBar: showAppBar),
        ),
        SettingMenuItem(
          icon: const Icon(Icons.monitor),
          title: '屏幕帧率',
          contentBuilder: (showAppBar) => SetDisplayMode(showAppBar: showAppBar),
        ),
        SettingMenuItem(
          icon: const Icon(Icons.format_size),
          title: '字体大小',
          contentBuilder: (showAppBar) => FontSizeSelectPage(showAppBar: showAppBar),
        ),
        SettingMenuItem(
          icon: const Icon(Icons.view_week),
          title: '栏位设置',
          contentBuilder: (showAppBar) => BarSetPage(showAppBar: showAppBar),
        ),
      ];

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
    // OttoHub 视频为纯数字 ID,直接走框架视频页(统一播放入口)。
    final vid = int.parse(id);
    AppNavigator.toNamed(
      '/videoV',
      preventDuplicates: false,
      arguments: <String, dynamic>{
        'aid': vid,
        'bvid': id,
        'cid': vid,
        'heroTag': Utils.makeHeroTag(vid),
      },
    );
  }
}
