import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/pages/common/common_list_controller.dart';

class SearchTrendingController
    extends CommonListController<CoreSearchTrendingData, CoreSearchTrendingItemModel> {
  int topCount = 0;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreSearchTrendingItemModel>? getDataList(CoreSearchTrendingData response) {
    topCount = response.topCount;
    return response.list;
  }

  @override
  Future<LoadingState<CoreSearchTrendingData>> customGetData() async {
    final result = await Get.find<SearchRepository>().searchTrending(needsTop: true);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
