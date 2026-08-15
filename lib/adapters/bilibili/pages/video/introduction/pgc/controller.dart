import 'dart:async';
import 'dart:math' show max;

import 'package:skf/common/widgets/dialog/simple_dialog_option.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/repository/pgc_repository.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/models/common/video/source_type.dart';
import 'package:skf/adapters/bilibili/http/constants.dart';
import 'package:skf/adapters/bilibili/models_new/pgc/pgc_info_model/episode.dart';
import 'package:skf/adapters/bilibili/models_new/pgc/pgc_info_model/result.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/episode.dart'
    hide EpisodeItem;
import 'package:skf/adapters/bilibili/models_new/video/video_detail/stat_detail.dart';
import 'package:skf/adapters/bilibili/pages/common/common_intro_controller.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_repost/view.dart';
import 'package:skf/adapters/bilibili/pages/video/reply/controller.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/models/play_repeat.dart';
import 'package:skf/adapters/bilibili/services/service_locator.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/global_data.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/share_utils.dart';
import 'package:skf/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';


class PgcIntroController extends CommonIntroController {
  int? seasonId;
  int? epId;

  late final String pgcType = pgcItem.type == 1 || pgcItem.type == 4
      ? '\u8ffd\u756a'
      : '\u8ffd\u5267';

  late final bool isPgc;
  late final PgcInfoModel pgcItem;

  @override
  (Object, int) get getFavRidType => (epId!, 24);

  @override
  StatDetail? getStat() => pgcItem.stat;

  late final RxBool isFollowed = false.obs;
  late final RxInt followStatus = (-1).obs;
  late final RxBool isFav = (pgcItem.userStatus?.favored == 1).obs;

  @override
  void onInit() {
    final args = Get.arguments;
    seasonId = args['seasonId'];
    epId = args['epId'];
    isPgc = args['videoType'] == CoreVideoType.pgc;
    pgcItem = args['pgcItem'];

    super.onInit();

    if (isPgc) {
      if (isLogin) {
        queryIsFollowed();
        if (epId != null) {
          queryPgcLikeCoinFav();
        }
      }
      queryVideoTags();
    }
  }

  // \u83b7\u53d6\u70b9\u8d5e/\u6295\u5e01/\u6536\u85cf\u72b6\u6001
  Future<void> queryPgcLikeCoinFav() async {
    final result = await Get.find<VideoRepository>().pgcLikeCoinFav(epId: '${epId!}');
    if (result case Success(:final response)) {
      final hasLike = response.like == 1;
      final hasFav = response.favorite == 1;
      late final stat = pgcItem.stat;
      if (hasLike) {
        stat?.like = max(1, stat.like);
      }
      if (hasFav) {
        stat?.favorite = max(1, stat.favorite);
      }
      this.hasLike.value = hasLike;
      coinNum.value = response.coinNumber!;
      this.hasFav.value = hasFav;
    } else {
      SmartDialog.showToast(result.toString());
    }
  }

  // \uff08\u53d6\u6d88\uff09\u70b9\u8d5e
  @override
  Future<void> actionLikeVideo() async {
    if (!isLogin) {
      SmartDialog.showToast('\u8d26\u53f7\u672a\u767b\u5f55');
      return;
    }
    final newVal = !hasLike.value;
    final result = await Get.find<VideoRepository>().likeVideo(bvid: bvid, type: newVal);
    if (result case Success(:final response)) {
      SmartDialog.showToast(newVal ? response : '\u53d6\u6d88\u8d5e');
      pgcItem.stat?.like += newVal ? 1 : -1;
      hasLike.value = newVal;
    } else {
      SmartDialog.showToast(result.toString());
    }
  }

  @override
  int get copyright => 1;

