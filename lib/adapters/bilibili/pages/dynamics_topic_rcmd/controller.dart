import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';

class DynTopicRcmdController
    extends CommonListController<List<CoreTopicItem>?, CoreTopicItem> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<LoadingState<List<CoreTopicItem>?>> customGetData() async {
    final result = await (_ref?.read(dynamicsRepositoryProvider) ?? Get.find<DynamicsRepository>()).dynTopicRcmd();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}