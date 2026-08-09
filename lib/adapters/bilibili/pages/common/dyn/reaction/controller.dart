import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class DynReactController
    extends CommonListController<CoreDynReactionData, CoreDynReactionItem> {
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
    final result = await Get.find<DynamicsRepository>().dynReaction(id: id, offset: _offset);
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