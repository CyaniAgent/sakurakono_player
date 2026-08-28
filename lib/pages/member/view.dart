import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';
import 'dart:math' as math;

import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/dynamic_sliver_app_bar/dynamic_sliver_app_bar.dart';
import 'package:skf/common/widgets/gesture/tap_gesture_recognizer.dart';
import 'package:skf/common/widgets/loading_widget/loading_widget.dart';
import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/member/controller.dart';
import 'package:skf/pages/member/member_host.dart';
import 'package:skf/pages/member/widget/reserve_button.dart';
import 'package:skf/pages/member/widget/user_info_card.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/date_utils.dart';
import 'package:skf/utils/extension/context_ext.dart';
import 'package:skf/utils/num_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/utils.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  late final int _mid;
  late final String _heroTag;
  late final MemberController _userController;
  PageController? _headerController;
  PageController getHeaderController() =>
      _headerController ??= PageController();
  @override
  void initState() {
    super.initState();
    _mid = int.tryParse(AppNavigator.parametersOf(context)['mid']!) ?? -1;
    _heroTag = Utils.makeHeroTag(_mid);
    _userController = MemberController(mid: _mid);
    memberControllerRegistry[_heroTag] = _userController;
  }

  @override
  void dispose() {
    memberControllerRegistry.remove(_heroTag);
    _headerController?.dispose();
    _headerController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final padding = MediaQuery.viewPaddingOf(context);
    return Material(
      color: theme.surface,
      child: ListenableBuilder(
        listenable: _userController,
        builder: (_, _) => switch (_userController.loadingState) {
          Loading() => m3eLoading,
          Success(:final response) => ExtendedNestedScrollView(
            key: _userController.scrollKey,
            onlyOneScrollInBody: true,
            pinnedHeaderSliverHeightBuilder: () =>
                kToolbarHeight + MediaQuery.viewPaddingOf(context).top,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              if (response != null) {
                return [
                  DynamicSliverAppBar.medium(
                    actions: _actions(theme),
                    title: Text(_userController.username ?? ''),
                    flexibleSpace: UserInfoCard(
                      isOwner:
                          _userController.mid == _userController.currentUserId,
                      relation: _userController.relation,
                      card: response.coreCard!,
                      images: response.images!,
                      onFollow: () => _userController.onFollow(context),
                      live: _userController.live,
                      silence: _userController.silence,
                      headerControllerBuilder: getHeaderController,
                      showLiveMedalWall: _showLiveMedalWall,
                      charges: _userController.charges,
                      chargeCount: _userController.chargeCount,
                      guards: _userController.guards,
                      guardCount: _userController.guardCount,
                    ),
                  ),
                ];
              }
              return [
                SliverAppBar(
                  pinned: true,
                  actions: _actions(theme),
                  title: GestureDetector(
                    onTap: _userController.onReload,
                    behavior: HitTestBehavior.opaque,
                    child: Text(_userController.username ?? ''),
                  ),
                ),
              ];
            },
            body: _userController.tab2?.isNotEmpty == true
                ? Padding(
                    padding: .only(left: padding.left, right: padding.right),
                    child: Column(
                      children: [
                        if ((_userController.tab2?.length ?? 0) > 1)
                          SizedBox(
                            height: 45,
                            child: TabBar(
                              controller: _userController.tabController,
                              tabs: _userController.tabs,
                              onTap: _userController.onTapTab,
                              dividerColor: theme.outline.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        Expanded(child: _buildBody),
                      ],
                    ),
                  )
                : scrollableError,
          ),
          Error(:final errMsg) => scrollErrorWidget(
            errMsg: errMsg,
            onReload: _userController.onReload,
          ),
        },
      ),
    );
  }

  Widget _reserveBtn(List<CoreReservationCardItem> list, ColorScheme theme) {
    return IconButton(
      tooltip: '预约',
      onPressed: () => _showReserveList(list),
      icon: ReserveButton(
        count: list.length,
        color: theme.onSurfaceVariant,
        child: const Icon(Icons.notifications_none),
      ),
    );
  }

  void _showReserveList(List<CoreReservationCardItem> list) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: math.min(640, context.mediaQueryShortestSide),
      ),
      builder: (context) {
        final scheme = ColorScheme.of(context);
        return Padding(
          padding: .only(bottom: MediaQuery.viewPaddingOf(context).bottom + 30),
          child: Column(
            mainAxisSize: .min,
            children: [
              InkWell(
                onTap: AppNavigator.back,
                borderRadius: Style.bottomSheetRadius,
                child: SizedBox(
                  height: 35,
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: scheme.outline,
                        borderRadius: const .all(.circular(1.5)),
                      ),
                    ),
                  ),
                ),
              ),
              ...list.map((e) {
                return Builder(
                  builder: (context) {
                    Widget trailing = FilledButton.tonal(
                      onPressed: () async {
                        final isFollow = e.isFollow ?? false;
                        final res = await appRead(userRepositoryProvider).spaceReserve(
                          sid: e.sid!.toString(),
                          isFollow: isFollow,
                        );
                        if (res.isSuccess) {
                          e
                            ..total = (e.total ?? 0) + (isFollow ? -1 : 1)
                            ..isFollow = !isFollow;
                          if (!context.mounted) return;
                          (context as Element).markNeedsBuild();
                        } else {
                          res.toast();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: e.isFollow == true
                            ? scheme.onInverseSurface
                            : null,
                        foregroundColor: e.isFollow == true ? scheme.outline : null,
                        tapTargetSize: .shrinkWrap,
                        minimumSize: const Size(68, 40),
                        padding: const .symmetric(horizontal: 10),
                        visualDensity: const .new(horizontal: -2, vertical: -3),
                        shape: const RoundedRectangleBorder(
                          borderRadius: .all(.circular(6)),
                        ),
                      ),
                      child: Text(
                        '${e.isFollow == true ? '已' : ''}预约',
                      ),
                    );
                    if (e.dynamicId?.isNotEmpty ?? false) {
                      trailing = Row(
                        spacing: 8,
                        mainAxisSize: .min,
                        children: [
                          iconButton(
                            tooltip: '预约动态',
                            size: 32,
                            iconSize: 20,
                            iconColor: scheme.outline,
                            icon: const Icon(Icons.open_in_browser),
                            onPressed: () => MemberHost.of().pushDynFromId(
                              e.dynamicId,
                            ),
                          ),
                          trailing,
                        ],
                      );
                    }
                    return ListTile(
                      dense: true,
                      title: Text(
                        e.name!,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Padding(
                        padding: const .only(top: 2.0),
                        child: Text.rich(
                          style: TextStyle(fontSize: 12, color: scheme.outline),
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${e.descText1 == null ? '' : '${e.descText1}  '}'
                                    '${NumUtils.numFormat(e.total)}人预约',
                              ),
                              if (e.lotteryPrizeInfo case final lottery?) ...[
                                const TextSpan(text: '\n'),
                                WidgetSpan(
                                  alignment: .middle,
                                  child: Icon(
                                    size: 15,
                                    Icons.card_giftcard,
                                    color: scheme.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${lottery.text}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.primary,
                                  ),
                                  recognizer:
                                      lottery.jumpUrl?.isNotEmpty == true
                                      ? (NoDeadlineTapGestureRecognizer()
                                          ..onTap = () => AppNavigator.toNamed(
                                            '/webview',
                                            parameters: {
                                              'url': lottery.jumpUrl!,
                                            },
                                          ))
                                      : null,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      trailing: trailing,
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _actions(ColorScheme theme) => [
      _reserveBtn(
        _userController.reserves ?? <CoreReservationCardItem>[],
        theme,
      ),
    IconButton(
      tooltip: '搜索',
      onPressed: () => AppNavigator.toNamed(
        '/memberSearch?mid=$_mid&uname=${_userController.username}',
      ),
      icon: const Icon(Icons.search_outlined),
    ),
    PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => <PopupMenuEntry>[
        if (_userController.isLogin &&
            _userController.currentUserId != _mid) ...[
          PopupMenuItem(
            onTap: () => _userController.blockUser(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 19),
                const SizedBox(width: 10),
                Text(
                  _userController.relation != 128 ? '加入黑名单' : '移除黑名单',
                ),
              ],
            ),
          ),
          if (_userController.isFollowed == 1)
            PopupMenuItem(
              onTap: _userController.onRemoveFan,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_circle_outline_outlined, size: 19),
                  SizedBox(width: 10),
                  Text('移除粉丝'),
                ],
              ),
            ),
        ],
        PopupMenuItem(
          onTap: _userController.shareUser,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.share_outlined, size: 19),
              const SizedBox(width: 10),
              Text(
                _userController.currentUserId != _mid ? '分享UP主' : '分享我的主页',
              ),
            ],
          ),
        ),
        if (PlatformUtils.isMobile)
          PopupMenuItem(
            onTap: () => MemberHost.of().createShortcut(
              mid: _mid,
              name: _userController.username ?? '',
              avatar: _userController.userAvatar ?? '',
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_box_outlined, size: 19),
                SizedBox(width: 10),
                Text('添加至桌面'),
              ],
            ),
          ),
        // if (_userController.hasCharge)
        //   PopupMenuItem(
        //     onTap: () => UpowerRankPage.toUpowerRank(
        //       mid: _userController.mid,
        //       name: _userController.username ?? '',
        //       count: _userController.chargeCount,
        //     ),
        //     child: const Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Icon(Icons.electric_bolt, size: 19),
        //         SizedBox(width: 10),
        //         Text('充电排行榜'),
        //       ],
        //     ),
        //   ),
        // if (_userController.hasGuard)
        //   PopupMenuItem(
        //     onTap: () => MemberGuard.toMemberGuard(
        //       mid: _userController.mid,
        //       name: _userController.username ?? '',
        //       count: _userController.guardCount,
        //     ),
        //     child: const Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Icon(Icons.anchor, size: 19),
        //         SizedBox(width: 10),
        //         Text('大航海舰队'),
        //       ],
        //     ),
        //   ),
        if (MemberHost.of().canToWebArchive(_heroTag))
          PopupMenuItem(
            onTap: () => MemberHost.of().toWebArchive(
              heroTag: _heroTag,
              mid: _mid,
              username: _userController.username ?? '',
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.extension_outlined, size: 19),
                SizedBox(width: 10),
                Text('网页投稿'),
              ],
            ),
          ),
        if (_userController.isLogin)
          if (_userController.mid == _userController.currentUserId) ...[
            if ((_userController.loadingState.dataOrNull?.coreCard?.vip
                    ?.status ??
                0) >
                0)
              PopupMenuItem(
                onTap: _userController.vipExpAdd,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upcoming_outlined, size: 19),
                    SizedBox(width: 10),
                    Text('大会员经验'),
                  ],
                ),
              ),
            PopupMenuItem(
              onTap: () => MemberHost.of().openLoginDevices(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.devices, size: 18),
                  SizedBox(width: 10),
                  Text('登录设备'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => MemberHost.of().openLoginLog(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login, size: 18),
                  SizedBox(width: 10),
                  Text('登录记录'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => MemberHost.of().openCoinLog(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.b, size: 16),
                  SizedBox(width: 10),
                  Text('硬币记录'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => MemberHost.of().openExpLog(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.linear_scale, size: 18),
                  SizedBox(width: 10),
                  Text('经验记录'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => AppNavigator.toNamed('/spaceSetting'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings_outlined, size: 19),
                  SizedBox(width: 10),
                  Text('空间设置'),
                ],
              ),
            ),
          ] else ...[
            if (_userController.isFollow)
              PopupMenuItem(
                onTap: _showFollowTime,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.more_time_outlined, size: 19),
                    SizedBox(width: 10),
                    Text('关注时间'),
                  ],
                ),
              ),
            const PopupMenuDivider(),
            PopupMenuItem(
              onTap: () => MemberHost.of().showReportDialog(
                context,
                name: _userController.username,
                mid: _mid,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 19,
                    color: theme.error,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '举报',
                    style: TextStyle(color: theme.error),
                  ),
                ],
              ),
            ),
          ],
      ],
    ),
    const SizedBox(width: 4),
  ];

  Widget get _buildBody => tabBarView(
    controller: _userController.tabController,
    children: _userController.tab2!.map((item) {
      return MemberHost.of().buildTab(
        param: item.param!,
        title: item.title,
        heroTag: _heroTag,
        mid: _mid,
        contributeInitialIndex: _userController.contributeInitialIndex,
      );
    }).toList(),
  );

  String? _cacheFollowTime;
  Future<void> _showFollowTime() async {
    void onShow() {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_userController.username ?? ''),
          content: Text(_cacheFollowTime!),
          actions: [
            TextButton(
              onPressed: AppNavigator.back,
              child: Text(
                '关闭',
                style: TextStyle(color: ColorScheme.of(context).outline),
              ),
            ),
          ],
        ),
      );
    }

    if (_cacheFollowTime != null) {
      onShow();
      return;
    }
    final res = await appRead(userRepositoryProvider).userRelation(_mid);
    if (res case Success(:final response)) {
      if (response.mtime == null) return;
      _cacheFollowTime =
          '关注时间: ${DateFormatUtils.longFormatDs.format(
            DateTime.fromMillisecondsSinceEpoch(response.mtime! * 1000),
          )}';
      onShow();
    } else {
      res.toast();
    }
  }

  Future<void> _showLiveMedalWall() =>
      MemberHost.of().showLiveMedalWall(_mid);




}
