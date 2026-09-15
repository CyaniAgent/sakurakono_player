// B站 适配器的视频页宿主实现（VideoHost 契约的 B站 侧）。
//
// 页面主框架（lib/pages/video/）零适配器依赖；所有 B站 专属能力
// （播放器扩展、弹幕、回复、简介、选集、下载、字幕等）在此实现并
// 通过 [VideoHost] 注入。OttoHub 侧见 ottohub/services/otto_video_host.dart。

import 'dart:math' show max, min;
import 'package:skf/adapters/bilibili/common/setting_providers.dart';import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/core/container/app_container.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:skf/adapters/bilibili/grpc/bilibili/app/listener/v1.pbenum.dart'
    show PlaylistSource;
import 'package:skf/adapters/bilibili/grpc/dm.dart' as dm_grpc;
import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/adapters/bilibili/models/common/video/source_type.dart'
    show SourceType;
import 'package:skf/adapters/bilibili/models/common/sponsor_block/segment_model.dart'
    show SegmentModel;
import 'package:skf/adapters/bilibili/models/common/account_type.dart';
import 'package:skf/adapters/bilibili/models/common/episode_panel_type.dart';
import 'package:skf/adapters/bilibili/models/common/video/video_type.dart';
import 'package:skf/adapters/bilibili/models/video/play/url.dart' as play_url;
import 'package:skf/adapters/bilibili/models_new/download/bili_download_entry_info.dart';
import 'package:skf/adapters/bilibili/models_new/media_list/media_list.dart';
import 'package:skf/adapters/bilibili/models_new/pgc/pgc_info_model/result.dart';
import 'package:skf/adapters/bilibili/models_new/sponsor_block/segment_item.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_ai_conclusion/model_result.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/episode.dart'
    as ugc;
import 'package:skf/adapters/bilibili/models_new/video/video_detail/page.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/ugc_season.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_pbp/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_stein_edgeinfo/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_tag/data.dart';
import 'package:skf/adapters/bilibili/pages/audio/view.dart';
import 'package:skf/adapters/bilibili/pages/common/common_intro_controller.dart';
import 'package:skf/adapters/bilibili/pages/common/publish/publish_route.dart';
import 'package:skf/adapters/bilibili/pages/danmaku/view.dart' show PlDanmaku;
import 'package:skf/adapters/bilibili/pages/episode_panel/view.dart';
import 'package:skf/adapters/bilibili/pages/sponsor_block/block_mixin.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/ai_conclusion/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/download_panel/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/local/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/local/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/pgc/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/pgc/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/pgc/widgets/intro_detail.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/ugc/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/ugc/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/ugc/widgets/page.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/ugc/widgets/season.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/medialist/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/member/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/note/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/post_panel/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/related/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/send_danmaku/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/view_point/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/widgets/header_control.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/widgets/player_focus.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/controller.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/view/view.dart';
import 'package:skf/adapters/bilibili/services/service_locator.dart';
import 'package:skf/adapters/bilibili/services/shutdown_timer_service.dart'
    show shutdownTimerService;
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/player/models/heart_beat_type.dart';
import 'package:skf/player/player_controller.dart';
import 'package:skf/utils/extension/context_ext.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:skf/utils/extension/size_ext.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:media_kit/media_kit.dart' show Player;
import 'package:skf/adapters/bilibili/utils/bili_storage_pref.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/adapters/bilibili/utils/video_utils.dart';
import 'package:skf/common/widgets/keep_alive_wrapper.dart';
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/search/widgets/search_text.dart';
import 'package:skf/pages/video/controller.dart';
import 'package:skf/pages/video/video_host.dart';
import 'package:skf/player/models/data_source.dart';
import 'package:skf/utils/num_utils.dart' show NumUtils;
import 'package:skf/utils/platform_utils.dart';
import 'package:collection/collection.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/theme_utils.dart';

/// Core [CorePlayUrlModel] → 适配器 [play_url.PlayUrlModel] 转换（JSON 往返保字段）。
play_url.PlayUrlModel playUrlModelFromCore(CorePlayUrlModel core) {
  return play_url.PlayUrlModel.fromJson(<String, dynamic>{
    'from': core.from,
    'result': core.result,
    'message': core.message,
    'quality': core.quality,
    'format': core.format,
    'timelength': core.timeLength,
    'accept_format': core.acceptFormat,
    'accept_description': core.acceptDesc,
    'accept_quality': core.acceptQuality,
    'video_codecid': core.videoCodecid,
    'seek_param': core.seekParam,
    'seek_type': core.seekType,
    'dash': core.dash,
    'durl': core.durl,
    'support_formats': core.supportFormats,
    'volume': core.volume,
    'last_play_time': core.lastPlayTime,
    'last_play_cid': core.lastPlayCid,
    'cur_language': core.curLanguage,
    'language': core.language,
    'clip_info_list': core.clipInfoList,
  });
}


CoreSegmentItemModel _coreSegmentItem(SegmentItemModel e) =>
    CoreSegmentItemModel(
      cid: e.cid,
      category: e.category,
      actionType: e.actionType,
      segment: e.segment,
      uuid: e.uuid,
      videoDuration: e.videoDuration,
      votes: e.votes,
    );
/// 适配器 [VideoType] → core [CoreVideoType]。
CoreVideoType coreVideoTypeOf(VideoType t) {
  switch (t) {
    case VideoType.ugc:
      return CoreVideoType.ugc;
    case VideoType.pgc:
      return CoreVideoType.pgc;
    case VideoType.pugv:
      return CoreVideoType.pugv;
  }
}

/// B站 播放器宿主的实现（委托 [PlPlayerController] + [BlockConfigMixin]）。
class BiliVideoPlayerHost implements VideoPlayerHost {
  BiliVideoPlayerHost();

  late PlPlayerController _player;

  /// 每页访问获取播放器实例：getInstance 内部对已存在实例复用并计数 +1，
  /// 已销毁（currentInstance == null）则重建——恢复每页一次生命周期语义。
  @override
  PlayerController acquirePlayer() {
    _player = PlPlayerController.getInstance();
    return _player;
  }

  @override
  PlayerController get player => _player;

  @override
  bool get tryLook => _player.tryLook;

  @override
  bool get enableAudioNormalization => _player.enableAudioNormalization;

  @override
  bool get enableHeart => _player.enableHeart;

  @override
  bool get enableBlock => _player.enableBlock;

  @override
  bool get enableSponsorBlock => _player.enableSponsorBlock;

