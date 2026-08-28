import 'package:skf/core/repository/repository_providers_batch2.dart';

import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/live_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class LiveFollowController
    extends CommonListControllerRiverpod<CoreLiveFollowData, CoreLiveFollowItem> {
  LiveFollowController() {
    queryData();
  }

  int? count;

  @override
  void checkIsEnd(int length) {
    final count = this.count;
    if (count != null && length >= count) {
      isEnd = true;
    }
  }

  @override
  List<CoreLiveFollowItem>? getDataList(CoreLiveFollowData response) {
    count = response.liveCount;
    return response.list;
  }

  @override
  Future<LoadingState<CoreLiveFollowData>> customGetData() async {
    final result = await (appRead(liveRepositoryProvider)).liveFollow(page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
