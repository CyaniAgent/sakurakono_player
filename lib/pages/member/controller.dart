import 'dart:math';

import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/pages/member/member_host.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/extension/nested_scroll_ext.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    show ExtendedNestedScrollViewState;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';

class MemberController extends CommonDataControllerRiverpod<CoreSpaceData, CoreSpaceData?>
    implements TickerProvider {
  MemberController({required this.mid}) {
    queryData();
  }

  final List<Ticker> _tickers = [];
  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = Ticker(onTick);
    _tickers.add(ticker);
    return ticker;
  }
  int mid;
  String? username;
  String? userAvatar;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  int get currentUserId => MemberHost.of().currentUserId;

  bool get isLogin => appRead(accountProvider).isLogin;

  CoreLive? live;
  int? silence;

  int? isFollowed; // 被关注
  int _relation = 0;
  bool get isFollow {
    final relation = _relation;
    return relation != 0 && relation != 128 && relation != -1;
  }
  int get relation => _relation;
  set relation(int value) {
    _relation = value;
    notifyListeners();
  }

  CoreSpaceSetting? spaceSetting;
  List<CoreSpaceTab2>? tab2;
  late List<Tab> tabs;
  TabController? tabController;
  int _contributeInitialIndex = 0;
  int get contributeInitialIndex => _contributeInitialIndex;
  set contributeInitialIndex(int value) {
    _contributeInitialIndex = value;
    notifyListeners();
  }

  bool? hasSeasonOrSeries;

  List<dynamic>? charges;
  int? chargeCount;
  bool get hasCharge => chargeCount != null && chargeCount! > 0;

  List<CoreSpaceGuardItem>? guards;
  Object? guardCount;
  bool get hasGuard => guards?.isNotEmpty ?? false;

  List<CoreReservationCardItem>? reserves;

  final fromViewAid = int.tryParse(Get.parameters['from_view_aid'] ?? '');

  final scrollKey = GlobalKey<ExtendedNestedScrollViewState>();


  @override
  bool customHandleResponse(bool isRefresh, Success<CoreSpaceData> response) {
    final data = response.response;
    final card = data.coreCard;
    username = card?.name ?? '';
    userAvatar = card?.face;

    isFollowed = card?.relation?.isFollowed;

    // charge
    final elec = data.coreElec;
    charges = elec?.list;
    chargeCount = elec?.total;
    // guard
    final guard = data.coreGuard;
    guards = guard?.item;
    guardCount = guard?.count;

    reserves = data.reservationCardList;

    switch (data.relation) {
      case -1:
        _relation = 128;
      case -999:
        if (data.guestRelation == -1) {
          _relation = -1;
        }
      default:
        _relation = card?.relation?.isFollow == 1
            ? data.relSpecial == 1
                  ? -10
                  : card?.relation?.status ?? 2
            : data.relation ?? 0;
    }
    tab2 = data.tab2;
    live = data.coreLive;
    silence = card?.silence;
    if ((data.coreUgcSeason?.count != null && data.coreUgcSeason?.count != 0) ||
        data.series?.item?.isNotEmpty == true) {
      hasSeasonOrSeries = true;
    }
    if (tab2 != null) {
      tab2 = MemberHost.of().filterTabs(tab2!);
    }
    if (tab2?.isNotEmpty == true) {
      if (data.hasItem != true && tab2!.first.param == 'home') {
        // remove empty home tab
        tab2!.removeAt(0);
      }
      if (tab2!.isNotEmpty) {
        int initialIndex = -1;
        final preferredTabParam = MemberHost.of().preferredTabParam;
        if (preferredTabParam != null) {
          initialIndex = tab2!.indexWhere((item) {
            return item.param == preferredTabParam;
          });
        }
        if (initialIndex == -1) {
          if (data.defaultTab == 'video') {
            data.defaultTab = 'contribute';
          }
          initialIndex = tab2!.indexWhere((item) {
            return item.param == data.defaultTab;
          });
        }
        tabs = tab2!.map((item) => Tab(text: item.title ?? '')).toList();
        tabController?.dispose();
        tabController = TabController(
          vsync: this,
          length: tabs.length,
          initialIndex: max(0, initialIndex),
        );
      }
    }
    if (mid == currentUserId) {
      spaceSetting = data.setting;
    }
    loadingState = response;
    return true;
  }

  @override
  bool handleError(String? errMsg) {
    tab2 = [
      CoreSpaceTab2(title: '动态', param: 'dynamic'),
      CoreSpaceTab2(
        title: '投稿',
        param: 'contribute',
        items: [{'title': '视频', 'param': 'video'}],
      ),
      CoreSpaceTab2(title: '收藏', param: 'favorite'),
      CoreSpaceTab2(title: '追番', param: 'bangumi'),
    ];
    tabs = tab2!.map((item) => Tab(text: item.title)).toList();
    tabController?.dispose();
    tabController = TabController(
      vsync: this,
      length: tabs.length,
    );
    username = errMsg;
    loadingState = const Success(null);
    return true;
  }

  @override
  Future<LoadingState<CoreSpaceData>> customGetData() async {
    final result = await (appRead(memberRepositoryProvider)).space(
      mid: mid,
      fromViewAid: fromViewAid,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  void blockUser(BuildContext context) {
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(relation != 128 ? '确定拉黑UP主?' : '从黑名单移除UP主'),
        actions: [
          TextButton(
            onPressed: AppNavigator.back,
            child: Text(
              '点错了',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () {
              AppNavigator.back();
              _onBlock();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void shareUser() {
    MemberHost.of().shareUser(mid);
  }

  Future<void> _onBlock() async {
    final isBlocked = relation == 128;
    final res = await (appRead(videoRepositoryProvider)).relationMod(
      mid: mid,
      act: isBlocked ? 6 : 5,
      reSrc: 11,
    );
    if (res.isSuccess) {
      relation = isBlocked ? 0 : 128;
    }
  }

  void onFollow(BuildContext context) {
    if (mid == currentUserId) {
      AppNavigator.toNamed('/editProfile');
    } else if (relation == 128) {
      _onBlock();
    } else {
      if (!isLogin) {
        SmartDialog.showToast('账号未登录');
        return;
      }
      MemberHost.of().actionRelationMod(
        context,
        mid: mid,
        isFollow: isFollow,
        afterMod: (attribute) => relation = attribute,
      );
    }
  }

  @override
  void dispose() {
    tabController?.dispose();
    for (final ticker in _tickers) {
      if (ticker.isActive) ticker.dispose();
    }
    super.dispose();
  }

  Future<void> onRemoveFan() async {
    final res = await (appRead(videoRepositoryProvider)).relationMod(mid: mid, act: 7, reSrc: 11);
    if (res.isSuccess) {
      isFollowed = null;
      if (relation == 4) {
        relation = 2;
      }
      SmartDialog.showToast('移除成功');
    } else {
      res.toast();
    }
  }

  void onTapTab(int value) {
    if (tabController?.indexIsChanging == false) {
      scrollKey.currentState?.animToTop();
    }
  }

  Future<void> vipExpAdd() async {
    final res = await (appRead(userRepositoryProvider)).vipExpAdd();
    if (res.isSuccess) {
      SmartDialog.showToast('领取成功');
    } else {
      res.toast();
    }
  }
}


/// 每用户页实例注册表 — member 页 view 创建 [MemberController] 后登记，
/// 子部件按 [heroTag] 经 [memberControllerProvider] 读取（替代 GetX tag 注册）。
/// [heroTag] 含随机数不可逆，故无法用 family 按 heroTag 构造（需要 mid）。
final Map<String, MemberController> memberControllerRegistry = {};

final memberControllerProvider = Provider.family<MemberController, String>(
  (ref, heroTag) => memberControllerRegistry[heroTag] ??
      (throw StateError('MemberController not registered for heroTag: $heroTag')),
);