  // \u5206\u4eab\u89c6\u9891
  @override
  void actionShareVideo(BuildContext context) {
    String videoUrl =
        '${HttpString.baseUrl}/bangumi/play/ep$epId${videoDetailCtr.playedTimePos}';
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          DialogOption(
            child: const Text('\u590d\u5236\u94fe\u63a5', style: TextStyle(fontSize: 14)),
            onPressed: () {
              Get.back();
              Utils.copyText(videoUrl);
            },
          ),
          DialogOption(
            child: const Text('\u5176\u5b83app\u6253\u5f00', style: TextStyle(fontSize: 14)),
            onPressed: () {
              Get.back();
              PageUtils.launchURL(videoUrl);
            },
          ),
          if (PlatformUtils.isMobile)
            DialogOption(
              child: const Text('\u5206\u4eab\u89c6\u9891', style: TextStyle(fontSize: 14)),
              onPressed: () {
                final item = pgcItem.episodes?.firstWhereOrNull(
                  (item) => item.epId == epId,
                );
                Get.back();
                ShareUtils.shareText(
                  '${pgcItem.title}${item != null ? ' ${item.showTitle}' : ''}'
                  ' - $videoUrl',
                );
              },
            ),
          if (isLogin)
            DialogOption(
              child: const Text('\u5206\u4eab\u81f3\u52a8\u6001', style: TextStyle(fontSize: 14)),
              onPressed: () {
                Get.back();
                final item = pgcItem.episodes?.firstWhereOrNull(
                  (item) => item.epId == epId,
                );
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (context) => RepostPanel(
                    rid: epId,
                    dynType: switch (pgcItem.type) {
                      1 => 4097,
                      2 => 4098,
                      3 => 4101,
                      4 => 4100,
                      5 || 7 => 4099,
                      _ => -1,
                    },
                    pic: pgcItem.cover,
                    title:
                        '${pgcItem.title}${item != null ? '\n${item.showTitle}' : ''}',
                    uname: '',
                  ),
                );
              },
            ),
          if (isLogin)
            DialogOption(
              child: const Text(
                '\u5206\u4eab\u81f3\u6d88\u606f',
                style: TextStyle(fontSize: 14),
              ),
              onPressed: () {
                Get.back();
                try {
                  final item = pgcItem.episodes!.firstWhere(
                    (item) => item.epId == epId,
                  );
                  final title =
                      item.shareCopy ??
                      '${pgcItem.title} ${item.showTitle ?? item.longTitle}';
                  PageUtils.pmShare(
                    context,
                    content: {
                      "id": epId!.toString(),
                      "title": title,
                      "url": item.shareUrl,
                      "headline": title,
                      "source": 16,
                      "thumb": item.cover,
                      "source_desc": switch (pgcItem.type) {
                        1 => '\u756a\u5267',
                        2 => '\u7535\u5f71',
                        3 => '\u7eaa\u5f55\u7247',
                        4 => '\u56fd\u521b',
                        5 => '\u7535\u89c6\u5267',
                        6 => '\u6f2b\u753b',
                        7 => '\u7efc\u827a',
                        _ => null,
                      },
                    },
                  );
                } catch (e) {
                  SmartDialog.showToast(e.toString());
                }
              },
            ),
        ],
      ),
    );
  }

  // \u4fee\u6539\u5206P\u6216\u756a\u5267\u5206\u96c6
  Future<bool> onChangeEpisode(BaseEpisodeItem episode) async {
    try {
      final int epId = episode.epId ?? episode.id!;
      final String bvid = episode.bvid ?? this.bvid;
      final int aid = episode.aid ?? IdUtils.bv2av(bvid);
      final int? cid =
          episode.cid ?? await Get.find<SearchRepository>().ab2c(aid: aid, bvid: bvid);
      if (cid == null) {
        return false;
      }
      final String? cover = episode.cover;

      this.epId = epId;
      this.bvid = bvid;

      videoDetailCtr
        ..plPlayerController.pause()
        ..makeHeartBeat()
        ..onReset()
        ..epId = epId
        ..bvid = bvid
        ..aid = aid
        ..cid.value = cid
        ..queryVideoUrl();
      if (cover != null && cover.isNotEmpty) {
        videoDetailCtr.cover.value = cover;
      }

      if (videoDetailCtr.showReply) {
        try {
          final replyCtr = Get.find<VideoReplyController>(tag: heroTag)
            ..aid = aid;
          if (replyCtr.loadingState.value is! Loading) {
            replyCtr.onReload();
          }
        } catch (_) {}
      }

      if (isPgc && isLogin) {
        queryPgcLikeCoinFav();
      }

      hasLater.value = videoDetailCtr.sourceType == SourceType.watchLater;
      this.cid.value = cid;
      queryOnlineTotal();
      queryVideoIntro(episode as EpisodeItem);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('pgc onChangeEpisode: $e');
      return false;
    }
  }

  // \u8ffd\u756a
  Future<void> pgcAdd() async {
    final result = await Get.find<VideoRepository>().pgcAdd(seasonId: pgcItem.seasonId);
    if (result case Success(:final response)) {
      isFollowed.value = true;
      followStatus.value = 2;
      SmartDialog.showToast(response);
    } else {
      SmartDialog.showToast(result.toString());
    }
  }

  // \u53d6\u6d88\u8ffd\u756a
  Future<void> pgcDel() async {
    final result = await Get.find<VideoRepository>().pgcDel(seasonId: pgcItem.seasonId);
    if (result case Success(:final response)) {
      isFollowed.value = false;
      SmartDialog.showToast(response);
    } else {
      SmartDialog.showToast(result.toString());
    }
  }

  Future<void> pgcUpdate(int status) async {
    final result = await Get.find<VideoRepository>().pgcUpdate(
      seasonId: pgcItem.seasonId.toString(),
      status: status,
    );
    if (result case Success(:final response)) {
      followStatus.value = status;
      SmartDialog.showToast(response);
    } else {
      SmartDialog.showToast(result.toString());
    }
  }

  @override
  bool prevPlay() {
    final episodes = pgcItem.episodes!;
    int currentIndex = episodes.indexWhere(
      (e) => e.cid == videoDetailCtr.cid.value,
    );
    int prevIndex = currentIndex - 1;
    PlayRepeat playRepeat = videoDetailCtr.plPlayerController.playRepeat;
    if (prevIndex < 0) {
      if (playRepeat == PlayRepeat.listCycle) {
        prevIndex = episodes.length - 1;
      } else {
        return false;
      }
    }
    onChangeEpisode(episodes[prevIndex]);
    return true;
  }

  @override
  bool nextPlay() {
    try {
      final episodes = pgcItem.episodes!;

      PlayRepeat playRepeat = videoDetailCtr.plPlayerController.playRepeat;

      int currentIndex = episodes.indexWhere(
        (e) => e.cid == videoDetailCtr.cid.value,
      );
      int nextIndex = currentIndex + 1;
      if (nextIndex >= episodes.length) {
        if (playRepeat == PlayRepeat.listCycle) {
          nextIndex = 0;
        } else if (playRepeat == PlayRepeat.autoPlayRelated) {
          return false;
        } else {
          return false;
        }
      }
      onChangeEpisode(episodes[nextIndex]);
      return true;
    } catch (_) {
      return false;
    }
  }

  // \u4e00\u952e\u4e09\u8fde
  @override
  Future<void> actionTriple() async {
    feedBack();
    if (!isLogin) {
      SmartDialog.showToast('\u8d26\u53f7\u672a\u767b\u5f55');
      return;
    }
    if (hasLike.value && hasCoin && hasFav.value) {
      SmartDialog.showToast('\u5df2\u4e09\u8fde');
      return;
    }
    final result = await Get.find<VideoRepository>().pgcTriple(epId: '${epId!}', seasonId: seasonId?.toString());
    if (result case Success(:final response)) {
      late final stat = pgcItem.stat;
      if (response.like == 1 && !hasLike.value) {
        stat?.like++;
        hasLike.value = true;
      }
      if (response.coin == 1 && !hasCoin) {
        stat?.coin += 2;
        coinNum.value = 2;
        GlobalData().afterCoin(2);
      }
      if (response.favorite == 1 && !hasFav.value) {
        stat?.favorite++;
        hasFav.value = true;
      }
      if (!hasCoin) {
        SmartDialog.showToast('\u6295\u5e01\u5931\u8d25');
      } else {
        SmartDialog.showToast('\u4e09\u8fde\u6210\u529f');
      }
    } else {
      SmartDialog.showToast(result.toString());
    }
  }

  Future<void> queryIsFollowed() async {
    final res = await Get.find<PgcRepository>().seasonStatus(seasonId!);
    if (res case Success(:final response)) {
      isFollowed.value = response['follow'] == 1;
      followStatus.value = response['follow_status'];
    }
  }

  @override
  void queryVideoIntro([EpisodeItem? episode]) {
    episode ??= pgcItem.episodes!.firstWhere((e) => e.cid == cid.value);
    videoDetail
      ..value.title = episode.showTitle
      ..refresh();
    videoPlayerServiceHandler?.onVideoDetailChange(
      episode,
      cid.value,
      heroTag,
      artist: pgcItem.title,
    );
  }

  Future<void> onFavPugv(bool isFav) async {
    final res = isFav
      ? await Get.find<FavRepository>().delFavPugv(seasonId!)
      : await Get.find<FavRepository>().addFavPugv(seasonId!);
    if (res.isSuccess) {
      this.isFav.toggle();
      SmartDialog.showToast('${isFav ? '\u53d6\u6d88' : ''}\u6536\u85cf\u6210\u529f');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }
}
