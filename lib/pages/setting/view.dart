import 'package:skf/common/widgets/flutter/list_tile.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/pages/setting/play_input_dialog.dart';
import 'package:skf/pages/setting/setting_host.dart';
import 'package:skf/utils/extension/size_ext.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:get/get.dart';

/// 通用设置页框架：搜索 + 菜单列表 + 播放链接/切换账号/退出登录 + 底部菜单。
///
/// 菜单项、账号操作与搜索入口均由 [SettingHost] 注入（B站: [BiliSettingHost]；
/// OttoHub: [OttoSettingHost]），本页零适配器依赖。
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final SettingHost _host = SettingHost.of();
  SettingMenuItem? _type;
  late bool _isPortrait;
  late ThemeData theme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    theme = Theme.of(context);
    _isPortrait = MediaQuery.sizeOf(context).isPortrait;
    // 横屏默认选中首个菜单项（无菜单项时为 null → 空右侧栏）。
    _type ??= _host.menuItems.isEmpty ? null : _host.menuItems.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: _isPortrait ? const Text('设置') : Text(_type?.title ?? '设置'),
      ),
      body: ViewSafeArea(
        child: _isPortrait
            ? _buildList(theme)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildList(theme),
                  ),
                  VerticalDivider(
                    width: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  Expanded(
                    flex: 6,
                    child: _type == null
                        ? const SizedBox.shrink()
                        : _type!.contentBuilder(false),
                  ),
                ],
              ),
      ),
    );
  }

  void _toPage(SettingMenuItem item) {
    if (_isPortrait) {
      Get.to(() => item.contentBuilder(true));
    } else {
      _type = item;
      setState(() {});
    }
  }

  Color? _getTileColor(ThemeData theme, SettingMenuItem item) {
    if (_isPortrait) {
      return null;
    } else {
      return identical(item, _type)
          ? theme.colorScheme.onInverseSurface
          : null;
    }
  }

  Widget _buildList(ThemeData theme) {
    final padding = MediaQuery.viewPaddingOf(context);
    TextStyle titleStyle = theme.textTheme.titleMedium!;
    TextStyle subTitleStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.outline,
    );
    return ListView(
      padding: EdgeInsets.only(bottom: padding.bottom + 100),
      children: [
        if (_host.searchTap != null) _buildSearchItem(theme),
        ..._host.menuItems.map(
          (item) => ListTile(
            tileColor: _getTileColor(theme, item),
            onTap: () => _toPage(item),
            leading: item.icon,
            title: Text(item.title, style: titleStyle),
            subtitle: item.subtitle == null
                ? null
                : Text(item.subtitle!, style: subTitleStyle),
          ),
        ),
        ListTile(
          onTap: () => showPlayInputDialog(context),
          leading: const Icon(Icons.play_circle_outline),
          title: Text('播放链接', style: titleStyle),
        ),
        ListTile(
          onTap: () => _host.switchAccountDialog(context),
          leading: const Icon(Icons.switch_account_outlined),
          title: Text('切换账号', style: titleStyle),
        ),
        Obx(
          () => _host.hasAccount
              ? ListTile(
                  leading: const Icon(Icons.logout_outlined),
                  onTap: () => _host.logout(context),
                  title: Text('退出登录', style: titleStyle),
                )
              : const SizedBox.shrink(),
        ),
        ..._host.footerItems.map(
          (item) => ListTile(
            tileColor: _getTileColor(theme, item),
            onTap: () => _toPage(item),
            leading: item.icon,
            title: Text(item.title, style: titleStyle),
            subtitle: item.subtitle == null
                ? null
                : Text(item.subtitle!, style: subTitleStyle),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchItem(ThemeData theme) => Padding(
    padding: const EdgeInsets.only(
      left: 16,
      right: 16,
      bottom: 8,
    ),
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: _host.searchTap,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            color: theme.colorScheme.onInverseSurface,
          ),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  size: 18,
                  applyTextScaling: true,
                  Icons.search,
                ),
                Text(
                  ' 搜索',
                  style: TextStyle(height: 1),
                  strutStyle: StrutStyle(height: 1, leading: 0),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

