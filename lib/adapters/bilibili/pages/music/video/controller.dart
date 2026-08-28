import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/music_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

typedef MusicRecommendArgs = ({String id, CoreMusicDetail item});

class MusicRecommendController
    extends CommonListControllerRiverpod<List<CoreBgmRecommend>?, CoreBgmRecommend> {
  void attachRef(Ref ref) {}
  late final String musicId;
  late final CoreMusicDetail musicDetail;

  MusicRecommendController() {
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
    final result = await (appRead(musicRepositoryProvider)).bgmRecommend(musicId);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