  @override
  bool get enablePgcSkip => _player.enablePgcSkip;

  @override
  bool get playerDanmakuVisible => _player.showDanmaku;

  @override
  void setPlayerDanmakuVisible(bool value) => _player.showDanmaku = value;

  @override
  bool get danmakuEnabled => _player.enableShowDanmaku;

  @override
  void toggleDanmakuEnabled() {
    final newVal = !_player.enableShowDanmaku;
    _player.enableShowDanmaku = newVal;
    if (!_player.tempPlayerConf) {
      GStorage.setting.put(SettingBoxKey.enableShowDanmaku, newVal);
    }
  }

  @override
  PlayRepeat get playerPlayRepeat => _player.playRepeat;

  @override
  Future<void>? playerMakeHeartBeat({
    required int progress,
    required HeartBeatType type,
    required bool isManual,
    required int aid,
    required String bvid,
    required int cid,
    int? epid,
    int? seasonId,
    int? pgcType,
    required CoreVideoType videoType,
  }) {
    return _player.makeHeartBeat(
      progress,
      type: type,
      isManual: isManual,
      aid: aid,
      bvid: bvid,
      cid: cid,
      epid: epid,
      seasonId: seasonId,
      pgcType: pgcType,
      videoType: _videoTypeOf(videoType),
    );
  }

  VideoType _videoTypeOf(CoreVideoType t) {
    switch (t) {
      case CoreVideoType.ugc:
        return VideoType.ugc;
      case CoreVideoType.pgc:
        return VideoType.pgc;
      case CoreVideoType.pugv:
        return VideoType.pugv;
    }
  }

  @override
  Future<void> playerSetDataSource({
    required DataSource source,
    Duration? seekTo,
    Duration? duration,
    bool isVertical = false,
    int? aid,
    String? bvid,
    int? cid,
    bool autoplay = true,
    int? epid,
    int? seasonId,
    int? pgcType,
    required CoreVideoType videoType,
    VoidCallback? onInit,
    int? width,
    int? height,
    VideoVolume? volume,
    bool autoFullScreenFlag = false,
  }) {
    return _player.setDataSource(
      source,
      seekTo: seekTo,
      duration: duration,
      isVertical: isVertical,
      aid: aid,
      bvid: bvid,
      cid: cid,
      autoplay: autoplay,
      epid: epid,
      seasonId: seasonId,
      pgcType: pgcType,
      videoType: _videoTypeOf(videoType),
      onInit: onInit,
      width: width,
      height: height,
      volume: volume == null ? null : play_url.Volume.fromJson(volume.toMap()),
      autoFullScreenFlag: autoFullScreenFlag,
    );
  }

  @override
  void setPlayCallBack(PlayCallback? playCallBack) {
    PlPlayerController.setPlayCallBack(playCallBack);
  }

  @override
  void updatePlayCount() => PlPlayerController.updatePlayCount();

  @override
  bool dmStateContains(int cid) => _player.dmState.contains(cid);

  @override
  bool get showDmChart => _player.showDmChart;

  @override
  String getCdnUrl(List<String> urls, {bool isAudio = false}) =>
      VideoUtils.getCdnUrl(urls, isAudio: isAudio);
}

/// B站 片段跳过引擎的状态。
class BiliVideoBlockState {
  const BiliVideoBlockState();
}

