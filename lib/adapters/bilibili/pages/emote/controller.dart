import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/http/reply.dart';
import 'package:skf/adapters/bilibili/models_new/emote/package.dart'; // ignore: adapter import (no core equivalent for Package)
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:flutter/material.dart';

class EmotePanelController extends CommonListController<List<Package>?, Package>
    with GetSingleTickerProviderStateMixin {
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
    final result = await ReplyHttp.getEmoteList(business: 'reply');
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
