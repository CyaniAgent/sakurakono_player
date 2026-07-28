import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SelectTopicController
    extends CommonListController<CoreTopicPubSearchData, CoreTopicItem> {
  final focusNode = FocusNode();
  final controller = TextEditingController();

  final RxBool enableClear = false.obs;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreTopicItem>? getDataList(CoreTopicPubSearchData response) {
    if (response.pageInfo?.hasMore == false) {
      isEnd = true;
    }
    return response.topicItems;
  }

  @override
  Future<LoadingState<CoreTopicPubSearchData>> customGetData() async {
    final result = await Get.find<SearchRepository>().topicPubSearch(
      keywords: controller.text,
      pageNum: page,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void onClose() {
    focusNode.dispose();
    controller.dispose();
    super.onClose();
  }
}