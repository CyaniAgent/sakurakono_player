import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/models/music_types.dart';
import 'package:skf/adapters/bilibili/pages/common/dyn/common_dyn_controller.dart';
import 'package:skf/core/container/app_container.dart';

class CoreMusicDetailController extends CommonDynController {
  @override
  late final int oid;
  @override
  late final int replyType;

  @override
  dynamic get sourceId => oid.toString();

  LoadingState<CoreMusicDetail> infoState = LoadingState<CoreMusicDetail>.loading();

  late final String musicId;

  String get shareUrl =>
      'https://music.bilibili.com/h5/music-detail?music_id=$musicId';

  CoreMusicDetailController() {
    musicId = Get.parameters['musicId']!;
    getCoreMusicDetail();
  }

  Future<void> getCoreMusicDetail() async {
    final res = await appRead(musicRepositoryProvider).bgmDetail(musicId);
    if (res case Success(:final response)) {
      final comment = response.musicComment!;
      oid = comment.oid!;
      replyType = comment.pageType ?? 47;
      count = comment.nums ?? -1;
      queryData();
    }
    infoState = switch (res) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}

/// 每实例注册表 — 页面 view 创建后登记，按 key 经 provider 读取（替代 GetX tag 注册）。
/// key = musicId 参数
final Map<String, CoreMusicDetailController> coreMusicDetailRegistry = {};

final coreMusicDetailProvider = Provider.family<CoreMusicDetailController, String>(
  (ref, key) => coreMusicDetailRegistry[key] ??
      (throw StateError('CoreMusicDetailController not registered for key: $key')),
);

