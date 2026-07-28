import 'package:skf/core/repository/music_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/music_types.dart';
import 'package:skf/adapters/bilibili/pages/common/dyn/common_dyn_controller.dart';

class CoreMusicDetailController extends CommonDynController {
  @override
  late final int oid;
  @override
  late final int replyType;

  @override
  dynamic get sourceId => oid.toString();

  final infoState = LoadingState<CoreMusicDetail>.loading().obs;

  late final String musicId;

  String get shareUrl =>
      'https://music.bilibili.com/h5/music-detail?music_id=$musicId';

  @override
  void onInit() {
    super.onInit();
    musicId = Get.parameters['musicId']!;
    getCoreMusicDetail();
  }

  Future<void> getCoreMusicDetail() async {
    final res = await Get.find<MusicRepository>().bgmDetail(musicId);
    if (res case Success(:final response)) {
      final comment = response.musicComment!;
      oid = comment.oid!;
      replyType = comment.pageType ?? 47;
      count.value = comment.nums ?? -1;
      queryData();
    }
    infoState.value = switch (res) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
