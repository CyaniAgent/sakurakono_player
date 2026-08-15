import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/pages/common/common_data_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class SpaceSettingController
    extends CommonDataController<CoreSpaceSettingData, CorePrivacy?> {
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  bool? hasMod;

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<CoreSpaceSettingData> response,
  ) {
    loadingState.value = Success(response.response.privacy);
    return true;
  }

  @override
  Future<LoadingState<CoreSpaceSettingData>> customGetData() async {
    final result = await Get.find<UserRepository>().spaceSetting();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onMod() async {
    if (hasMod ?? false) {
      if (loadingState.value case Success(:final response?)) {
        final res = await Get.find<UserRepository>().spaceSettingMod(
          {
            for (final e in response.list1) e.key: e.value,
            for (final e in response.list2) e.key: e.value,
            for (final e in response.list3) e.key: e.value,
          },
        );
        if (!res.isSuccess) {
          SmartDialog.showToast(res.toString());
        }
      }
    }
  }
}
