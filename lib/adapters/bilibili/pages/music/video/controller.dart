import 'package:skf/core/repository/music_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/music_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

typedef MusicRecommendArgs = ({String id, CoreMusicDetail item});

class MusicRecommendController
    extends CommonListController<List<CoreBgmRecommend>?, CoreBgmRecommend> {
  late final String musicId;
  late final CoreMusicDetail musicDetail;

  @override
  void onInit() {
    super.onInit();
    final MusicRecommendArgs args = Get.arguments;
    musicId = args.id;
    musicDetail = args.item;
    queryData();
  }

  @override
  void checkIsEnd(int length) {
    isEnd = true;
  }

  @override
  Future<LoadingState<List<CoreBgmRecommend>?>> customGetData() async {
    final result = await Get.find<MusicRepository>().bgmRecommend(musicId);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
