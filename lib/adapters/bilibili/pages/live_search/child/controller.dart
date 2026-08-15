import 'package:skf/core/repository/live_repository.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/live_enums.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/adapters/bilibili/pages/live_search/controller.dart';

class LiveSearchChildController
    extends CommonListController<CoreLiveSearchData, dynamic> {
  LiveSearchChildController(this.controller, this.searchType);

  final LiveSearchController controller;
  final CoreLiveSearchType searchType;

  @override
  void checkIsEnd(int length) {
    switch (searchType) {
      case CoreLiveSearchType.room:
        if (controller.counts.first != -1 &&
            length >= controller.counts.first) {
          isEnd = true;
        }
        break;
      case CoreLiveSearchType.user:
        if (controller.counts[1] != -1 && length >= controller.counts[1]) {
          isEnd = true;
        }
        break;
    }
  }

  @override
  List? getDataList(response) {
    switch (searchType) {
      case CoreLiveSearchType.room:
        controller.counts[searchType.index] = response.room?.totalRoom ?? 0;
        return response.room?.list;
      case CoreLiveSearchType.user:
        controller.counts[searchType.index] = response.user?.totalUser ?? 0;
        return response.user?.list;
    }
  }

  @override
  Future<LoadingState<CoreLiveSearchData>> customGetData() async {
    final result = await Get.find<LiveRepository>().liveSearch(
      page: page,
      keyword: controller.editingController.text,
      type: searchType,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
