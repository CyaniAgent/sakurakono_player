import 'package:flutter/material.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:skf/adapters/bilibili/http/login.dart';
import 'package:skf/adapters/bilibili/models/common/setting_type.dart';
import 'package:skf/adapters/bilibili/pages/about/view.dart';
import 'package:skf/adapters/bilibili/pages/login/controller.dart';
import 'package:skf/adapters/bilibili/pages/webdav/view.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/accounts/account.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/pages/setting/common_setting.dart';
import 'package:skf/pages/setting/setting_host.dart';
import 'package:skf/pages/setting/widgets/multi_select_dialog.dart';

/// B站 设置域宿主：菜单项（隐私/推荐/音视频/播放器/外观/其它/WebDAV/关于）
/// 与账号操作、播放链接分派。
///
/// 设置框架（lib/pages/setting/）零适配器依赖；B站 专属设置项内容经
/// [SettingMenuItem.contentBuilder] 提供。
class BiliSettingHost implements SettingHost {
  @override
  List<SettingMenuItem> get menuItems => [
    _commonItem(
      SettingType.privacySetting,
      subtitle: '黑名单',
      icon: const Icon(Icons.privacy_tip_outlined),
    ),
    _commonItem(
      SettingType.recommendSetting,
      subtitle: '推荐来源（web/app）、刷新保留内容、过滤器',
      icon: const Icon(Icons.explore_outlined),
    ),
    _commonItem(
      SettingType.videoSetting,
      subtitle: '画质、音质、解码、缓冲、音频输出等',
      icon: const Icon(Icons.video_settings_outlined),
    ),
    _commonItem(
      SettingType.playSetting,
      subtitle: '双击/长按、全屏、后台播放、弹幕、字幕、底部进度条等',
      icon: const Icon(Icons.touch_app_outlined),
    ),
    _commonItem(
      SettingType.styleSetting,
      subtitle: '横屏适配（平板）、侧栏、列宽、首页、动态红点、主题、字号、图片、帧率等',
      icon: const Icon(Icons.style_outlined),
    ),
    _commonItem(
      SettingType.extraSetting,
      subtitle: '震动、搜索、收藏、ai、评论、动态、代理、更新检查等',
      icon: const Icon(Icons.extension_outlined),
    ),
    SettingMenuItem(
      icon: const Icon(MdiIcons.databaseCogOutline),
      title: SettingType.webdavSetting.title,
      contentBuilder: (showAppBar) => WebDavSettingPage(
        showAppBar: showAppBar,
      ),
    ),
  ];

  @override
  List<SettingMenuItem> get footerItems => [
    SettingMenuItem(
      icon: const Icon(Icons.info_outline),
      title: SettingType.about.title,
      contentBuilder: (showAppBar) => AboutPage(showAppBar: showAppBar),
    ),
  ];

  SettingMenuItem _commonItem(
    SettingType type, {
    String? subtitle,
    required Icon icon,
  }) =>
      SettingMenuItem(
        icon: icon,
        title: type.title,
        subtitle: subtitle,
        contentBuilder: (showAppBar) => CommonSetting(
          title: type.title,
          settings: type.settings,
          showAppBar: showAppBar,
        ),
      );

  @override
  VoidCallback? get searchTap => () => AppNavigator.toNamed('/settingsSearch');

  @override
  Future<void> switchAccountDialog(BuildContext context) async {
    await LoginNotifier.switchAccountDialog(context);
  }

  @override
  bool get hasAccount => Accounts.account.isNotEmpty;

  @override
  Future<void> logout(BuildContext context) async {
    final result = await showDialog<Set<LoginAccount>>(
      context: context,
      builder: (context) => MultiSelectDialog<LoginAccount>(
        title: '选择要登出的账号uid',
        initValues: const Iterable.empty(),
        values: {
          for (final i in Accounts.account.values) i: i.mid.toString(),
        },
      ),
    );
    if (!context.mounted || result == null || result.isEmpty) return;
    Future<void> doLogout() => Accounts.deleteAll(result);

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('提示'),
          content: Text(
            "确认要退出以下账号登录吗\n\n${result.map((i) => i.mid.toString()).join('\n')}",
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text(
                '点错了',
                style: TextStyle(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                AppNavigator.back();
                doLogout();
              },
              child: Text(
                '仅登出',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () async {
                SmartDialog.showLoading();
                final res = await LoginHttp.logout(Accounts.main);
                if (res['status']) {
                  SmartDialog.dismiss();
                  doLogout();
                  AppNavigator.back();
                } else {
                  SmartDialog.dismiss();
                  SmartDialog.showToast(res['msg'].toString());
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  @override
  void openVideoById(String id) {
    // classifyPlayInput 已保证 trim 后 ^\d+$，int.parse 不会失败。
    final vid = int.parse(id);
    PageUtils.toVideoPage(bvid: id, aid: vid, cid: vid);
  }
}
