import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:get/get.dart';
import 'package:skf/core/container/app_container.dart';

class ArticleListController
    extends CommonListControllerRiverpod<CoreArticleListData, CoreArticleListItemModel> {
  final id = Get.parameters['id']!;

  ArticleListController() {
    queryData();
  }

  CoreArticleListInfo? list;
  CoreOwner? author;

  @override
  List<CoreArticleListItemModel>? getDataList(CoreArticleListData response) {
    list = response.list;
    author = response.author;
    return response.articles;
  }

  @override
  Future<LoadingState<CoreArticleListData>> customGetData() async {
    final result = await (appRead(dynamicsRepositoryProvider)).articleList(id: id);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}