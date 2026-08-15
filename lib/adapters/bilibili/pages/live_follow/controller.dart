import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/live_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class LiveFollowController
    extends CommonListController<CoreLiveFollowData, CoreLiveFollowItem> {
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  final count = RxnInt();

  @override
  void checkIsEnd(int length) {
    final count = this.count.value;
    if (count != null && length >= count) {
      isEnd = true;
    }
  }

  @override
  List<CoreLiveFollowItem>? getDataList(CoreLiveFollowData response) {
    count.value = response.liveCount;
    return response.list;
  }

  @override
  Future<LoadingState<CoreLiveFollowData>> customGetData() async {
    final result = await Get.find<LiveRepository>().liveFollow(page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
