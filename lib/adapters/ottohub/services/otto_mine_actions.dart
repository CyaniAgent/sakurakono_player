import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/adapters/ottohub/services/otto_account_provider.dart';
import 'package:skf/common/widgets/custom_icon.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/msg_feed_top/message_page.dart' show MessagePage;
import 'package:skf/pages/mine/mine_actions.dart';
import 'package:skf/router/app_navigator.dart';

/// OttoHub 的 mine 域导航/账号动作契约实现。
///
/// 导航类动作走共享路由(OttoBridge.routes);菜单项含 离线缓存/
/// 历史记录/我的收藏/动态。SDK 无登出端点,退出登录为客户端本地
/// 清除凭证(clearCredentials),登录态经 Riverpod 同步到各监听方。
class OttoMineActions implements MineActions {

  @override
  List<MineMenuItem> get menuItems => <MineMenuItem>[
    // 离线缓存:OttoHub 无下载 API(download_actions 为 stub),隐藏入口。
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
  Widget? buildMsgBadge() => const _MineMsgBadge();

  @override
  void openSearch() => AppNavigator.toNamed('/search');

  @override
  void openSetting() => AppNavigator.toNamed('/setting', preventDuplicates: false);

  @override
  Future<dynamic>? switchAccountDialog(BuildContext context) {
    // 单账号体系:清凭证退出后直接进入登录页。
    logout();
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
  Future<void> logout() async {
    // SDK 无登出端点:客户端清除本地 token/账密缓存并同步账号态
    // (clearCredentials → accountProvider 更新 → mine 页监听自动重置)。
    appRead(ottoAccountProvider).clearCredentials();
    SmartDialog.showToast('已退出登录');
  }

  @override
  bool get canToggleAnonymity => false;

  @override
  bool get isAnonymity => false;

  @override
  void setAnonymity(bool on, {bool permanent = false}) {}

  @override
  Color? vipNameColor(ThemeData theme) => null;
}

/// 「我的」页消息入口徽章:登录态监听 + getNewMessageNum 未读数,
/// 样式对齐 home 页 msgBadge(数字 >99 显示 99+)。
class _MineMsgBadge extends StatefulWidget {
  const _MineMsgBadge();

  @override
  State<_MineMsgBadge> createState() => _MineMsgBadgeState();
}

class _MineMsgBadgeState extends State<_MineMsgBadge> {
  int? _unread;

  @override
  void initState() {
    super.initState();
    _query();
    // 会话页打开/离开/选中会话后重查未读数(piliotto: 打开消息页即刷新)。
    MessagePage.unreadRefresh.addListener(_query);
  }

  @override
  void dispose() {
    MessagePage.unreadRefresh.removeListener(_query);
    super.dispose();
  }

  Future<void> _query() async {
    final res = await appRead(imRepositoryProvider).getTotalUnread();
    if (!mounted) return;
    if (res case Success(:final response)) {
      setState(() => _unread = response.totalUnread);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = appRead(accountProvider).isLogin;
    if (!isLogin) return const SizedBox.shrink();
    final count = _unread ?? 0;
    return IconButton(
      tooltip: '消息',
      onPressed: () => AppNavigator.toNamed('/whisper'),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        alignment: const Alignment(1.0, -0.85),
        child: const Icon(Icons.notifications_none),
      ),
    );
  }
}
