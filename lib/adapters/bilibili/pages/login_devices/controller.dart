import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/auth_repository.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/auth_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:get/get.dart';

class CoreLoginDevicesController
    extends CommonListControllerRiverpod<CoreLoginDevicesData, CoreLoginDevice> {

  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  CoreLoginDevicesController() {
    queryData();
  }

  @override
  List<CoreLoginDevice>? getDataList(CoreLoginDevicesData response) {
    return response.devices;
  }

  @override
  Future<LoadingState<CoreLoginDevicesData>> customGetData() async {
    final result = await (_ref!.read(authRepositoryProvider)).loginDevices();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}