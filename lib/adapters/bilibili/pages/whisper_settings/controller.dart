import 'package:skf/adapters/bilibili/grpc/bilibili/app/im/v1.pb.dart'
    show GetImSettingsReply, IMSettingType, Setting;
import 'package:skf/adapters/bilibili/grpc/im.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:protobuf/protobuf.dart' show PbMap;

class WhisperSettingsController
    extends CommonControllerRiverpod<GetImSettingsReply, PbMap<int, Setting>> {
  WhisperSettingsController({
    required this.imSettingType,
  }) {
    queryData();
  }

  final IMSettingType imSettingType;

  String title = '';
  LoadingState<PbMap<int, Setting>> _loadingState =
      LoadingState<PbMap<int, Setting>>.loading();
  @override
  LoadingState<PbMap<int, Setting>> get loadingState => _loadingState;
  set loadingState(LoadingState<PbMap<int, Setting>> value) {
    _loadingState = value;
    notifyListeners();
  }

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<GetImSettingsReply> response,
  ) {
    title = response.response.pageTitle;
    loadingState = Success(response.response.settings);
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

  @override
  Future<void> queryData([bool isRefresh = true]) async {
    if (isLoading) return;
    isLoading = true;
    final LoadingState<GetImSettingsReply> res = await customGetData();
    if (res is Success<GetImSettingsReply>) {
      if (!customHandleResponse(isRefresh, res)) {
        loadingState = Success(res.response.settings);
      }
    } else {
      if (isRefresh && !handleError(res is Error ? res.errMsg : null)) {
        loadingState = res as Error;
      }
    }
    isLoading = false;
  }

  @override
  Future<void> onReload() {
    loadingState = LoadingState<PbMap<int, Setting>>.loading();
    return super.onReload();
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