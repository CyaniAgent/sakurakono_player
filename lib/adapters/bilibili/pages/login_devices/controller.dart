import 'package:skf/core/result/loading_state.dart';

import 'package:skf/adapters/bilibili/http/login.dart';
import 'package:skf/core/models/auth_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';

class CoreLoginDevicesController
    extends CommonListController<CoreLoginDevicesData, CoreLoginDevice> {
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreLoginDevice>? getDataList(CoreLoginDevicesData response) {
    return response.devices;
  }

  @override
  Future<LoadingState<CoreLoginDevicesData>> customGetData() async {
    final result = await LoginHttp.loginDevices();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response as dynamic),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}