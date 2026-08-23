import 'dart:async';
import 'dart:math';

import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/adapters/bilibili/http/api.dart';
import 'package:skf/adapters/bilibili/http/constants.dart';
import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/models_new/media_list/media_list.dart';
import 'package:skf/adapters/bilibili/models_new/relation/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/dimension.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/episode.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/page.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/section.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/staff.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/stat_detail.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/ugc_season.dart';
import 'package:skf/adapters/bilibili/pages/common/common_intro_controller.dart';
import 'package:skf/pages/video/video_host.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_repost/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/related/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply/controller.dart';
import 'package:skf/player/models/play_repeat.dart';
import 'package:skf/adapters/bilibili/services/service_locator.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/device_utils.dart';
import 'package:skf/utils/extension/size_ext.dart';
import 'package:skf/utils/extension/string_ext.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/global_data.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/adapters/bilibili/utils/request_utils.dart';
import 'package:skf/utils/share_utils.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/utils/utils.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

class UgcIntroController extends CommonIntroController with ReloadMixin {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  late final RxBool expand;
  bool status = true;

  // up主粉丝数
  CoreMemberCardInfoData userStat = CoreMemberCardInfoData();
  // 关注状态 默认未关注
  late final Rx<CoreRelationData> followStatus = Rx(CoreRelationData());
  late final Map staffRelations = {};

  // 是否点踩
  bool hasDislike = false;

  late final showArgueMsg = Pref.showArgueMsg;
  late final enableAi = Pref.enableAi;
  late final horizontalMemberPage = Pref.horizontalMemberPage;

  Map<String, dynamic>? aiConclusionResult;

  late final Map<int?, bool> seasonFavState = {};

