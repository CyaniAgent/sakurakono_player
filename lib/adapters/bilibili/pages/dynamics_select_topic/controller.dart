import 'package:skf/core/models/search_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:skf/core/container/app_container.dart';

class SelectTopicController
    extends CommonListControllerRiverpod<CoreTopicPubSearchData, CoreTopicItem> {
  void attachRef(Ref ref) {}
  final focusNode = FocusNode();
  final controller = TextEditingController();

  bool enableClear = false;

  SelectTopicController() {
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
    final result = await (appRead(searchRepositoryProvider)).topicPubSearch(
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
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }
}