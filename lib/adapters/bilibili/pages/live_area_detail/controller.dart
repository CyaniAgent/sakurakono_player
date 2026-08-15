import 'dart:math';

import 'package:skf/core/repository/live_repository.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:flutter/material.dart' show TabController;
import 'package:get/get.dart';

class LiveAreaDetailController
    extends CommonListController<List<CoreAreaItem>?, CoreAreaItem>
    with GetSingleTickerProviderStateMixin {
  LiveAreaDetailController(this.areaId, this.parentAreaId);
  final dynamic areaId;
  final dynamic parentAreaId;

  TabController? tabController;

  bool showFirstFrame = false;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreAreaItem>? getDataList(List<CoreAreaItem>? response) {
    if (response != null && response.isNotEmpty) {
      assert(tabController == null);
      final initialIndex = max(0, response.indexWhere((e) => e.id == areaId));
      tabController = TabController(
        length: response.length,
        initialIndex: initialIndex,
        vsync: this,
      );
    }
    return response;
  }

  @override
  Future<LoadingState<List<CoreAreaItem>?>> customGetData() async {
    final result = await Get.find<LiveRepository>().liveRoomAreaList(parentid: parentAreaId);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void onClose() {
    tabController?.dispose();
    tabController = null;
    super.onClose();
  }
}
