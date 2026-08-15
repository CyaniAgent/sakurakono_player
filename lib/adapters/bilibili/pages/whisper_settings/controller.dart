import 'package:skf/adapters/bilibili/grpc/bilibili/app/im/v1.pb.dart'
    show GetImSettingsReply, IMSettingType, Setting;
import 'package:skf/adapters/bilibili/grpc/im.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/pages/common/common_data_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:protobuf/protobuf.dart' show PbMap;

class WhisperSettingsController
    extends CommonDataController<GetImSettingsReply, PbMap<int, Setting>> {
  WhisperSettingsController({
    required this.imSettingType,
  });

  final IMSettingType imSettingType;

  final RxString title = ''.obs;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<GetImSettingsReply> response,
  ) {
    title.value = response.response.pageTitle;
    loadingState.value = Success(response.response.settings);
    return true;
  }

  @override
  Future<LoadingState<GetImSettingsReply>> customGetData() async {
    final result = await ImGrpc.getImSettings(type: imSettingType);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<bool> onSet(Map<int, Setting> settings) async {
    final res = await ImGrpc.setImSettings(settings: settings);
    if (!res.isSuccess) {
      SmartDialog.showToast(res.toString());
      return false;
    }
    return true;
  }
}