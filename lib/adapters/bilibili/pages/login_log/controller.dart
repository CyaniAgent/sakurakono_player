import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/adapters/bilibili/pages/log_table/controller.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';

class LoginLogController extends LogController<CoreLoginLogData, CoreLoginLogItem> {
  @override
  List<CoreLoginLogItem>? getDataList(CoreLoginLogData response) {
    return response.list;
  }

  @override
  Future<LoadingState<CoreLoginLogData>> customGetData() async {
    final result = await (appRead(userRepositoryProvider)).loginLog();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  List<(int, String)> getFlexAndText(CoreLoginLogItem item) {
    return [(3, item.timeAt), (2, item.ip), (3, item.geo)];
  }

  @override
  final CoreLoginLogItem header = const CoreLoginLogItem(
    timeAt: '时间',
    ip: '变化',
    geo: '地理位置',
  );

  @override
  final String title = '登录记录';
}