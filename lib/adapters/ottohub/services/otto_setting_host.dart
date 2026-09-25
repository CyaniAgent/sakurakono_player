import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/adapters/ottohub/services/otto_account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/ui/up_panel_position.dart';
import 'package:skf/pages/about/view.dart';
import 'package:skf/pages/dynamics/controller.dart';
import 'package:skf/pages/rcmd/widgets/home_slideshow.dart';
import 'package:skf/pages/setting/common_setting.dart';
import 'package:skf/pages/setting/models/model.dart';
import 'package:skf/pages/setting/pages/font_size_select.dart';
import 'package:skf/pages/setting/pages/play_speed_set.dart';
import 'package:skf/pages/setting/setting_host.dart';
import 'package:skf/pages/setting/setting_parts/models/play_settings.dart';
import 'package:skf/pages/setting/widgets/select_dialog.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/utils/utils.dart';

/// OttoHub 的设置域宿主实现。
///
/// 注入设置子页:播放速度/播放器(手势/全屏/弹幕/键盘等框架通用项)/
/// 字号;「屏幕帧率」为 Android 专用、「栏位设置」依赖 B站 首页参数、
/// 「音视频设置」依赖 B站 CDN/画质码,均不注入。切换账号无 SDK API
/// 降级为 toast,退出登录经账号提供者清除本地凭证。
class OttoSettingHost implements SettingHost {
  @override
  List<SettingMenuItem> get menuItems => [
        SettingMenuItem(
          icon: const Icon(Icons.speed),
          title: '播放速度',
          contentBuilder: (showAppBar) => PlaySpeedPage(showAppBar: showAppBar),
        ),
        SettingMenuItem(
          icon: const Icon(Icons.touch_app_outlined),
          title: '播放器设置',
          subtitle: '弹幕、手势、全屏、后台播放、键盘控制等',
          contentBuilder: (showAppBar) => CommonSetting(
            title: '播放器设置',
            settings: playSettings,
            showAppBar: showAppBar,
          ),
        ),
        SettingMenuItem(
          icon: const Icon(Icons.view_carousel_outlined),
          title: '首页轮播',
          subtitle: '轮播样式',
          contentBuilder: (showAppBar) => CommonSetting(
            title: '首页轮播',
            settings: [
              NormalModel(
                title: '轮播样式',
                leading: const Icon(Icons.style),
                getSubtitle: () => Pref.carouselStyle == 1
                    ? '当前:「不均匀大卡(multi-browse)」'
                    : '当前:「均匀大卡 + 右侧窄卡窥视」',
                onTap: (context, setState) async {
                  final result = await showDialog<int>(
                    context: context,
                    builder: (context) => SelectDialog<int>(
                      title: '轮播样式',
                      value: Pref.carouselStyle,
                      values: const [
                        (0, '均匀大卡 + 右侧窄卡窥视'),
                        (1, '不均匀大卡(multi-browse)'),
                      ],
                    ),
                  );
                  if (result != null) {
                    Pref.carouselStyle = result;
                    HomeSlideshow.carouselStyle.value = result;
                    setState();
                  }
                },
              ),
            ],
            showAppBar: showAppBar,
          ),
        ),
        SettingMenuItem(
          icon: const Icon(Icons.view_week_outlined),
          title: '动态页布局',
          subtitle: 'UP 关注面板位置',
          contentBuilder: (showAppBar) => CommonSetting(
            title: '动态页布局',
            settings: [
              NormalModel(
                title: 'UP 面板位置',
                leading: const Icon(Icons.group_outlined),
                getSubtitle: () =>
                    '当前:「${UpPanelPosition.values[Pref.upPanelPosition].label}」',
                onTap: (context, setState) async {
                  final result = await showDialog<int>(
                    context: context,
                    builder: (context) => SelectDialog<int>(
                      title: 'UP 面板位置',
                      value: Pref.upPanelPosition,
                      values: UpPanelPosition.values
                          .map((e) => (e.index, e.label))
                          .toList(),
                    ),
                  );
                  if (result != null) {
                    Pref.upPanelPosition = result;
                    // 控制器实时读取 Pref,通知后动态页立即按新位置重排。
                    appRead(dynamicsControllerProvider).notifyListeners();
                    setState();
                  }
                },
              ),
            ],
            showAppBar: showAppBar,
          ),
        ),
        SettingMenuItem(
          icon: const Icon(Icons.format_size),
          title: '字体大小',
          contentBuilder: (showAppBar) => FontSizeSelectPage(showAppBar: showAppBar),
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
      SmartDialog.showToast('暂不支持切换账号');

  @override
  bool get hasAccount => appRead(ottoAccountProvider).isLogin;

  @override
  bool get playInputEnabled => false;

  @override
  Future<void> logout(BuildContext context) async {
    appRead(ottoAccountProvider).clearCredentials();
    SmartDialog.showToast('已退出登录');
  }

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
