import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:flutter/material.dart' show TabController;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class LiveAreaController extends CommonListController<List<CoreAreaList>?, CoreAreaList>
    with GetSingleTickerProviderStateMixin {
  late final isLogin = Accounts.main.isLogin;

  late final isEditing = false.obs;
  late final favInfo = {};

  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    if (isLogin) {
      queryFavTags();
    }
    queryData();
  }

  @override
  Future<void> onRefresh() {
    if (isLogin) {
      queryFavTags();
    }
    return super.onRefresh();
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<List<CoreAreaList>?> response) {
    assert(tabController == null);
    final length = response.response?.length;
    if (length != null && length != 0) {
      tabController = TabController(length: length, vsync: this);
    }
    return super.customHandleResponse(isRefresh, response);
  }

  Rx<LoadingState<List<CoreAreaItem>>> favState =
      LoadingState<List<CoreAreaItem>>.loading().obs;

  @override
  Future<LoadingState<List<CoreAreaList>?>> customGetData() async {
    final result = await Get.find<LiveRepository>().liveAreaList();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> queryFavTags() async {
    final biliResult = await Get.find<LiveRepository>().getLiveFavTag();
    favState.value = switch (biliResult) {
      Loading _ => LoadingState<List<CoreAreaItem>>.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> setFavTag() async {
    if (favState.value case Success(:final response)) {
      final biliResult = await Get.find<LiveRepository>().setLiveFavTag(
        ids: response.map((e) => e.id).join(','),
      );
      final res = switch (biliResult) {
        Loading _ => LoadingState.loading(),
        Success(:final response) => Success(response),
        Error(:final errMsg, :final code) => Error(errMsg, code: code),
      };
      if (res.isSuccess) {
        isEditing.toggle();
        SmartDialog.showToast('设置成功');
      } else {
        res.toast();
      }
    } else {
      isEditing.toggle();
    }
  }

  void onEdit() {
    if (isEditing.value) {
      setFavTag();
    } else {
      isEditing.toggle();
    }
  }

  @override
  void onClose() {
    tabController?.dispose();
    tabController = null;
    super.onClose();
  }
}
