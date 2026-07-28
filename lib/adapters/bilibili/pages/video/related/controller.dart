import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class RelatedController
    extends CommonListController<List<CoreHotVideoItemModel>?, CoreHotVideoItemModel> {
  RelatedController({this.autoQuery = true});
  String bvid = Get.arguments['bvid'];
  final bool autoQuery;

  @override
  void onInit() {
    super.onInit();
    if (autoQuery) {
      queryData();
    }
  }

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>?>> customGetData() async {
    final result = await Get.find<VideoRepository>().relatedVideoList(bvid: bvid);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
