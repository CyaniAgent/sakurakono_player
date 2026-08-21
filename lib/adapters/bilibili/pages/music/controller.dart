import 'package:skf/core/repository/music_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
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
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  String get shareUrl =>
      'https://music.bilibili.com/h5/music-detail?music_id=$musicId';

  CoreMusicDetailController() {
    musicId = Get.parameters['musicId']!;
    getCoreMusicDetail();
  }

  Future<void> getCoreMusicDetail() async {
    final res = await (_ref?.read(musicRepositoryProvider) ?? Get.find<MusicRepository>()).bgmDetail(musicId);
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
