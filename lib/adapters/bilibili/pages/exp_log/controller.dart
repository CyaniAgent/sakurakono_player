import 'package:skf/core/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/adapters/bilibili/pages/log_table/controller.dart';
import 'package:get/get.dart';

class ExpLogController extends LogController<CoreCoinLogData, CoreCoinLogItem> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  @override
  List<CoreCoinLogItem>? getDataList(CoreCoinLogData response) {
    return response.list;
  }

  @override
  Future<LoadingState<CoreCoinLogData>> customGetData() async {
    final result = await (_ref?.read(userRepositoryProvider) ?? Get.find<UserRepository>()).expLog();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  List<(int, String)> getFlexAndText(CoreCoinLogItem item) {
    return [(2, item.time), (1, item.delta), (2, item.reason)];
  }

  @override
  final CoreCoinLogItem header = const CoreCoinLogItem(
    time: '时间',
    delta: '变化',
    reason: '原因',
  );

  @override
  final String title = '经验记录';
}
