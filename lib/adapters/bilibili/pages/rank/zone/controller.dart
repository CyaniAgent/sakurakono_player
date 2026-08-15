import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/pages/common/common_list_controller.dart';

class ZoneController extends CommonListController {
  ZoneController({this.rid, this.seasonType});

  int? rid;
  int? seasonType;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<LoadingState> customGetData() async {
    final result = await (rid != null
        ? Get.find<VideoRepository>().getRankVideoList(rid!)
        : seasonType == 4 || seasonType == 5
            ? Get.find<VideoRepository>().pgcRankList(seasonType: seasonType!)
            : Get.find<VideoRepository>().pgcSeasonRankList(seasonType: seasonType!));
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
