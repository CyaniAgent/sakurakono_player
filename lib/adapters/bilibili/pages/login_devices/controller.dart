import 'package:get/get.dart';
import 'package:skf/core/repository/auth_repository.dart';

import 'package:skf/core/result/loading_state.dart';
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
    final result = await Get.find<AuthRepository>().loginDevices();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}