  @override
  void onInit() {
    super.onInit();
    final alwaysExpandIntroPanel = Pref.alwaysExpandIntroPanel;
    expand = RxBool(alwaysExpandIntroPanel);
    if (!alwaysExpandIntroPanel && Pref.expandIntroPanelH) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!expand.value && !DeviceUtils.size.isPortrait) {
          expand.toggle();
        }
      });
    }
    videoDetail.title = Get.arguments['title'] ?? '';
  }

  // 获取视频简介&分p
  @override
  Future<void> queryVideoIntro() async {
    queryVideoTags();
    final res = await (_ref!.read(videoRepositoryProvider)).videoIntro(bvid: bvid);
    if (res case Success(:final response)) {
      if (response.redirectUrl != null &&
          videoDetailCtr.epId == null &&
          videoDetailCtr.seasonId == null) {
        if (!isClosed) {
          PageUtils.viewPgcFromUri(response.redirectUrl!, off: true);
        }
        return;
      }
      videoPlayerServiceHandler?.onVideoDetailChange(
        response,
        cid,
        heroTag,
      );
      // Convert core response to adapter VideoDetailData for the base class
      final adapterResponse = VideoDetailData.fromJson(<String, dynamic>{
        'bvid': response.bvid,
        'aid': response.aid,
        'videos': response.videos,
        'copyright': response.copyright,
        'pic': response.pic,
        'title': response.title,
        'pubdate': response.pubdate,
        'ctime': response.ctime,
        'desc': response.desc,
        'desc_v2': response.descV2,
        'duration': response.duration,
        'rights': response.rights,
        'owner': response.owner,
        'stat': response.stat,
        'argue_info': response.argueInfo,
        'cid': response.cid,
        'dimension': response.dimension,
        'season_id': response.seasonId,
        'is_upower_exclusive': response.isUpowerExclusive,
        'pages': response.pages,
        'ugc_season': response.ugcSeason,
        'staff': response.staff,
        'redirect_url': response.redirectUrl,
      });
      videoDetail = adapterResponse;
      try {
        if (videoDetailCtr.cover.value.isEmpty ||
            (videoDetailCtr.videoUrl.isNullOrEmpty &&
                !videoDetailCtr.isQuerying)) {
          videoDetailCtr.cover.value = response.pic ?? '';
        }
        if (videoDetailCtr.showReply) {
          try {
            Get.find<VideoReplyController>(tag: heroTag).count.value =
                response.stat?['reply'] as int? ?? 0;
          } catch (_) {}
        }
      } catch (_) {}
      final pages = videoDetail.pages;
      if (pages != null && pages.isNotEmpty && cid == 0) {
        cid = pages.first.cid!;
      }
      queryUserStat(response.staff
          ?.map(Staff.fromJson)
          .toList());
    } else {
      SmartDialog.showToast(res.toString());
      status = false;
    }

    if (isLogin) {
      queryAllStatus();
      queryFollowStatus();
    }
  }

  // 获取up主粉丝数
  Future<void> queryUserStat(List<Staff>? staff) async {
    if (staff != null && staff.isNotEmpty) {
      final res = await Request().get(
        Api.relations,
        queryParameters: {'fids': staff.map((item) => item.mid).join(',')},
      );
      if (res.data['code'] == 0) {
        staffRelations.addAll({'status': true, ...?res.data['data']});
      }
    } else {
      final mid = videoDetail.owner?.mid;
      if (mid == null) {
        return;
      }
      final res = await (_ref!.read(memberRepositoryProvider)).memberCardInfo(mid: mid);
      if (res case Success(:final response)) {
        userStat = response;
      }
    }
  }

  Future<void> queryAllStatus() async {
    final result = await (_ref!.read(videoRepositoryProvider)).videoRelation(bvid: bvid);
    if (result case Success(:final response)) {
      late final stat = videoDetail.stat;
      if (response.like!) {
        stat?.like = max(1, stat.like);
      }
      if (response.favorite!) {
        stat?.favorite = max(1, stat.favorite);
      }
      hasLike = response.like!;
      hasDislike = response.dislike!;
      coinNum = response.coin!;
      hasFav = response.favorite!;
    }
  }

  // 一键三连
  @override
  Future<void> actionTriple() async {
    feedBack();
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    if (hasLike && hasCoin && hasFav) {
      // 已点赞、投币、收藏
      SmartDialog.showToast('已三连');
      return;
    }
    final result = await (_ref!.read(videoRepositoryProvider)).ugcTriple(bvid: bvid);
    if (result case Success(:final response)) {
      late final stat = videoDetail.stat;
      if (response.like == true && !hasLike) {
        stat?.like++;
        hasLike = true;
      }
      if (response.coin == true && !hasCoin) {
        stat?.coin += 2;
        coinNum = 2;
        GlobalData().afterCoin(2);
      }
      if (response.fav == true && !hasFav) {
        stat?.favorite++;
        hasFav = true;
      }
      hasDislike = false;
      if (!hasCoin) {
        SmartDialog.showToast('投币失败');
      } else {
        SmartDialog.showToast('三连成功');
      }
    } else {
      SmartDialog.showToast(result.toString());
    }
  }

  // （取消）点赞
  @override
  Future<void> actionLikeVideo() async {
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    if (videoDetail.stat == null) {
      return;
    }
    final newVal = !hasLike;
    final result = await (_ref!.read(videoRepositoryProvider)).likeVideo(bvid: bvid, type: newVal);
    if (result case Success(:final response)) {
      SmartDialog.showToast(newVal ? response : '取消赞');
      videoDetail.stat?.like += newVal ? 1 : -1;
      hasLike = newVal;
      if (newVal) {
        hasDislike = false;
      }
    } else {
      SmartDialog.showToast(result.toString());
    }
  }

  Future<void> actionDislikeVideo() async {
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final res = await (_ref!.read(videoRepositoryProvider)).dislikeVideo(
      bvid: bvid,
      type: !hasDislike,
    );
    if (res.isSuccess) {
      if (!hasDislike) {
        SmartDialog.showToast('点踩成功');
        hasDislike = true;
        if (hasLike) {
          videoDetail.stat?.like--;
          hasLike = false;
        }
      } else {
        SmartDialog.showToast('取消踩');
        hasDislike = false;
      }
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  @override
  int get copyright => videoDetail.copyright ?? 1;

  @override
  (Object, int) get getFavRidType => (IdUtils.bv2av(bvid), 2);

  @override
  StatDetail? getStat() => videoDetail.stat;

  // 分享视频
  @override
  void actionShareVideo(BuildContext context) {
    final videoDetail = this.videoDetail;
    final playedTimePos = videoDetailCtr.playedTimePos;
    String videoUrl = '${HttpString.baseUrl}/video/$bvid';
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          ListTile(
            dense: true,
            title: const Text(
              '复制链接',
              style: TextStyle(fontSize: 14),
            ),
            onTap: () {
              Get.back();
              Utils.copyText(videoUrl);
            },
            trailing: playedTimePos.isNotEmpty
                ? iconButton(
                    tooltip: '精确分享',
                    icon: const Icon(Icons.timer_outlined),
                    onPressed: () {
                      Get.back();
                      Utils.copyText('$videoUrl$playedTimePos');
                    },
                  )
                : null,
          ),
          ListTile(
            dense: true,
            title: const Text(
              '其它app打开',
              style: TextStyle(fontSize: 14),
            ),
            onTap: () {
              Get.back();
              PageUtils.launchURL(videoUrl);
            },
          ),
          if (PlatformUtils.isMobile)
            ListTile(
              dense: true,
              title: const Text(
                '分享视频',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Get.back();
                ShareUtils.shareText(
                  '${videoDetail.title} '
                  'UP主: ${videoDetail.owner!.name!}'
                  ' - $videoUrl',
                );
              },
            ),
          if (isLogin)
            ListTile(
              dense: true,
              title: const Text(
                '分享至动态',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Get.back();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (context) => RepostPanel(
                    rid: videoDetail.aid,
                    dynType: 8,
                    pic: videoDetail.pic,
                    title: videoDetail.title,
                    uname: videoDetail.owner?.name,
                  ),
                );
              },
            ),
          if (isLogin)
            ListTile(
              dense: true,
              title: const Text(
                '分享至消息',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Get.back();
                try {
                  PageUtils.pmShare(
                    context,
                    content: {
                      "id": videoDetail.aid!.toString(),
                      "title": videoDetail.title!,
                      "headline": videoDetail.title!,
                      "source": 5,
                      "thumb": videoDetail.pic!,
                      "author": videoDetail.owner!.name!,
                      "author_id": videoDetail.owner!.mid!.toString(),
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

  // 查询关注状态
  Future<void> queryFollowStatus() async {
    final videoDetail = this.videoDetail;
    if (videoDetail.owner == null || videoDetail.staff?.isNotEmpty == true) {
      return;
    }
    final res = await (_ref!.read(userRepositoryProvider)).userRelation(videoDetail.owner!.mid!);
    if (res case Success(:final response)) {
      if (response.special == 1) response.attribute = -10;
      followStatus.value = response;
    }
  }

  // 关注/取关up
  Future<void> actionRelationMod(BuildContext context) async {
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final videoDetail = this.videoDetail;
    if (videoDetail.staff?.isNotEmpty == true) {
      return;
    }
    int? mid = videoDetail.owner?.mid;
    if (mid == null) {
      return;
    }
    int attr = followStatus.value.attribute ?? 0;
    if (attr == 128) {
      final res = await (_ref!.read(videoRepositoryProvider)).relationMod(
        mid: mid,
        act: 6,
        reSrc: 11,
      );
      if (res.isSuccess) {
        followStatus
          ..value.attribute = 0
          ..refresh();
      }
      return;
    } else {
      RequestUtils.actionRelationMod(
        context: context,
        mid: mid,
        isFollow: attr != 0,
        followStatus: RelationData(
          attribute: followStatus.value.attribute,
          mtime: followStatus.value.mtime,
          tag: followStatus.value.tag,
          special: followStatus.value.special,
        ),
        afterMod: (attribute) {
          followStatus
            ..value.attribute = attribute
            ..refresh();
          Future.delayed(const Duration(milliseconds: 500), queryFollowStatus);
        },
      );
    }
  }

  // 修改分P或番剧分集
  Future<bool> onChangeEpisode(
    BaseEpisodeItem episode, {
    bool isStein = false,
  }) async {
    try {
      final String bvid = episode.bvid ?? this.bvid;
      final int aid = episode.aid ?? IdUtils.bv2av(bvid);
      int? cid = episode.cid;
      Dimension? dimension;
      if (cid == null) {
        if (await (_ref!.read(searchRepositoryProvider)).ab2cWithDimension(aid: aid, bvid: bvid)
            case final res?) {
          cid = res.cid;
          final coreDim = res.dimension;
          dimension = coreDim != null
              ? Dimension(width: coreDim.width, height: coreDim.height)
              : null;
        }
      }
      if (cid == null) {
        return false;
      }

      final String? cover = episode.cover;

      // 重新获取视频资源
      if (videoDetailCtr.isPlayAll) {
        if (videoDetailCtr.mediaList.indexWhere((item) => item.bvid == bvid) ==
            -1) {
          if (dimension == null && episode is EpisodeItem) {
            dimension = episode.page?.dimension;
          }
          PageUtils.toVideoPage(
            bvid: bvid,
            cid: cid,
            cover: cover,
            dimension: dimension,
          );
          return false;
        }
      }

      videoDetailCtr
        ..plPlayerController.pause()
        ..makeHeartBeat()
        ..updateMediaListHistory(aid)
        ..onReset(isStein: isStein)
        ..bvid = bvid
        ..aid = aid
        ..cid.value = cid
        ..queryVideoUrl();

      if (this.bvid != bvid) {
        reload = true;
        aiConclusionResult = null;

        if (cover != null && cover.isNotEmpty) {
          videoDetailCtr.cover.value = cover;
        }

        // 重新请求相关视频
        if (videoDetailCtr.plPlayerController.showRelatedVideo) {
          try {
            Get.find<RelatedController>(tag: heroTag)
              ..bvid = bvid
              ..queryData();
          } catch (_) {}
        }

        // 重新请求评论
        if (videoDetailCtr.showReply) {
          try {
            final replyCtr = Get.find<VideoReplyController>(tag: heroTag)
              ..aid = aid;
            if (replyCtr.loadingState is! Loading) {
              replyCtr.onReload();
            }
          } catch (_) {}
        }

        hasLater = VideoHost.of().isWatchLaterSource(videoDetailCtr.args['sourceType']);
        this.bvid = bvid;
        queryVideoIntro();
      } else {
        if (episode is Part) {
          final videoDetail = this.videoDetail;
          videoPlayerServiceHandler?.onVideoDetailChange(
            episode,
            cid,
            heroTag,
            artist: videoDetail.owner?.name,
            cover: videoDetail.pic,
          );
        }
      }

      this.cid = cid;
      queryOnlineTotal();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('ugc onChangeEpisode: $e');
      return false;
    }
  }

  /// 播放上一个
  @override
  bool prevPlay([bool skipPart = false]) {
    final List<BaseEpisodeItem> episodes = <BaseEpisodeItem>[];
    bool isPart = false;

    final videoDetail = this.videoDetail;

    if (!skipPart && (videoDetail.pages?.length ?? 0) > 1) {
      isPart = true;
      episodes.addAll(videoDetail.pages!);
    } else if (videoDetailCtr.isPlayAll) {
      episodes.addAll(
        videoDetailCtr.mediaList.map(
          (e) => MediaListItemModel(
            aid: e.aid,
            bvid: e.bvid,
            cover: e.cover,
            title: e.title,
            type: e.type,
            badge: e.badge,
            intro: e.intro,
            duration: e.duration,
          ),
        ),
      );
    } else if (videoDetail.ugcSeason != null) {
      final UgcSeason ugcSeason = videoDetail.ugcSeason!;
      final List<SectionItem> sections = ugcSeason.sections!;
      for (int i = 0; i < sections.length; i++) {
        final List<EpisodeItem> episodesList = sections[i].episodes!;
        episodes.addAll(episodesList);
      }
    }

    final int currentIndex = episodes.indexWhere(
      (e) =>
          e.cid ==
          (skipPart
              ? videoDetail.isPageReversed
                    ? videoDetail.pages!.last.cid
                    : videoDetail.pages!.first.cid
              : this.cid),
    );

    int prevIndex = currentIndex - 1;
    final PlayRepeat playRepeat = VideoHost.of().playerHost.playerPlayRepeat;

    // 列表循环
    if (prevIndex < 0) {
      if (isPart &&
          (videoDetailCtr.isPlayAll || videoDetail.ugcSeason != null)) {
        return prevPlay(true);
      }
      if (playRepeat == PlayRepeat.listCycle) {
        prevIndex = episodes.length - 1;
      } else {
        return false;
      }
    }

    int? cid = episodes[prevIndex].cid;
    while (cid == null) {
      prevIndex--;
      if (prevIndex < 0) {
        return false;
      }
      cid = episodes[prevIndex].cid;
    }

    if (cid != this.cid) {
      onChangeEpisode(episodes[prevIndex]);
      return true;
    } else {
      return false;
    }
  }

  /// 列表循环或者顺序播放时，自动播放下一个
  @override
  bool nextPlay([bool skipPart = false]) {
    try {
      final List<BaseEpisodeItem> episodes = <BaseEpisodeItem>[];
      bool isPart = false;
      final videoDetail = this.videoDetail;

      // part -> playall -> season
      if (!skipPart && (videoDetail.pages?.length ?? 0) > 1) {
        isPart = true;
        final List<Part> pages = videoDetail.pages!;
        episodes.addAll(pages);
      } else if (videoDetailCtr.isPlayAll) {
        episodes.addAll(
          videoDetailCtr.mediaList.map(
            (e) => MediaListItemModel(
              aid: e.aid,
              bvid: e.bvid,
              cover: e.cover,
              title: e.title,
              type: e.type,
              badge: e.badge,
              intro: e.intro,
              duration: e.duration,
            ),
          ),
        );
      } else if (videoDetail.ugcSeason != null) {
        final UgcSeason ugcSeason = videoDetail.ugcSeason!;
        final List<SectionItem> sections = ugcSeason.sections!;
        for (int i = 0; i < sections.length; i++) {
          final List<EpisodeItem> episodesList = sections[i].episodes!;
          episodes.addAll(episodesList);
        }
      }

      final PlayRepeat playRepeat =
          VideoHost.of().playerHost.playerPlayRepeat;

      if (episodes.isEmpty) {
        if (playRepeat == PlayRepeat.listCycle) {
          videoDetailCtr.plPlayerController.play(repeat: true);
          return true;
        }
        if (playRepeat == PlayRepeat.autoPlayRelated &&
            videoDetailCtr.plPlayerController.showRelatedVideo) {
          return playRelated();
        }
        return false;
      }

      final int currentIndex = episodes.indexWhere(
        (e) =>
            e.cid ==
            (skipPart
                ? videoDetail.isPageReversed
                      ? videoDetail.pages!.last.cid
                      : videoDetail.pages!.first.cid
                : this.cid),
      );

      int nextIndex = currentIndex + 1;

      if (!isPart &&
          videoDetailCtr.isPlayAll &&
          currentIndex == episodes.length - 2) {
        videoDetailCtr.getMediaList();
      }

      // 列表循环
      if (nextIndex >= episodes.length) {
        if (isPart &&
            (videoDetailCtr.isPlayAll || videoDetail.ugcSeason != null)) {
          return nextPlay(true);
        }

        if (playRepeat == PlayRepeat.listCycle) {
          nextIndex = 0;
        } else if (playRepeat == PlayRepeat.autoPlayRelated &&
            videoDetailCtr.plPlayerController.showRelatedVideo) {
          return playRelated();
        } else {
          return false;
        }
      }

      int? cid = episodes[nextIndex].cid;
      while (cid == null) {
        nextIndex++;
        if (nextIndex >= episodes.length) {
          return false;
        }
        cid = episodes[nextIndex].cid;
      }

      if (cid != this.cid) {
        onChangeEpisode(episodes[nextIndex]);
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  bool playRelated() {
    RelatedController relatedCtr;
    if (Get.isRegistered<RelatedController>(tag: heroTag)) {
      relatedCtr = Get.find<RelatedController>(tag: heroTag);
    } else {
      relatedCtr = Get.put(RelatedController(autoQuery: false), tag: heroTag)
        ..queryData().whenComplete(playRelated);
      return false;
    }

    if (relatedCtr.loadingState case Success(:final response)) {
      final firstItem = response?.firstOrNull;
      if (firstItem == null) {
        SmartDialog.showToast('暂无相关视频，停止连播');
        return false;
      }
      onChangeEpisode(
        BaseEpisodeItem(
          aid: firstItem.aid,
          bvid: firstItem.bvid,
          cid: firstItem.cid,
          cover: firstItem.cover,
        ),
      );
      return true;
    }

    return false;
  }

  // ai总结
  static Future<Map<String, dynamic>?> getAiConclusion(
    String bvid,
    int cid,
    int? mid,
  ) async {
    if (!Accounts.heartbeat.isLogin) {
      SmartDialog.showToast("账号未登录");
      return null;
    }
    SmartDialog.showLoading(msg: '正在获取AI总结');
    final res = await Get.find<VideoRepository>().aiConclusion(
      bvid: bvid,
      cid: cid,
      upMid: mid,
    );
    SmartDialog.dismiss();
    if (res case Success(:final response)) {
      return response.modelResult;
    } else if (res is Error && res.code == 1) {
      SmartDialog.showToast("AI处理中，请稍后再试");
    } else {
      SmartDialog.showToast("当前视频暂不支持AI视频总结");
    }
    return null;
  }

  Future<void> aiConclusion() async {
    aiConclusionResult = await getAiConclusion(
      bvid,
      cid,
      videoDetail.owner?.mid,
    );
  }
}

