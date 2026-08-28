import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class DynTopicRcmdController
    extends CommonListControllerRiverpod<List<CoreTopicItem>?, CoreTopicItem> {
  void attachRef(Ref ref) {}
  DynTopicRcmdController() {
    queryData();
  }

  @override
  Future<LoadingState<List<CoreTopicItem>?>> customGetData() async {
    final result = await (appRead(dynamicsRepositoryProvider)).dynTopicRcmd();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}