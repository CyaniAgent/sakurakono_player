import 'dart:math';

import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/repository/live_repository.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class LiveAreaChildController
    extends CommonListController<CoreLiveSecondData, CoreCardLiveItem> {
  LiveAreaChildController(this.areaId, this.parentAreaId);
  final dynamic areaId;
  final dynamic parentAreaId;

  int? count;

  String? sortType;

  // tag
  final RxInt tagIndex = 0.obs;
  List<CoreLiveSecondTag>? newTags;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  void checkIsEnd(int length) {
    if (count != null && length >= count!) {
      isEnd = true;
    }
  }

  @override
  List<CoreCardLiveItem>? getDataList(CoreLiveSecondData response) {
    count = response.count;
    newTags = response.newTags;
    tagIndex.value = max(
      0,
      newTags?.indexWhere((e) => e.sortType == sortType) ?? 0,
    );
    return response.cardList;
  }

  @override
  Future<LoadingState<CoreLiveSecondData>> customGetData() async {
    final result = await Get.find<LiveRepository>().liveSecondList(
        pn: page,
        areaId: areaId,
        parentAreaId: parentAreaId,
        sortType: sortType,
      );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  void onSelectTag(int index, String? sortType) {
    if (isLoading) {
      return;
    }
    tagIndex.value = index;
    this.sortType = sortType;

    onRefresh();
  }
}
