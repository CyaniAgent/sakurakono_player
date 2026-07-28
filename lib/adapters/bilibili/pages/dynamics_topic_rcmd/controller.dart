import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';

class DynTopicRcmdController
    extends CommonListController<List<CoreTopicItem>?, CoreTopicItem> {
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<LoadingState<List<CoreTopicItem>?>> customGetData() async {
    final result = await Get.find<DynamicsRepository>().dynTopicRcmd();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}