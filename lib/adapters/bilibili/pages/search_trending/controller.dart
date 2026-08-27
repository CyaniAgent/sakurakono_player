import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';

class SearchTrendingController
    extends CommonListControllerRiverpod<CoreSearchTrendingData, CoreSearchTrendingItemModel> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
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
    final result = await (_ref!.read(searchRepositoryProvider)).searchTrending(needsTop: true);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
