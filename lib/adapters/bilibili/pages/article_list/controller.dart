import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:get/get.dart';

class ArticleListController
    extends CommonListControllerRiverpod<CoreArticleListData, CoreArticleListItemModel> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
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
    final result = await (_ref!.read(dynamicsRepositoryProvider)).articleList(id: id);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}