import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class SearchTrendingController
    extends CommonListControllerRiverpod<CoreSearchTrendingData, CoreSearchTrendingItemModel> {
  int topCount = 0;

  SearchTrendingController() {
    queryData();
  }

  @override
  List<CoreSearchTrendingItemModel>? getDataList(CoreSearchTrendingData response) {
    topCount = response.topCount;
    return response.list;
  }

  @override
  Future<LoadingState<CoreSearchTrendingData>> customGetData() async {
    final result = await (appRead(searchRepositoryProvider)).searchTrending(needsTop: true);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
