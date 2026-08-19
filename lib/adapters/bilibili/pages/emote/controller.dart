import 'package:skf/core/repository/reply_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/models_new/emote/package.dart'; // ignore: adapter import (no core equivalent for Package)
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:flutter/material.dart';

class EmotePanelController extends CommonListController<List<Package>?, Package>
    with GetSingleTickerProviderStateMixin {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<List<Package>?> response) {
    if (response.response?.isNotEmpty == true) {
      tabController = TabController(
        length: response.response!.length,
        vsync: this,
      );
    }
    loadingState.value = response;
    return true;
  }

  @override
  Future<LoadingState<List<Package>?>> customGetData() async {
    final result = await (_ref?.read(replyRepositoryProvider) ?? Get.find<ReplyRepository>())
        .getEmoteList(business: 'reply');
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response as List<Package>?),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
