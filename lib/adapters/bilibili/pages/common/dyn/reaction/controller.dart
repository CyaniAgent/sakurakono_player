import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';

class DynReactController
    extends CommonListControllerRiverpod<CoreDynReactionData, CoreDynReactionItem> {
  DynReactController(this.id, {int count = -1}) : _count = count;
  final String id;

  int _count;
  int get count => _count;
  set count(int value) {
    _count = value;
    notifyListeners();
  }

  String? _offset;
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
        count = total;
      }
    }
    return false;
  }

  @override
  Future<LoadingState<CoreDynReactionData>> customGetData() async {
    final result = await (appRead(dynamicsRepositoryProvider)).dynReaction(id: id, offset: _offset);
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