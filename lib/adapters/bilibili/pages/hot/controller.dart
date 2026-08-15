import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class HotController
    extends CommonListController<List<CoreHotVideoItemModel>, CoreHotVideoItemModel> {
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>>> customGetData() async {
    final result = await Get.find<VideoRepository>().hotVideoList(
      pn: page,
      ps: 20,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
