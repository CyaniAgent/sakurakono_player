import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:skf/core/repository/repository_providers.dart';

class DynReactController
    extends CommonListController<CoreDynReactionData, CoreDynReactionItem> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  DynReactController(this.id, {int count = -1}) : count = RxInt(count);
  final String id;

  String? _offset;
  final RxInt count;

  @override
  List<CoreDynReactionItem>? getDataList(CoreDynReactionData response) {
    _offset = response.offset;
    if (response.hasMore != true) {
      isEnd = true;
    }
    return response.items;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<CoreDynReactionData> response) {
    if (isRefresh) {
      final res = response.response;
      final total = res.total;
      if (!(total == 0 && res.items?.isNotEmpty == true)) {
        count.value = total;
      }
    }
    return false;
  }

  @override
  Future<LoadingState<CoreDynReactionData>> customGetData() async {
    final result = await (_ref?.read(dynamicsRepositoryProvider) ?? Get.find<DynamicsRepository>()).dynReaction(id: id, offset: _offset);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  Future<void> onRefresh() {
    _offset = null;
    return super.onRefresh();
  }
}