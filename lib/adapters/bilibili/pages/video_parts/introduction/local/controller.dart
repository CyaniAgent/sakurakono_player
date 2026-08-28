import 'package:skf/adapters/bilibili/models_new/download/bili_download_entry_info.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/stat_detail.dart';
import 'package:skf/adapters/bilibili/pages/common/common_intro_controller.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/controller.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/player/models/play_repeat.dart';
import 'package:skf/adapters/bilibili/services/service_locator.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:skf/core/container/app_container.dart';
import 'package:skf/adapters/bilibili/common/setting_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalIntroController extends CommonIntroController {
  @override
  void queryVideoIntro() {}

  @override
  int get copyright => throw UnimplementedError();

  @override
  void actionLikeVideo() {}

  @override
  void actionShareVideo(context) {}

  @override
  void actionTriple() {}

  @override
  Future<void> actionFavVideo({bool isQuick = false}) async {}

  @override
  (Object, int) get getFavRidType => throw UnimplementedError();

  @override
  StatDetail? getStat() => null;

  @override
  bool get isShowOnlineTotal => false;

  late final Set<String> aidSet = {};

  @override
  void onClose() {
    aidSet.clear();
    videoPlayerServiceHandler?.onVideoDetailDispose(heroTag);
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    videoDetail.title = videoDetailCtr.args['title'];
    final controller = appRead(downloadPageControllerProvider);
    final list = <BiliDownloadEntryInfo>[];
    for (final e in controller.pages) {
      final items = e.entries..sort((a, b) => a.sortKey.compareTo(b.sortKey));
      final completed = items.where((e) => e.isCompleted);
      if (completed.isNotEmpty) {
        list.addAll(completed.map(ModelConverters.toBiliDownloadEntry));
      }
      if (completed.length == 1) {
        aidSet.add(e.pageId);
      }
    }
    this.list = list;
    final currCid = videoDetailCtr.cid.value;
    final index = list.indexWhere((e) => e.cid == currCid);
    this.index = index;
    if (PlatformUtils.isMobile) {
      onVideoDetailChange(list[index]);
    }
    if (index != 0) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        try {
          final state = videoDetailCtr.scrollKey.currentState;
          if (state != null && state.mounted) {
            (state.innerController as ExtendedNestedScrollController)
                .nestedPositions
                .first
                .localJumpTo(_offset);
          } else if (videoDetailCtr.introScrollCtr?.hasClients ?? false) {
            videoDetailCtr.introScrollCtr!.jumpTo(_offset);
          }
        } catch (_) {
          if (kDebugMode) rethrow;
        }
      });
    }
  }

  int index = -1;
  double get _offset => (index * 112 + 7 - 35).toDouble();
  List<BiliDownloadEntryInfo> list = [];

  @override
  bool nextPlay() {
    final next = index + 1;
    if (next < list.length) {
      playIndex(next);
      return true;
    } else {
      final playCtr = videoDetailCtr.plPlayerController as PlPlayerController;
      if (playCtr.playRepeat == PlayRepeat.listCycle) {
        if (list.length == 1) {
          if (playCtr.videoPlayerController case final ctr?) {
            ctr.seek(Duration.zero).whenComplete(ctr.play);
          }
        } else {
          playIndex(0);
        }
        return true;
      }
    }
    return false;
  }

  @override
  bool prevPlay() {
    final prev = index - 1;
    if (prev >= 0) {
      playIndex(prev);
      return true;
    }
    return false;
  }

  void playIndex(
    int index, {
    BiliDownloadEntryInfo? entry,
  }) {
    entry ??= list[index];
    videoDetailCtr
      ..onReset()
      ..cover.value = entry.cover
      ..aid = entry.avid
      ..bvid = entry.bvid
      ..cid.value = entry.cid
      ..args['dirPath'] = entry.entryDirPath
      ..initFileSource(entry, isInit: false)
      ..playerInit();
    videoDetail
      .title = entry.showTitle;
    notifyListeners();
    this.index = index;
    if (PlatformUtils.isMobile) {
      onVideoDetailChange(entry);
    }
  }

  void onVideoDetailChange(BiliDownloadEntryInfo entry) {
    videoPlayerServiceHandler?.onVideoDetailChange(entry, entry.cid, heroTag);
  }
}
/// 本地离线简介控制器（每视频页一实例，按 heroTag 键控）。
final localIntroControllerProvider = ChangeNotifierProvider
    .family<LocalIntroController, String>(
  (ref, heroTag) => LocalIntroController(),
);
