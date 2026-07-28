
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/adapters/bilibili/models/member/tags.dart'; // ignore: adapter import (no core equivalent for MemberTagItemModel)
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class FollowController extends GetxController with GetTickerProviderStateMixin {
  late final int mid;
  late final RxnString name;
  late final bool isOwner;

  late final Rx<LoadingState> followState = LoadingState.loading().obs;
  late final RxList<CoreMemberTagItemModel> tabs = <CoreMemberTagItemModel>[].obs;
  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    final Map? args = Get.arguments;
    final ownerMid = Accounts.main.mid;
    final int? mid = args?['mid'];
    this.mid = mid ?? ownerMid;
    isOwner = ownerMid == this.mid;
    if (isOwner) {
      queryFollowUpTags();
    } else {
      final String? name = args?['name'];
      this.name = RxnString(name);
      if (name == null) {
        _queryUserName();
      }
    }
  }

  Future<void> _queryUserName() async {
    final res = await Get.find<MemberRepository>().memberCardInfo(mid: mid);
    name.value = res.dataOrNull?.card?.name;
  }

  Future<void> queryFollowUpTags() async {
    final res = await Get.find<MemberRepository>().followUpTags();
    if (res case Success(:final response)) {
      tabs
        ..assign(CoreMemberTagItemModel(name: '全部关注'))
        ..addAll(response);
      onInitTab();
      followState.value = Success(tabs.hashCode);
    } else {
      followState.value = switch (res) {
        Error(:final errMsg, :final code) => Error(errMsg, code: code),
        _ => LoadingState.loading(),
      };
    }
  }

  void onInitTab() {
    int initialIndex = 0;
    if (tabController != null) {
      initialIndex = tabController!.index.clamp(0, tabs.length - 1);
      tabController!.dispose();
    }
    tabController = TabController(
      initialIndex: initialIndex,
      length: tabs.length,
      vsync: this,
    );
  }

  void onCreateFavTag(({int tagid, String tagName}) res) {
    if (isClosed) return;
    if (followState.value.isSuccess) {
      tabs.add(CoreMemberTagItemModel.fromCreate(res));
      onInitTab();
      followState.refresh();
    } else {
      followState.value = LoadingState.loading();
      queryFollowUpTags();
    }
  }

  Future<void> onUpdateTag(MemberTagItemModel item, String tagName) async {
    final res = await Get.find<MemberRepository>().updateFollowTag(item.tagid!, tagName);
    if (res.isSuccess) {
      item.name = tagName;
      tabs.refresh();
      SmartDialog.showToast('修改成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  Future<void> onDelTag(int index, int tagid) async {
    final res = await Get.find<MemberRepository>().delFollowTag(tagid);
    if (res.isSuccess) {
      tabs.removeAt(index);
      onInitTab();
      followState.refresh();
      SmartDialog.showToast('删除成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  @override
  void onClose() {
    tabController?.dispose();
    tabController = null;
    super.onClose();
  }
}