/// B站 片段跳过引擎（StateNotifier + BlockMixin 的页面级包装）。
class BiliVideoBlockNotifier extends StateNotifier<BiliVideoBlockState>
    with BlockConfigMixin, BlockMixin
    implements VideoBlock {
  BiliVideoBlockNotifier(this._ctr) : super(const BiliVideoBlockState());

  final VideoDetailController _ctr;

  @override
  BlockConfigMixin get blockConfig => this;

  @override
  Future<void> handleSBData(List<Object> list) async {
    final items = list.map((e) {
      if (e is CoreSegmentItemModel) {
        return SegmentItemModel(
          cid: e.cid,
          category: e.category,
          actionType: e.actionType,
          segment: e.segment,
          uuid: e.uuid,
          videoDuration: e.videoDuration,
          votes: e.votes,
        );
      }
      return e as SegmentItemModel;
    }).toList();
    await super.handleSBData(items);
  }

  @override
  Future<void> onSkip(
    Object item, {
    bool isSkip = true,
    bool isSeek = true,
  }) async {
    if (item is SegmentModel) {
      await super.onSkip(item, isSkip: isSkip, isSeek: isSeek);
    }
  }

  @override
  Player? get player => _ctr.plPlayerController.videoPlayerController;

  @override
  bool get autoPlay => _ctr.autoPlay;

  @override
  int? get timeLength => _ctr.timeLength;

  @override
  bool get preInitPlayer => _ctr.preInitPlayer;

  @override
  int get currPosInMilliseconds => _ctr.currPosInMilliseconds;

  @override
  bool get isUgc => _ctr.isUgc;

  @override
  Future<void>? seekTo(Duration duration, {required bool isSeek}) =>
      _ctr.plPlayerController.seekTo(duration, isSeek: isSeek);

  @override
  String? get videoLabel => _ctr.videoLabel;

  @override
  Widget buildItem(Object item, Animation<double> animation) {
    final theme = ThemeUtils.theme;
    return Align(
      alignment: Alignment.centerLeft,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: GestureDetector(
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              if (details.delta.dx < 0) {
                onRemoveItem(listData.indexOf(item), item);
              }
            },
            child: SearchText(
              bgColor: theme.colorScheme.secondaryContainer.withValues(
                alpha: 0.8,
              ),
              textColor: theme.colorScheme.onSecondaryContainer,
              padding: const .symmetric(horizontal: 8, vertical: 4),
              fontSize: 14,
              text: item is SegmentModel
                  ? '跳过: ${item.segmentType.shortTitle}'
                  : '上次看到第${(item as int) + 1}P，点击跳转',
              onTap: (_) {
                if (item is int) {
                  try {
                    final ugcIntroController = appRead(
                      ugcIntroControllerProvider(_ctr.heroTag),
                    );
                    final part = ugcIntroController.videoDetail.pages![item];
                    ugcIntroController.onChangeEpisode(part);
                    SmartDialog.showToast('已跳至第${item + 1}P');
                  } catch (e) {
                    if (kDebugMode) debugPrint('$e');
                    SmartDialog.showToast('跳转失败');
                  }
                  onRemoveItem(listData.indexOf(item), item);
                } else if (item is SegmentModel) {
                  onSkip(item, isSeek: false);
                  onRemoveItem(listData.indexOf(item), item);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    isClosed = true;
    blockListener?.cancel();
    disposeBlock();
    super.dispose();
  }
}

/// B站 片段跳过引擎 Provider。
final biliVideoBlockProvider =
    StateNotifierProvider.family<BiliVideoBlockNotifier, BiliVideoBlockState, VideoDetailController>(
  (ref, controller) => BiliVideoBlockNotifier(controller),
);

/// B站 视频页宿主实现。
class BiliVideoHost implements VideoHost {
  BiliVideoHost() : playerHost = BiliVideoPlayerHost();

  @override
  final VideoPlayerHost playerHost;

  @override
  bool get isLogin => Accounts.main.isLogin;

  @override
  bool get isVideoLogin => Accounts.get(AccountType.video).isLogin;

  @override
  List<VideoDecodeFormatType> get preferCodecs => BiliPref.preferCodecs;

  @override
  CorePlaybackConfig selectPlayback({
    required CorePlayUrlModel data,
    required int? cacheVideoQa,
    required int cacheAudioQa,
  }) {
    final playUrl = playUrlModelFromCore(data);
    final videoList = playUrl.dash!.video!;
    final curHighestVideoQa = videoList.first.quality.code;
    int targetVideoQa = curHighestVideoQa;
    if (playUrl.acceptQuality?.isNotEmpty == true &&
        cacheVideoQa != null &&
        cacheVideoQa <= curHighestVideoQa) {
      targetVideoQa = playUrl.acceptQuality!.findClosestTarget(
        (e) => e <= cacheVideoQa,
        (a, b) => a > b ? a : b,
      );
    }

    final supportFormats = playUrl.supportFormats!;
    // 决策（不修）：decodeFormat 源自 supportFormats（质量元数据）的 codecs 字符串，
    // 而实际流的 dash.video[].codecs 前缀可能与它不完全一致（B站 元数据/流偶发分歧）。
    // 该字段仅用于 UI 显示（header_control 当前解码格式文本 + 切换面板高亮），
    // media_kit 按实际 URL 流自动解码，不依赖此字段——分歧仅影响显示文案，属 minor，记录不修。
    VideoDecodeFormatType decodeFormat = VideoUtils.selectCodec(
      supportFormats
          .firstWhere(
            (e) => e.quality == targetVideoQa,
            orElse: () => supportFormats.first,
          )
          .codecs!,
      preferCodecs,
    );

    final videosList = videoList
        .where((e) => e.quality.code == targetVideoQa)
        .toList();
    final firstVideo = videosList.firstWhere(
      (e) => decodeFormat.codes.any(e.codecs!.startsWith),
      orElse: () => videosList.first,
    );

    final videoUrl = VideoUtils.getCdnUrl(firstVideo.playUrls);

    String audioUrl = '';
    int? audioQaCode;
    final audioList = playUrl.dash?.audio;
    if (audioList != null && audioList.isNotEmpty) {
      final List<int> audioIds = audioList.map((map) => map.id!).toList();
      int closestNumber = audioIds.findClosestTarget(
        (e) => e <= cacheAudioQa,
        (a, b) => a > b ? a : b,
      );
      if (!audioIds.contains(cacheAudioQa) &&
          audioIds.any((e) => e > cacheAudioQa)) {
        closestNumber = AudioQuality.k192.code;
      }
      final firstAudio = audioList.firstWhere(
        (e) => e.id == closestNumber,
        orElse: () => audioList.first,
      );
      audioUrl = VideoUtils.getCdnUrl(firstAudio.playUrls, isAudio: true);
      audioQaCode = firstAudio.id;
    }

    return CorePlaybackConfig(
      videoUrl: videoUrl,
      audioUrl: audioUrl,
      videoQaCode: targetVideoQa,
      audioQaCode: audioQaCode,
      decodeFormat: decodeFormat,
      width: firstVideo.width,
      height: firstVideo.height,
    );
  }

  @override
  VideoBlock createBlock(VideoDetailController controller) =>
      BiliVideoBlockNotifier(controller);

  @override
  void reportVideo(int aid) => PageUtils.reportVideo(aid);

  @override
  Future<void> onVideoDetailDispose(String heroTag) async {
    videoPlayerServiceHandler?.onVideoDetailDispose(heroTag);
  }

  // ---------- 简介控制器管理 ----------

  void _ensureIntroController(String heroTag) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    if (ctr.isFileSource) {
      appRead(localIntroControllerProvider(heroTag));
    } else if (ctr.isUgc) {
      appRead(ugcIntroControllerProvider(heroTag));
    } else {
      appRead(pgcIntroControllerProvider(heroTag));
    }
  }

  CommonIntroController _introController(String heroTag) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    if (ctr.isFileSource) {
      return appRead(localIntroControllerProvider(heroTag));
    }
    if (ctr.isUgc) {
      return appRead(ugcIntroControllerProvider(heroTag));
    }
    return appRead(pgcIntroControllerProvider(heroTag));
  }

  // ---------- 播放器 / 覆盖层 ----------

  @override
  Widget buildPlayer({
    required String heroTag,
    required double width,
    required double height,
    bool isPipMode = false,
    required bool isPortrait,
  }) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    _ensureIntroController(heroTag);
    final player = ctr.plPlayerController as PlPlayerController;
    final introCtr = _introController(heroTag);
    return PLVideoPlayer(
      maxWidth: width,
      maxHeight: height,
      plPlayerController: player,
      videoDetailController: ctr,
      introController: introCtr,
      headerControl: HeaderControl(
        key: ctr.headerCtrKey,
        isPortrait: isPortrait,
        controller: player,
        videoDetailCtr: ctr,
        heroTag: heroTag,
      ),
      danmuWidget: isPipMode && player.pipNoDanmaku
          ? null
          : ListenableBuilder(
              listenable: player,
              builder: (_, _) => PlDanmaku(
                key: ValueKey(ctr.cid),
                isPipMode: isPipMode,
                cid: ctr.cid,
                playerController: player,
                isFullScreen: player.isFullScreen,
                isFileSource: ctr.isFileSource,
                size: Size(width, height),
              ),
            ),
      showEpisodes: ([int? index, UgcSeason? season, List<ugc.BaseEpisodeItem>? episodes, String? bvid, int? aid, int? cid]) =>
          showEpisodes(heroTag, index: index, season: season, episodes: episodes, bvid: bvid, aid: aid, cid: cid),
      showViewPoints: () => showViewPoints(heroTag),
    );
  }

  @override
  List<Widget> buildPlayerOverlays({
    required String heroTag,
    required bool isFullScreen,
    required double maxHeight,
  }) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    final context = AppNavigator.context!;
    final widgets = <Widget>[];
    if (ctr.enableBlock || ctr.continuePlayingPart) {
      widgets.add(
        Positioned(
          left: 16,
          bottom: isFullScreen ? max(75, maxHeight * 0.25) : 75,
          width: MediaQuery.textScalerOf(context).scale(120),
          child: AnimatedList(
            padding: EdgeInsets.zero,
            key: ctr.listKey,
            reverse: true,
            shrinkWrap: true,
            initialItemCount: ctr.listData.length,
            itemBuilder: (context, index, animation) {
              return ctr.buildItem(ctr.listData[index], animation);
            },
          ),
        ),
      );
    }
    widgets.add(
      ListenableBuilder(
        listenable: ctr,
        builder: (context, _) {
          if (!ctr.showSteinEdgeInfo) {
            return const SizedBox.shrink();
          }
          return _buildSteinEdges(ctr, heroTag, context);
        },
      ),
    );
    return widgets;
  }

  Widget _buildSteinEdges(
    VideoDetailController ctr,
    String heroTag,
    BuildContext context,
  ) {
    final player = ctr.plPlayerController;
    final themeData = player.darkVideoPage ? ThemeUtils.darkTheme : Theme.of(context);
    final edge = _steinEdgeInfo[heroTag];
    try {
      if (edge?.edges?.questions?.firstOrNull?.choices?.isNotEmpty != true) {
        return const SizedBox.shrink();
      }
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: player.showControls ? 75 : 16,
          ),
          child: Wrap(
            spacing: 25,
            runSpacing: 10,
            children: edge!.edges!.questions!.first.choices!
                .map((item) {
                  return FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: .all(.circular(6)),
                      ),
                      backgroundColor:
                          themeData.colorScheme.secondaryContainer.withValues(
                        alpha: 0.8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      appRead(ugcIntroControllerProvider(heroTag)).onChangeEpisode(item, isStein: true);
                      ctr.getSteinEdgeInfo(item.id);
                    },
                    child: Text(item.option!),
                  );
                })
                .toList(),
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('build stein edges: $e');
      return const SizedBox.shrink();
    }
  }

  @override
  Widget? buildKeyboardFocus({
    required Widget child,
    required String heroTag,
    required VoidCallback onSendDanmaku,
    required bool Function() canPlay,
    required bool Function() onSkipSegment,
  }) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    return PlayerFocus(
      plPlayerController: ctr.plPlayerController as PlPlayerController,
      introController: _introController(heroTag),
      onSendDanmaku: onSendDanmaku,
      canPlay: canPlay,
      onSkipSegment: onSkipSegment,
      child: child,
    );
  }

  @override
  void showSettingSheet(GlobalKey headerKey) {
    (headerKey.currentState as HeaderControlState?)?.showSettingSheet();
  }

  // ---------- 简介 / 选集 / 回复 ----------

  @override
  Widget buildLocalIntroPanel({required Key key, required String heroTag}) {
    _ensureIntroController(heroTag);
    return LocalIntroPanel(key: key, heroTag: heroTag);
  }

  @override
  Widget buildUgcIntroPanel({
    required Key key,
    required String heroTag,
    required bool isPortrait,
    required bool isHorizontal,
  }) {
    _ensureIntroController(heroTag);
    return UgcIntroPanel(
      key: key,
      heroTag: heroTag,
      showAiBottomSheet: () => showAiBottomSheet(heroTag),
      showEpisodes: ([int? index, UgcSeason? season, List<ugc.BaseEpisodeItem>? episodes, String? bvid, int? aid, int? cid]) =>
          showEpisodes(heroTag, index: index, season: season, episodes: episodes, bvid: bvid, aid: aid, cid: cid),
      onShowMemberPage: (mid) => showMemberPage(heroTag, mid),
      isPortrait: isPortrait,
      isHorizontal: isHorizontal,
    );
  }

  @override
  Widget buildRelatedPanel({required Key key, required String heroTag}) =>
      RelatedVideoPanel(key: key, heroTag: heroTag);

  @override
  Widget buildPgcIntroPage({
    required Key key,
    required String heroTag,
    required int cid,
    required double maxWidth,
    required bool isLandscape,
  }) {
    _ensureIntroController(heroTag);
    return PgcIntroPage(
      key: key,
      heroTag: heroTag,
      cid: cid,
      showEpisodes: () => showEpisodes(heroTag),
      showIntroDetail: (videoDetail, videoTags) =>
          showIntroDetail(heroTag, videoDetail, videoTags),
      maxWidth: maxWidth,
      isLandscape: isLandscape,
    );
  }

  @override
  Widget buildSeasonPanel({required String heroTag}) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    final ugcIntroCtr = appRead(ugcIntroControllerProvider(heroTag));
    final videoDetail = ugcIntroCtr.videoDetail;
    return KeepAliveWrapper(
      child: Column(
        children: [
          if ((videoDetail.pages?.length ?? 0) > 1)
            if (videoDetail.ugcSeason != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: PagesPanel(
                  heroTag: heroTag,
                  ugcIntroController: ugcIntroCtr,
                  bvid: ugcIntroCtr.bvid,
                  showEpisodes: () => showEpisodes(heroTag),
                ),
              )
            else
              Expanded(
              child: ListenableBuilder(
                listenable: ctr,
                builder: (context, _) => EpisodePanel(
                    heroTag: heroTag,
                    enableSlide: false,
                    ugcIntroController: ctr.isUgc ? ugcIntroCtr : null,
                    type: EpisodeType.part,
                    list: [videoDetail.pages!],
                    cover: ctr.cover,
                    bvid: ctr.bvid,
                    aid: ctr.aid,
                    cid: ctr.cid,
                    isReversed: videoDetail.isPageReversed,
                    onChangeEpisode: ctr.isUgc
                        ? ugcIntroCtr.onChangeEpisode
                        : appRead(pgcIntroControllerProvider(heroTag)).onChangeEpisode,
                    showTitle: false,
                    isSupportReverse: ctr.isUgc,
                    onReverse: () => onReversePlay(heroTag, isSeason: false),
                  ),
                ),
              ),
          if (videoDetail.ugcSeason != null) ...[
            if ((videoDetail.pages?.length ?? 0) > 1) ...[
              const SizedBox(height: 8),
              Divider(
                height: 1,
                color: Theme.of(AppNavigator.context!).colorScheme.outline.withValues(
                  alpha: 0.1,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListenableBuilder(
                listenable: ugcIntroCtr,
                builder: (context, _) => SeasonPanel(
                  key: ValueKey(ugcIntroCtr.videoDetail),
                  heroTag: heroTag,
                  canTap: false,
                  showEpisodes: () => showEpisodes(heroTag),
                  ugcIntroController: ugcIntroCtr,
                ),
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: ctr,
                builder: (context, _) => EpisodePanel(
                  heroTag: heroTag,
                  enableSlide: false,
                  ugcIntroController: ctr.isUgc ? ugcIntroCtr : null,
                  type: EpisodeType.season,
                  initialTabIndex: ctr.seasonIndex,
                  cover: ctr.cover,
                  seasonId: videoDetail.ugcSeason!.id,
                  list: videoDetail.ugcSeason!.sections!,
                  bvid: ctr.bvid,
                  aid: ctr.aid,
                  cid: ctr.seasonCid ?? 0,
                  isReversed: ugcIntroCtr
                      .videoDetail
                      .ugcSeason!
                      .sections![ctr.seasonIndex]
                      .isReversed,
                  onChangeEpisode: ctr.isUgc
                      ? ugcIntroCtr.onChangeEpisode
                      : appRead(pgcIntroControllerProvider(heroTag)).onChangeEpisode,
                  showTitle: false,
                  isSupportReverse: ctr.isUgc,
                  onReverse: () => onReversePlay(heroTag, isSeason: true),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildReplyPanel({required Key key, required String heroTag, bool isNested = false}) {
    _ensureReplyController(heroTag);
    return VideoReplyPanel(key: key, isNested: isNested, heroTag: heroTag);
  }

  void _ensureReplyController(String heroTag) {
    appRead(videoReplyControllerProvider(heroTag));
  }

  @override
  Widget buildReplyTabLabel({required String heroTag}) {
    _ensureReplyController(heroTag);
    return ListenableBuilder(
      listenable: appRead(videoReplyControllerProvider(heroTag)),
      builder: (context, _) {
        final ctr = appRead(videoReplyControllerProvider(heroTag));
        return Text('评论${ctr.count == -1 ? '' : ' ${NumUtils.numFormat(ctr.count)}'}');
      });
  }

  @override
  void animateReplyToTop(String heroTag) {
    // exists = 已初始化才通知，避免读 provider 时惰性创建控制器。
    if (appContainer.exists(videoReplyControllerProvider(heroTag))) {
      appRead(videoReplyControllerProvider(heroTag)).animateToTop();
    }
  }

  @override
  bool shouldShowSeasonPanel(String heroTag, {required bool isPortrait}) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    if (ctr.isFileSource || isPortrait || !ctr.isUgc) {
      return false;
    }
    final videoDetail = appRead(ugcIntroControllerProvider(heroTag)).videoDetail;
    return ctr.plPlayerController.horizontalSeasonPanel &&
        (videoDetail.ugcSeason != null ||
            ((videoDetail.pages?.length ?? 0) > 1));
  }

  // ---------- 弹幕 / 简介控制 ----------

  @override
  Future<void> showShootDanmakuSheet({
    required String heroTag,
    required String bvid,
    required int cid,
    required int progress,
    String? initialValue,
    void Function(String?)? onSave,
    ({int? mode, int? fontSize, Color? color})? dmConfig,
    ValueChanged<({int mode, int fontSize, Color color})>? onSaveDmConfig,
  }) async {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    final player = ctr.plPlayerController as PlPlayerController;
    await AppNavigator.push(
      PublishRoute(
        pageBuilder: (buildContext, animation, secondaryAnimation) {
          final child = SendDanmakuPanel(
            cid: cid,
            bvid: bvid,
            progress: progress,
            initialValue: initialValue,
            onSave: onSave,
            onSuccess: (danmakuModel) {
              // 发送成功后清空草稿（旧 controller 行为：savedDanmaku = null）。
              ctr.savedDanmaku = null;
              player.danmakuController?.addDanmaku(danmakuModel);
            },
            dmConfig: dmConfig,
            onSaveDmConfig: onSaveDmConfig,
          );
          return player.darkVideoPage
              ? Theme(data: ThemeUtils.darkTheme, child: child)
              : child;
        },
      ),
    );
  }

  @override
  void startIntroTimer(String heroTag) {
    try {
      _introController(heroTag).startTimer();
    } catch (_) {}
  }

  @override
  void cancelIntroTimer(String heroTag) {
    try {
      _introController(heroTag).cancelTimer();
    } catch (_) {}
  }

  @override
  void disposeIntro(String heroTag) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    try {
      if (ctr.isUgc) {
        appRead(ugcIntroControllerProvider(heroTag))
          ..cancelTimer()
          ..videoDetail;
      } else {
        appRead(pgcIntroControllerProvider(heroTag)).cancelTimer();
      }
    } catch (_) {}
  }

  @override
  bool nextPlay(String heroTag) {
    try {
      return _introController(heroTag).nextPlay();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> viewLater(String heroTag) async {
    try {
      await _introController(heroTag).viewLater();
    } catch (_) {}
  }

  // ---------- 底部弹层 / 页面动作 ----------

  @override
  void showMediaListPanel(BuildContext context, String heroTag) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    if (ctr.mediaList.isEmpty) {
      ctr.getMediaList();
      return;
    }
    final mediaList = ctr.mediaList
        .map(
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
        )
        .toList()
        ;
    Widget panel() => MediaListPanel(
      mediaList: mediaList,
      onChangeEpisode: (episode) {
        try {
          appRead(ugcIntroControllerProvider(heroTag)).onChangeEpisode(episode);
        } catch (_) {}
      },
      panelTitle: ctr.watchLaterTitle,
      bvid: ctr.bvid,
      count: ctr.args['count'],
      loadMoreMedia: ctr.getMediaList,
      desc: ctr.mediaDesc,
      onReverse: () => ctr
        ..toggleMediaDesc()
        ..getMediaList(isReverse: true),
      loadPrevious: ctr.args['isContinuePlaying'] == true
          ? () => ctr.getMediaList(isLoadPrevious: true)
          : null,
      onDelete:
          isWatchLaterSource(ctr.args['sourceType']) ||
              (isFavSource(ctr.args['sourceType']) && ctr.args['isOwner'] == true)
          ? (item, index) async {
              if (isWatchLaterSource(ctr.args['sourceType'])) {
                final res = await appRead(userRepositoryProvider).toViewDel(
                  aids: item.aid.toString(),
                );
                if (res.isSuccess) {
                  ctr.mediaList.removeAt(index);
                }
              } else {
                final res = await appRead(favRepositoryProvider).favVideo(
                  resources: '${item.aid}:${item.type}',
                  delIds: '${ctr.args['mediaId']}',
                );
                if (res.isSuccess) {
                  ctr.mediaList.removeAt(index);
                  SmartDialog.showToast('取消收藏');
                } else {
                  res.toast();
                }
              }
            }
          : null,
    );
    if (ctr.plPlayerController.isFullScreen || ctr.showVideoSheet) {
      PageUtils.showVideoBottomSheet(
        context,
        child: ctr.plPlayerController.darkVideoPage
            ? Theme(data: ThemeUtils.darkTheme, child: panel())
            : panel(),
      );
    } else {
      ctr.childKey.currentState?.showBottomSheet(
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(),
        (context) => panel(),
      );
    }
  }

  @override
  void showNoteList(BuildContext context, String heroTag) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    String? title;
    try {
      title = appRead(ugcIntroControllerProvider(heroTag)).videoDetail.title;
    } catch (_) {}
    final child = NoteListPage(
      oid: ctr.aid,
      enableSlide: false,
      heroTag: heroTag,
      isStein: ctr.graphVersion != null,
      title: title,
    );
    if (ctr.plPlayerController.isFullScreen || ctr.showVideoSheet) {
      PageUtils.showVideoBottomSheet(
        context,
        child: ctr.plPlayerController.darkVideoPage
            ? Theme(data: ThemeUtils.darkTheme, child: child)
            : child,
      );
    } else {
      ctr.childKey.currentState?.showBottomSheet(
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(),
        (context) => NoteListPage(
          oid: ctr.aid,
          heroTag: heroTag,
          isStein: ctr.graphVersion != null,
          title: title,
        ),
      );
    }
  }

  @override
  Future<void> showDownloadPanel(BuildContext context, String heroTag) async {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    VideoDetailData? videoDetail;
    List<ugc.BaseEpisodeItem>? episodes;
    UgcIntroController? ugcIntroController;
    PgcInfoModel? pgcItem;
    if (ctr.isUgc) {
      try {
        ugcIntroController = appRead(ugcIntroControllerProvider(heroTag));
        videoDetail = ugcIntroController.videoDetail;
        if (videoDetail.ugcSeason?.sections case final sections?) {
          episodes = <ugc.BaseEpisodeItem>[];
          for (final i in sections) {
            if (i.episodes case final e?) {
              episodes.addAll(e);
            }
          }
        } else {
          episodes = videoDetail.pages;
        }
      } catch (e, s) {
        if (kDebugMode) {
          debugPrint('download ugc: $e\n\n$s');
        }
      }
    } else {
      try {
        pgcItem = appRead(pgcIntroControllerProvider(heroTag)).pgcItem;
        episodes = pgcItem.episodes;
      } catch (e, s) {
        if (kDebugMode) {
          debugPrint('download pgc: $e\n\n$s');
        }
      }
    }
    if (episodes == null || episodes.isEmpty) {
      return;
    }
    final downloadService = appRead(downloadServiceProvider);
    await downloadService.waitForInitialization;
    if (!context.mounted) {
      return;
    }
    final Set<int> cidSet = downloadService.downloadList
        .followedBy(downloadService.waitDownloadQueue)
        .map((e) => e.cid)
        .toSet();
    final index = episodes.indexWhere(
      (e) => e.cid == (ctr.seasonCid ?? ctr.cid),
    );

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: min(640, context.mediaQueryShortestSide),
      ),
      builder: (context) {
        final maxChildSize =
            PlatformUtils.isMobile && !context.mediaQuerySize.isPortrait
            ? 1.0
            : 0.7;
        return DraggableScrollableSheet(
          snap: true,
          expand: false,
          minChildSize: 0,
          snapSizes: [maxChildSize],
          maxChildSize: maxChildSize,
          initialChildSize: maxChildSize,
          builder: (context, scrollController) => DownloadPanel(
            index: index,
            videoDetail: videoDetail,
            pgcItem: pgcItem,
            episodes: episodes!,
            scrollController: scrollController,
            videoDetailController: ctr,
            heroTag: heroTag,
            ugcIntroController: ugcIntroController,
            cidSet: cidSet,
          ),
        );
      },
    );
  }

  @override
  void openAudioPage(String heroTag) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    final args = ctr.args;
    int? id;
    int? extraId;
    PlaylistSource from = PlaylistSource.UP_ARCHIVE;
    final rawSource = args['sourceType'];
    if (ctr.isPlayAll) {
      id = args['mediaId'];
      extraId = rawSource is SourceType ? rawSource.extraId : null;
      from = rawSource is SourceType
          ? (rawSource.playlistSource ?? PlaylistSource.UP_ARCHIVE)
          : PlaylistSource.UP_ARCHIVE;
    } else if (ctr.isUgc) {
      try {
        final introCtr = appRead(ugcIntroControllerProvider(heroTag));
        id = introCtr.videoDetail.ugcSeason?.id;
        if (id != null) {
          extraId = 8;
          from = PlaylistSource.MEDIA_LIST;
        }
      } catch (_) {}
    }
    AudioPage.toAudioPage(
      itemType: 1,
      id: id,
      oid: ctr.aid,
      subId: [ctr.cid],
      from: from.value,
      heroTag: ctr.autoPlay ? heroTag : null,
      start: ctr.playedTime,
      audioUrl: ctr.audioUrl,
      extraId: extraId,
    );
  }

  @override
  void onBlock(BuildContext context, String heroTag) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    if (ctr.postList.isEmpty) {
      ctr.postList.add(
        CorePostSegmentModel(
          segment: CoreDoublePair(
            first: 0,
            second: ctr.plPlayerController.positionInMilliseconds / 1000,
          ),
          category: CoreSegmentType.sponsor,
          actionType: CoreActionType.skip,
        ),
      );
    }
    final child = PostPanel(
      enableSlide: false,
      videoDetailController: ctr,
      plPlayerController: ctr.plPlayerController as PlPlayerController,
    );
    if (ctr.plPlayerController.isFullScreen || ctr.showVideoSheet) {
      PageUtils.showVideoBottomSheet(
        context,
        child: ctr.plPlayerController.darkVideoPage
            ? Theme(data: ThemeUtils.darkTheme, child: child)
            : child,
      );
    } else {
      ctr.childKey.currentState?.showBottomSheet(
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(),
        (context) => PostPanel(
          videoDetailController: ctr,
          plPlayerController: ctr.plPlayerController as PlPlayerController,
        ),
      );
    }
  }

  @override
  void showSBDetail(String heroTag) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    ctr.block.showSBDetail();
  }

  // ---------- 选集 / 视角点 / AI / 成员页（内部接线） ----------

  void showEpisodes(
    String heroTag, {
    int? index,
    UgcSeason? season,
    List<ugc.BaseEpisodeItem>? episodes,
    String? bvid,
    int? aid,
    int? cid,
  }) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    assert((cid == null) == (bvid == null));
    if (cid == null) {
      ctr.showMediaListPanel(AppNavigator.context!);
      return;
    }
    Widget listSheetContent({bool enableSlide = true}) => EpisodePanel(
      heroTag: heroTag,
      ugcIntroController: ctr.isUgc
          ? appRead(ugcIntroControllerProvider(heroTag))
          : null,
      type: season != null
          ? EpisodeType.season
          : episodes is List<Part>
          ? EpisodeType.part
          : EpisodeType.pgc,
      cover: ctr.cover,
      enableSlide: enableSlide,
      initialTabIndex: index ?? 0,
      bvid: bvid!,
      aid: aid,
      cid: cid,
      seasonId: season?.id,
      list: season != null ? season.sections! : [episodes],
      isReversed: !ctr.isUgc
          ? null
          : season != null
          ? appRead(ugcIntroControllerProvider(heroTag))
                .videoDetail
                .ugcSeason!
                .sections![ctr.seasonIndex]
                .isReversed
          : appRead(ugcIntroControllerProvider(heroTag)).videoDetail.isPageReversed,
      isSupportReverse: ctr.isUgc,
      onChangeEpisode: ctr.isUgc
          ? appRead(ugcIntroControllerProvider(heroTag)).onChangeEpisode
          : appRead(pgcIntroControllerProvider(heroTag)).onChangeEpisode,
      onClose: AppNavigator.back,
      onReverse: () {
        AppNavigator.back();
        onReversePlay(heroTag, isSeason: season != null);
      },
    );
    final isFullScreen = ctr.plPlayerController.isFullScreen;
    if (isFullScreen || ctr.showVideoSheet) {
      final child = listSheetContent(enableSlide: false);
      PageUtils.showVideoBottomSheet(
        AppNavigator.context!,
        child: ctr.plPlayerController.darkVideoPage
            ? Theme(data: ThemeUtils.darkTheme, child: child)
            : child,
      );
    } else {
      ctr.childKey.currentState?.showBottomSheet(
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(),
        (context) => listSheetContent(),
      );
    }
  }

  void showViewPoints(String heroTag) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    final player = ctr.plPlayerController as PlPlayerController;
    final child = ViewPointsPage(
      enableSlide: false,
      videoDetailController: ctr,
      plPlayerController: player,
    );
    if (player.isFullScreen || ctr.showVideoSheet) {
      PageUtils.showVideoBottomSheet(
        AppNavigator.context!,
        child: player.darkVideoPage
            ? Theme(data: ThemeUtils.darkTheme, child: child)
            : child,
      );
    } else {
      ctr.childKey.currentState?.showBottomSheet(
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(),
        (context) => ViewPointsPage(
          videoDetailController: ctr,
          plPlayerController: player,
        ),
      );
    }
  }

  void showAiBottomSheet(String heroTag) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    final aiConclusionResult = appRead(ugcIntroControllerProvider(heroTag)).aiConclusionResult;
    ctr.childKey.currentState?.showBottomSheet(
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(),
      (context) =>
          AiConclusionPanel(item: AiConclusionResult.fromJson(aiConclusionResult!)),
    );
  }

  void showIntroDetail(
    String heroTag,
    PgcInfoModel videoDetail,
    List<VideoTagItem>? videoTags,
  ) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    ctr.childKey.currentState?.showBottomSheet(
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(),
      (context) => PgcIntroPanel(
        item: videoDetail,
        videoTags: videoTags,
      ),
    );
  }

  void showMemberPage(String heroTag, int? mid) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    final ugcIntroCtr = appRead(ugcIntroControllerProvider(heroTag));
    ctr.childKey.currentState?.showBottomSheet(
      shape: const RoundedRectangleBorder(),
      constraints: const BoxConstraints(),
      (context) {
        return HorizontalMemberPage(
          mid: mid,
          videoDetailController: ctr,
          ugcIntroController: ugcIntroCtr,
        );
      },
    );
  }

  void onReversePlay(String heroTag, {required bool isSeason}) {
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    if (isSeason && ctr.isPlayAll) {
      SmartDialog.showToast('当前为播放全部，合集不支持倒序');
      return;
    }

    final videoDetail = appRead(ugcIntroControllerProvider(heroTag)).videoDetail;
    if (isSeason) {
      final item = videoDetail
          .ugcSeason!
          .sections![ctr.seasonIndex];
      item
        ..isReversed = !item.isReversed
        ..episodes = item.episodes!.reversed.toList();

      if (!ctr.plPlayerController.reverseFromFirst) {
        ctr.notifyChange();
      } else {
        final episode = appRead(ugcIntroControllerProvider(heroTag))
            .videoDetail
            .ugcSeason!
            .sections![ctr.seasonIndex]
            .episodes!
            .first;
        if (episode.cid != ctr.cid) {
          appRead(ugcIntroControllerProvider(heroTag)).onChangeEpisode(episode);
          ctr.seasonCid = episode.cid;
        } else {
          ctr.notifyChange();
        }
      }
    } else {
      videoDetail
        ..isPageReversed = !videoDetail.isPageReversed
        ..pages = videoDetail.pages!.reversed.toList();
      if (!ctr.plPlayerController.reverseFromFirst) {
        ctr.notifyChange();
      } else {
        final episode = videoDetail.pages!.first;
        if (episode.cid != ctr.cid) {
          appRead(ugcIntroControllerProvider(heroTag)).onChangeEpisode(episode);
        } else {
          ctr.notifyChange();
        }
      }
    }
  }

  // ---------- 互动视频 / 高能进度条 / 字幕 ----------

  final Map<String, EdgeInfoData> _steinEdgeInfo = {};

  @override
  Future<bool> getSteinEdgeInfo({
    required String heroTag,
    required String bvid,
    required int? graphVersion,
    int? edgeId,
  }) async {
    _steinEdgeInfo.remove(heroTag);
    try {
      final res = await Request().get(
        '/x/stein/edgeinfo_v2',
        queryParameters: {
          'bvid': bvid,
          'graph_version': graphVersion,
          'edge_id': ?edgeId,
        },
      );
      if (res.data['code'] == 0) {
        final edge = EdgeInfoData.fromJson(res.data['data']);
        _steinEdgeInfo[heroTag] = edge;
        return edge.edges?.questions?.firstOrNull?.choices?.isNotEmpty == true;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('getSteinEdgeInfo: $e');
    }
    return false;
  }

  @override
  Future<LoadingState<List<double>>> fetchDmTrend({
    required String bvid,
    required int cid,
  }) async {
    try {
      final res = await Request().get(
        'https://bvc.bilivideo.com/pbp/data',
        queryParameters: {
          'bvid': bvid,
          'cid': cid,
        },
      );
      final data = PbpData.fromJson(res.data);
      final stepSec = data.stepSec ?? 0;
      if (stepSec != 0 && data.events?.eDefault?.isNotEmpty == true) {
        return Success(data.events!.eDefault!);
      }
      return const Error(null);
    } catch (e) {
      if (kDebugMode) debugPrint('fetchDmTrend: $e');
      return const Error(null);
    }
  }

  @override
  Future<List<VideoSubtitleItem>?> fetchDmSubtitles({
    required int aid,
    required int cid,
  }) async {
    final res = await dm_grpc.DmGrpc.dmView(aid, cid);
    if (res case Success(:final response)) {
      if (response.hasSubtitle() && response.subtitle.subtitles.isNotEmpty) {
        return response.subtitle.subtitles
            .map(
              (i) => VideoSubtitleItem(
                lan: i.lan,
                lanDoc: i.lanDoc,
                subtitleUrl: i.subtitleUrl.replaceFirst(
                  RegExp('^https?:'),
                  '',
                ),
                isAi: i.type == .AI,
              ),
            )
            .toList();
      }
    }
    return null;
  }

  // ---------- 来源参数辅助 ----------

  @override
  bool isWatchLaterSource(Object? sourceType) =>
      sourceType == SourceType.watchLater;

  @override
  bool isFavSource(Object? sourceType) => sourceType == SourceType.fav;

  @override
  int sourceMediaType(Object? sourceType) =>
      sourceType is SourceType ? (sourceType.mediaType ?? -1) : -1;

  @override
  bool isFileSourceSource(Object? sourceType) => sourceType == SourceType.file;

  @override
  bool isPlayAllSource(Object? sourceType) =>
      sourceType is SourceType && sourceType != SourceType.normal && sourceType != SourceType.file;

  @override
  ({int width, int height})? partDimension(String heroTag, int cid) {
    try {
      final part = appRead(ugcIntroControllerProvider(heroTag))
          .videoDetail
          .pages
          ?.firstWhereOrNull((e) => e.cid == cid);
      final dimension = part?.dimension;
      if (dimension?.width == null || dimension?.height == null) {
        return null;
      }
      return (width: dimension!.width!, height: dimension.height!);
    } catch (_) {
      return null;
    }
  }

  @override
  void applyPgcClipInfo(String heroTag, List<Map<String, dynamic>>? clipInfoList) {
    if (clipInfoList == null || clipInfoList.isEmpty) {
      return;
    }
    final ctr = appRead(videoDetailControllerProvider(heroTag));
    ctr.block
      ..resetBlock()
      ..handleSBData(
        clipInfoList
            .map(
              (e) => _coreSegmentItem(
                SegmentItemModel.fromPgcJson(e, ctr.timeLength),
              ),
            )
            .toList(),
      );
  }

  @override
  void applyContinuePlayingPart(String heroTag, {
    required int? lastPlayCid,
    required int currentCid,
  }) {
    if (lastPlayCid == null || lastPlayCid == 0 || lastPlayCid == currentCid) {
      return;
    }
    try {
      final pages = appRead(ugcIntroControllerProvider(heroTag))
          .videoDetail
          .pages;
      if (pages != null && pages.length > 1) {
        final index = pages.indexWhere((item) => item.cid == lastPlayCid);
        if (index != -1) {
          appRead(videoDetailControllerProvider(heroTag)).block.onAddItem(index);
        }
      }
    } catch (_) {}
  }

  @override
  bool isSteinGate(String heroTag) {
    try {
      return appRead(ugcIntroControllerProvider(heroTag))
          .videoDetail
          .rights
          ?.isSteinGate == 1;
    } catch (_) {
      return false;
    }
  }

  @override
  String? videoTitle(String heroTag) {
    try {
      return appRead(ugcIntroControllerProvider(heroTag))
          .videoDetail
          .title;
    } catch (_) {
      try {
        return appRead(pgcIntroControllerProvider(heroTag))
            .videoDetail
            .title;
      } catch (_) {
        return null;
      }
    }
  }

  @override
  void onChangeEpisodeFromMedia(String heroTag, CoreMediaListItemModel item) {
    appRead(ugcIntroControllerProvider(heroTag)).onChangeEpisode(
      MediaListItemModel(
        aid: item.aid,
        bvid: item.bvid,
        cover: item.cover,
        title: item.title,
        type: item.type,
        badge: item.badge,
        intro: item.intro,
        duration: item.duration,
      ),
    );
  }

  @override
  CoreFileEntryInfo? fileEntryInfo(Object? entry) {
    if (entry is! BiliDownloadEntryInfo) {
      return null;
    }
    return CoreFileEntryInfo(
      preferedVideoQuality: entry.preferedVideoQuality,
      width: entry.ep?.width ?? entry.pageData?.width,
      height: entry.ep?.height ?? entry.pageData?.height,
      totalTimeMilli: entry.totalTimeMilli,
      typeTag: entry.typeTag,
      mediaType: entry.mediaType,
      hasDashAudio: entry.hasDashAudio,
    );
  }

  @override
  bool get isShutdownTimerWaiting => shutdownTimerService.isWaiting;

  @override
  void handleShutdownTimer() => shutdownTimerService.handleWaiting();
}
