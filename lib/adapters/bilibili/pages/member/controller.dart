import 'dart:math';

import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models/common/member/tab_type.dart';
import 'package:skf/adapters/bilibili/pages/common/common_data_controller.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/extension/nested_scroll_ext.dart';
import 'package:skf/adapters/bilibili/utils/request_utils.dart';
import 'package:skf/utils/share_utils.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    show ExtendedNestedScrollViewState;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class MemberController extends CommonDataController<CoreSpaceData, CoreSpaceData?>
    with GetTickerProviderStateMixin {
  MemberController({required this.mid});
  int mid;
  String? username;
  String? userAvatar;

  late final account = Accounts.main;

  CoreLive? live;
  int? silence;

  int? isFollowed; // 被关注
  RxInt relation = 0.obs;
  bool get isFollow {
    final relation = this.relation.value;
    return relation != 0 && relation != 128 && relation != -1;
  }

  CoreSpaceSetting? spaceSetting;
  List<CoreSpaceTab2>? tab2;
  late List<Tab> tabs;
  TabController? tabController;
  RxInt contributeInitialIndex = 0.obs;

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
  void onInit() {
    super.onInit();
    queryData();
  }

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
        relation.value = 128;
      case -999:
        if (data.guestRelation == -1) {
          relation.value = -1;
        }
      default:
        relation.value = card?.relation?.isFollow == 1
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
    tab2?.retainWhere((item) => MemberTabType.contains(item.param!));
    if (tab2?.isNotEmpty == true) {
      if (data.hasItem != true && tab2!.first.param == 'home') {
        // remove empty home tab
        tab2!.removeAt(0);
      }
      if (tab2!.isNotEmpty) {
        int initialIndex = -1;
        MemberTabType memberTab = Pref.memberTab;
        if (memberTab != MemberTabType.def) {
          initialIndex = tab2!.indexWhere((item) {
            return item.param == memberTab.name;
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
    if (mid == account.mid) {
      spaceSetting = data.setting;
    }
    loadingState.value = response;
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
    loadingState.value = const Success(null);
    return true;
  }

  @override
  Future<LoadingState<CoreSpaceData>> customGetData() async {
    final result = await Get.find<MemberRepository>().space(
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
    if (!account.isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(relation.value != 128 ? '确定拉黑UP主?' : '从黑名单移除UP主'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              '点错了',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _onBlock();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void shareUser() {
    ShareUtils.shareText('https://space.bilibili.com/$mid');
  }

  Future<void> _onBlock() async {
    final isBlocked = relation.value == 128;
    final res = await Get.find<VideoRepository>().relationMod(
      mid: mid,
      act: isBlocked ? 6 : 5,
      reSrc: 11,
    );
    if (res.isSuccess) {
      relation.value = isBlocked ? 0 : 128;
    }
  }

  void onFollow(BuildContext context) {
    if (mid == account.mid) {
      Get.toNamed('/editProfile');
    } else if (relation.value == 128) {
      _onBlock();
    } else {
      if (!account.isLogin) {
        SmartDialog.showToast('账号未登录');
        return;
      }
      RequestUtils.actionRelationMod(
        context: context,
        mid: mid,
        isFollow: isFollow,
        afterMod: (attribute) => relation.value = attribute,
      );
    }
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }

  Future<void> onRemoveFan() async {
    final res = await Get.find<VideoRepository>().relationMod(mid: mid, act: 7, reSrc: 11);
    if (res.isSuccess) {
      isFollowed = null;
      if (relation.value == 4) {
        relation.value = 2;
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
    final res = await Get.find<UserRepository>().vipExpAdd();
    if (res.isSuccess) {
      SmartDialog.showToast('领取成功');
    } else {
      res.toast();
    }
  }
}
