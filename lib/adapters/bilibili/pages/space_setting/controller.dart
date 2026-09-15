import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpaceSettingController
    extends CommonDataControllerRiverpod<CoreSpaceSettingData, CorePrivacy?> {

  SpaceSettingController() {
    queryData();
  }

  bool? hasMod;

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<CoreSpaceSettingData> response,
  ) {
    loadingState = Success(response.response.privacy);
    return true;
  }

  @override
  Future<LoadingState<CoreSpaceSettingData>> customGetData() async {
    final result = await (appRead(userRepositoryProvider)).spaceSetting();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onMod() async {
    if (hasMod ?? false) {
      if (loadingState case Success(:final response?)) {
        final res = await (appRead(userRepositoryProvider)).spaceSettingMod(
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

/// SpaceSettingController（单实例）。
final spaceSettingControllerProvider = Provider<SpaceSettingController>((ref) => SpaceSettingController());
