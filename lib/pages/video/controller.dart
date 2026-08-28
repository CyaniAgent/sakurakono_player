import 'dart:async';
import 'dart:ui';

import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/progress_bar/segment_progress_bar.dart';
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/video/video_host.dart';
import 'package:skf/pages/video/video_models.dart';
import 'package:skf/player/models/data_source.dart';
import 'package:skf/player/models/heart_beat_type.dart';
import 'package:skf/player/models/play_status.dart';
import 'package:skf/player/player_controller.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/connectivity_utils.dart';
import 'package:skf/utils/extension/nested_scroll_ext.dart';
import 'package:skf/utils/extension/num_ext.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    show ExtendedNestedScrollViewState;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:hive_ce/hive.dart';
import 'package:media_kit/media_kit.dart' hide Subtitle;
import 'package:skf/core/container/app_container.dart';

/// 视频播放详情页控制器（通用层，零适配器依赖）。
///
/// 播放器/弹幕/回复/简介/下载等 B站 专属能力通过 [VideoHost] 注入，
/// 数据层使用 core [VideoRepository] 等仓库接口。
class VideoDetailController extends ChangeNotifier {
  /// 路由传参
  final TickerProvider? _vsync;
  bool _isDisposed = false;
  bool get isClosed => _isDisposed;

  VideoDetailController({this._vsync});

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) {}
  late final Map args;
  late String bvid;
  late int aid;
  late final RxInt cid;
  int? epId;
  int? seasonId;
  int? pgcType;
  late final String heroTag;
  late final RxString cover;

  // 视频类型 默认投稿视频
  late final CoreVideoType videoType;
  late final isUgc = videoType == CoreVideoType.ugc;
  CoreVideoType? _actualVideoType;

  // 页面来源 稍后再看 收藏夹
  late bool isPlayAll;
  late bool isFileSource;
  bool _mediaDesc = false;
  late List<CoreMediaListItemModel> mediaList = [];
  late String watchLaterTitle;

  /// tabs相关配置
  late TabController tabCtr;

  // 请求返回的视频信息
  late CorePlayUrlModel data;
  bool videoState = false;

  /// 播放器配置 画质 音质 解码格式
  final Rxn<VideoQuality> currentVideoQa = Rxn<VideoQuality>();
  AudioQuality? currentAudioQa;
  late VideoDecodeFormatType currentDecodeFormats;

  // 是否开始自动播放 存在多p的情况下，第二p需要为true
  bool _autoPlay = Pref.autoPlayEnable;

  final videoPlayerKey = GlobalKey();
  final childKey = GlobalKey<ScaffoldState>();

  /// B站 扩展播放器（经 VideoHost 注入，实际为 PlPlayerController）。
  late final PlayerController plPlayerController =
      VideoHost.of().playerHost.acquirePlayer();
  bool get setSystemBrightness => plPlayerController.setSystemBrightness;

  /// Public notify wrapper — [notifyListeners] is protected in
  /// [ChangeNotifier]; external code (Host implementations) uses this.
  void notifyChange() => notifyListeners();
  bool get removeSafeArea => plPlayerController.removeSafeArea;
  double get uiScale => plPlayerController.uiScale;

  /// 片段跳过引擎（B站 BlockMixin 页面级包装）。
  late final VideoBlock block = VideoHost.of().createBlock(this);

  int? firstVideoWidth;
  int? firstVideoHeight;
  int? firstVideoQaCode;
  String? videoUrl;
  String? audioUrl;
  Duration? defaultST;
  Duration? playedTime;
  String get playedTimePos {
    final pos = playedTime?.inMilliseconds;
    return pos == null || pos == 0 ? '' : '?t=${pos / 1000}';
  }

  // 亮度
  double? brightness;

  late final headerCtrKey = GlobalKey();

  Box setting = GStorage.setting;

  bool get showReply => isFileSource
      ? false
      : isUgc
      ? plPlayerController.showVideoReply
      : plPlayerController.showBangumiReply;

  bool get showRelatedVideo =>
      isFileSource ? false : plPlayerController.showRelatedVideo;

  ScrollController? introScrollCtr;
  ScrollController get effectiveIntroScrollCtr =>
      introScrollCtr ??= ScrollController();

  int? seasonCid;
  late int seasonIndex = 0;

  PlayerStatus? playerStatus;

  late final scrollKey = GlobalKey<ExtendedNestedScrollViewState>();
  late final RxBool isVertical;
  late double scrollRatio = 0.0;

  ScrollController? _scrollCtr;
  ScrollController get scrollCtr => _scrollCtr ??= ScrollController();

  late bool isExpanding = false;
  late bool isCollapsing = false;

  late double minVideoHeight;
  late double maxVideoHeight;
  late double videoHeight;
  late double animHeight;

  AnimationController? animController;
  AnimationController get animationController =>
      animController ??= (AnimationController(
        vsync: _vsync!,
        duration: const Duration(milliseconds: 200),
      )..addListener(_animListener));

  void refreshPage() {
    scrollKey.currentState?.refresh();
  }

  void _animListener() {
    if (animationController.isForwardOrCompleted) {
      _calcAnimHeight();
      refreshPage();
    }
  }

  void _calcAnimHeight() {
    if (isExpanding) {
      animHeight = clampDouble(
        videoHeight * animationController.value,
        kToolbarHeight,
        videoHeight,
      );
    } else if (isCollapsing) {
      animHeight = clampDouble(
        maxVideoHeight -
            (maxVideoHeight - minVideoHeight) * animationController.value,
        minVideoHeight,
        maxVideoHeight,
      );
    }
  }

  void animToTop() {
    scrollKey.currentState?.animToTop();
  }

  bool _needAnimOnDimensionChanged(bool isVertical) {
    if (isFullScreen) {
      if (PlatformUtils.isMobile) {
        plPlayerController.changeOrientation(isVertical: isVertical);
      }
      return false;
    }
    return true;
  }

  @pragma('vm:notify-debugger-on-exception')
  void _setVideoHeight() {
    try {
      var width = firstVideoWidth;
      var height = firstVideoHeight;
      if (width == null || height == null) {
        if (isUgc && !isFileSource) {
          final dimension = VideoHost.of().partDimension(heroTag, cid.value);
          if (dimension != null) {
            width = dimension.width;
            height = dimension.height;
          } else {
            return;
          }
        } else {
          return;
        }
      }
      final isVertical = height > width;
      if (_scrollCtr?.hasClients != true) {
        videoHeight = isVertical ? maxVideoHeight : minVideoHeight;
        if (this.isVertical.value != isVertical) {
          this.isVertical.value = isVertical;
          _needAnimOnDimensionChanged(isVertical);
        }
        return;
      }
      if (this.isVertical.value != isVertical) {
        this.isVertical.value = isVertical;
        double videoHeight = isVertical ? maxVideoHeight : minVideoHeight;
        if (this.videoHeight != videoHeight) {
          if (videoHeight > this.videoHeight) {
            // current minVideoHeight
            if (_needAnimOnDimensionChanged(isVertical)) {
              isExpanding = true;
              animationController.forward(
                from: (minVideoHeight - scrollCtr.offset) / maxVideoHeight,
              );
            }
            this.videoHeight = maxVideoHeight;
          } else {
            // current maxVideoHeight
            final currentHeight = (maxVideoHeight - scrollCtr.offset)
                .toPrecision(2);
            double minVideoHeightPrecise = minVideoHeight.toPrecision(2);
            if (currentHeight == minVideoHeightPrecise) {
              this.videoHeight = minVideoHeight;
              if (_needAnimOnDimensionChanged(isVertical)) {
                isExpanding = true;
                animationController.forward(from: 1);
              }
            } else if (currentHeight < minVideoHeightPrecise) {
              // expand
              if (_needAnimOnDimensionChanged(isVertical)) {
                isExpanding = true;
                animationController.forward(
                  from: currentHeight / minVideoHeight,
                );
              }
              this.videoHeight = minVideoHeight;
            } else {
              // collapse
              if (_needAnimOnDimensionChanged(isVertical)) {
                isCollapsing = true;
                animationController.forward(
                  from: scrollCtr.offset / (maxVideoHeight - minVideoHeight),
                );
              }
              this.videoHeight = minVideoHeight;
            }
          }
        }
      } else {
        if (scrollCtr.offset != 0) {
          isExpanding = true;
          animationController.forward(from: 1 - scrollCtr.offset / videoHeight);
        }
      }
    } catch (_) {}
  }

  final isLoginVideo = VideoHost.of().isVideoLogin;

  late final watchProgress = GStorage.watchProgress;
  void cacheLocalProgress() {
    if (plPlayerController.playerStatus.isCompleted) {
      watchProgress.put(
        cid.toString(),
        _fileEntry?.totalTimeMilli ?? playedTime?.inMilliseconds ?? 0,
      );
    } else if (playedTime case final playedTime?) {
      watchProgress.put(cid.toString(), playedTime.inMilliseconds);
    }
  }

  CoreFileEntryInfo? _fileEntry;

  void initFileSource(Object? entry, {bool isInit = true}) {
    _fileEntry = VideoHost.of().fileEntryInfo(entry);
    final fileEntry = _fileEntry;
    if (fileEntry == null) {
      return;
    }
    firstVideoQaCode = fileEntry.preferedVideoQuality;
    firstVideoWidth = fileEntry.width;
    firstVideoHeight = fileEntry.height;
    if (watchProgress.get(cid.toString()) case final int progress?) {
      if (progress >= fileEntry.totalTimeMilli - 400) {
        defaultST = Duration.zero;
      } else {
        defaultST = Duration(milliseconds: progress);
      }
    } else {
      defaultST = Duration.zero;
    }
    data = CorePlayUrlModel(timeLength: fileEntry.totalTimeMilli);
    _setVideoHeight();
  }

  void initController() {
    args = AppNavigator.arguments;
    videoType = coreVideoTypeFromArgs(args['videoType']);
    if (videoType == CoreVideoType.pgc) {
      if (!isLoginVideo) {
        _actualVideoType = CoreVideoType.ugc;
      }
    } else if (args['pgcApi'] == true) {
      _actualVideoType = CoreVideoType.pgc;
    }

    bvid = args['bvid'];
    aid = args['aid'];
    cid = RxInt(args['cid']);
    epId = args['epId'];
    seasonId = args['seasonId'];
    pgcType = args['pgcType'];
    heroTag = args['heroTag'];
    cover = RxString(args['cover'] ?? '');
    isVertical = RxBool(args['isVertical'] ?? false);

    final sourceType = args['sourceType'];
    isFileSource = VideoHost.of().isFileSourceSource(sourceType);
    isPlayAll = VideoHost.of().isPlayAllSource(sourceType);
    if (isFileSource) {
      initFileSource(args['entry']);
    } else if (isPlayAll) {
      watchLaterTitle = args['favTitle'];
      _mediaDesc = args['desc'];
      getMediaList();
    }

    tabCtr = TabController(
      length: 2,
      vsync: _vsync!,
      initialIndex: Pref.defaultShowComment ? 1 : 0,
    );
  }

  bool get mediaDesc => _mediaDesc;

  void toggleMediaDesc() {
    _mediaDesc = !_mediaDesc;
  }

  Future<void> getMediaList({
    bool isReverse = false,
    bool isLoadPrevious = false,
  }) async {
    final count = args['count'];
    if (!isReverse && count != null && mediaList.length >= count) {
      return;
    }
    final res = await (appRead(userRepositoryProvider)).getMediaList(
      type: VideoHost.of().sourceMediaType(args['sourceType']),
      bizId: (args['mediaId'] ?? -1).toString(),
      ps: 20,
      direction: isLoadPrevious ? true : false,
      oid: isReverse
          ? null
          : mediaList.isEmpty
          ? args['isContinuePlaying'] == true
                ? args['oid']
                : null
          : isLoadPrevious
          ? mediaList.first.aid
          : mediaList.last.aid,
      otype: isReverse
          ? null
          : mediaList.isEmpty
          ? null
          : isLoadPrevious
          ? mediaList.first.type
          : mediaList.last.type,
      desc: _mediaDesc,
      sortField: args['sortField'] ?? 1,
      withCurrent: mediaList.isEmpty && args['isContinuePlaying'] == true
          ? true
          : false,
    );
    if (res case Success(:final response)) {
      if (response.mediaList.isNotEmpty) {
        final converted = response.mediaList.toList();
        if (isReverse) {
          mediaList = converted;
          for (final item in mediaList) {
            if (item.aid != null) {
              try {
                VideoHost.of().onChangeEpisodeFromMedia(heroTag, item);
              } catch (_) {}
              break;
            }
          }
        } else if (isLoadPrevious) {
          mediaList.insertAll(0, converted);
        } else {
          mediaList.addAll(converted);
        }
      }
    } else {
      res.toast();
    }
  }

  bool isPortrait = true;

  bool get horizontalScreen => plPlayerController.horizontalScreen;

  bool get showVideoSheet =>
      (!horizontalScreen && !isPortrait) || plPlayerController.isDesktopPip;

  late String videoLabel = '';
  int? get timeLength => data.timeLength;
  bool get isFullScreen => plPlayerController.isFullScreen;
  bool get autoPlay => _autoPlay;
  set autoPlay(bool value) => _autoPlay = value;
  bool get preInitPlayer => plPlayerController.preInitPlayer;
  int get currPosInMilliseconds =>
      defaultST?.inMilliseconds ?? plPlayerController.positionInMilliseconds;
  Future<void> seekTo(Duration duration, {required bool isSeek}) =>
      plPlayerController.seekTo(duration, isSeek: isSeek);

  /// 片段跳过（委托给块引擎）。
  bool get enableBlock => block.enableBlock;
  bool get isBlock => block.isBlock;
  List<Segment> get segmentProgressList => block.segmentProgressList;
  List<Object> get listData => block.listData;
  GlobalKey<AnimatedListState> get listKey => block.listKey;
  void initSkip() => block.initSkip();
  void resetBlock() => block.resetBlock();
  Future<void> querySponsorBlock({required String bvid, required int cid}) =>
      block.querySponsorBlock(bvid: bvid, cid: cid);
  void cancelBlockListener() => block.cancelBlockListener();
  void onAddItem(Object item) => block.onAddItem(item);
  void onRemoveItem(int index, Object item) => block.onRemoveItem(index, item);
  Future<void>? onSkip(Object item, {bool isSeek = true}) =>
      block.onSkip(item, isSeek: isSeek);
  Widget buildItem(Object item, Animation<double> animation) =>
      block.buildItem(item, animation);

  ({int mode, int fontSize, Color color})? dmConfig;
  String? savedDanmaku;

  /// 发送弹幕
  Future<void> showShootDanmakuSheet() async {
    if (VideoHost.of().playerHost.dmStateContains(cid.value)) {
      SmartDialog.showToast('UP主已关闭弹幕');
      return;
    }
    final isPlaying =
        _autoPlay && plPlayerController.playerStatus.isPlaying;
    if (isPlaying) {
      await plPlayerController.pause();
    }
    await VideoHost.of().showShootDanmakuSheet(
      heroTag: heroTag,
      bvid: bvid,
      cid: cid.value,
      progress: plPlayerController.positionInMilliseconds,
      initialValue: savedDanmaku,
      onSave: (danmaku) => savedDanmaku = danmaku,
      dmConfig: dmConfig,
      onSaveDmConfig: (dmConfig) => this.dmConfig = dmConfig,
    );
    if (isPlaying) {
      plPlayerController.play();
    }
  }

  /// 更新画质、音质
  void updatePlayer() {
    final currentVideoQa = this.currentVideoQa.value;
    if (currentVideoQa == null) return;
    _autoPlay = true;
    playedTime = plPlayerController.videoPlayerController?.state.position;
    plPlayerController
      ..isBuffering = false
      ..buffered = 0;

    final config = VideoHost.of().selectPlayback(
      data: data,
      cacheVideoQa: currentVideoQa.code,
      cacheAudioQa: currentAudioQa?.code ?? AudioQuality.k192.code,
    );
    videoUrl = config.videoUrl;
    audioUrl = config.audioUrl;
    firstVideoWidth = config.width;
    firstVideoHeight = config.height;
    this.currentVideoQa.value = VideoQuality.fromCode(config.videoQaCode);
    currentAudioQa = config.audioQaCode == null
        ? null
        : AudioQuality.fromCode(config.audioQaCode!);
    currentDecodeFormats = config.decodeFormat;

    playerInit();
  }

  Future<void>? _initPlayerIfNeeded(bool autoFullScreenFlag) {
    if (_autoPlay ||
        (plPlayerController.preInitPlayer && !plPlayerController.processing) &&
            (isFileSource
                ? true
                : videoPlayerKey.currentState?.mounted == true)) {
      return playerInit(
        autoFullScreenFlag: autoFullScreenFlag && _autoPlay,
      );
    }
    return null;
  }

  Future<void> playerInit({
    bool? autoplay,
    bool autoFullScreenFlag = false,
  }) async {
    Duration? seek = defaultST ?? playedTime;
    if (seek == null || seek == Duration.zero) {
      seek = block.getFirstSegment();
    }
    await VideoHost.of().playerHost.playerSetDataSource(
      source: isFileSource
          ? FileSource(
              dir: args['dirPath'],
              typeTag: _fileEntry?.typeTag ?? '',
              isMp4: _fileEntry?.mediaType == 1,
              hasDashAudio: _fileEntry?.hasDashAudio ?? false,
            )
          : NetworkSource(
              videoSource: videoUrl!,
              audioSource: audioUrl,
            ),
      seekTo: seek,
      duration: data.timeLength == null
          ? null
          : Duration(milliseconds: data.timeLength!),
      isVertical: isVertical.value,
      aid: aid,
      bvid: bvid,
      cid: cid.value,
      autoplay: autoplay ?? _autoPlay,
      epid: isUgc ? null : epId,
      seasonId: isUgc ? null : seasonId,
      pgcType: isUgc ? null : pgcType,
      videoType: _actualVideoType ?? videoType,
      onInit: () {
        videoState = true;
        setSubtitle(vttSubtitlesIndex);
      },
      width: firstVideoWidth,
      height: firstVideoHeight,
      volume: volume,
      autoFullScreenFlag: autoFullScreenFlag,
    );

    if (isClosed) return;

    if (!isFileSource) {
      if (VideoHost.of().playerHost.enableBlock) {
        initSkip();
      }

      if (vttSubtitlesIndex == -1) {
        _queryPlayInfo();
      }

      if (VideoHost.of().playerHost.showDmChart && dmTrend.value == null) {
        _getDmTrend();
      }
    }

    defaultST = null;
  }

  bool isQuerying = false;

  final languages = Rxn<List<VideoLanguageItem>>();
  final currLang = Rxn<String>();
  void setLanguage(String language) {
    if (currLang.value == language) return;
    if (!isLoginVideo) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    currLang.value = language;
    queryVideoUrl(fromReset: true);
  }

  VideoVolume? volume;

  // 视频链接
  Future<void> queryVideoUrl({
    bool fromReset = false,
    bool autoFullScreenFlag = false,
  }) async {
    if (isFileSource) {
      return _initPlayerIfNeeded(autoFullScreenFlag);
    }
    if (isQuerying) {
      return;
    }
    isQuerying = true;
    if (VideoHost.of().playerHost.enableSponsorBlock && isBlock && !fromReset) {
      querySponsorBlock(bvid: bvid, cid: cid.value);
    }
    if (plPlayerController.cacheVideoQa == null) {
      final isWiFi = await ConnectivityUtils.isWiFi;
      plPlayerController
        ..cacheVideoQa = isWiFi
            ? Pref.defaultVideoQa
            : Pref.defaultVideoQaCellular
        ..cacheAudioQa = isWiFi
            ? Pref.defaultAudioQa
            : Pref.defaultAudioQaCellular;
    }

    final result = await (appRead(videoRepositoryProvider)).videoUrl(
      cid: cid.value,
      bvid: bvid,
      epid: epId?.toString(),
      seasonId: seasonId?.toString(),
      tryLook: VideoHost.of().playerHost.tryLook,
      videoType: _actualVideoType ?? videoType,
      language: currLang.value,
      voiceBalance: VideoHost.of().playerHost.enableAudioNormalization,
    );

    if (result case Success(:final response)) {
      data = response;

      languages.value = (data.language?['items'] as List?)
          ?.map((e) => VideoLanguageItem.fromMap(e as Map<String, dynamic>))
          .toList();
      currLang.value = data.curLanguage;

      volume = data.volume == null ? null : VideoVolume.fromMap(data.volume!);

      if (!fromReset) {
        final progress = args.remove('progress');
        if (progress != null) {
          defaultST = Duration(milliseconds: progress);
        } else {
          defaultST = Duration(milliseconds: data.lastPlayTime ?? 0);
        }
      }

      if (!isUgc && !fromReset && VideoHost.of().playerHost.enablePgcSkip) {
        VideoHost.of().applyPgcClipInfo(heroTag, data.clipInfoList);
      }

      if (data.acceptDesc?.contains('试看') == true) {
        SmartDialog.showToast(
          '该视频为专属视频，仅提供试看',
          displayTime: const Duration(seconds: 3),
        );
      }
      if (data.dashData == null && data.durlList != null) {
        final first = data.durlList!.first;
        videoUrl = VideoHost.of().playerHost.getCdnUrl([
          if (first.url != null) first.url!,
          ...?first.backupUrl,
        ]);
        audioUrl = '';

        // 实际为FLV/MP4格式，但已被淘汰，这里仅做兜底处理
        final videoQuality = VideoQuality.fromCode(data.quality ?? 0);
        firstVideoQaCode = data.quality;
        _setVideoHeight();
        currentDecodeFormats = VideoDecodeFormatType.AVC;
      currentVideoQa.value = videoQuality;
        await _initPlayerIfNeeded(autoFullScreenFlag);
        isQuerying = false;
        return;
      }
      if (data.dashData == null) {
        SmartDialog.showToast('视频资源不存在');
        _autoPlay = false;
        videoState = false;
        if (plPlayerController.isFullScreen) {
          plPlayerController.triggerFullScreen(status: false);
        }
        isQuerying = false;
        return;
      }
      final config = VideoHost.of().selectPlayback(
        data: data,
        cacheVideoQa: plPlayerController.cacheVideoQa,
        cacheAudioQa: plPlayerController.cacheAudioQa,
      );
      videoUrl = config.videoUrl;
      audioUrl = config.audioUrl;
      firstVideoWidth = config.width;
      firstVideoHeight = config.height;
      currentVideoQa.value = VideoQuality.fromCode(config.videoQaCode);
      currentAudioQa = config.audioQaCode == null
          ? null
          : AudioQuality.fromCode(config.audioQaCode!);
      currentDecodeFormats = config.decodeFormat;
      _setVideoHeight();
      await _initPlayerIfNeeded(autoFullScreenFlag);
    } else {
      _autoPlay = false;
      videoState = false;
      if (plPlayerController.isFullScreen) {
        plPlayerController.triggerFullScreen(status: false);
      }
      result.toast();
    }
    isQuerying = false;
  }

  late final List<CorePostSegmentModel> postList = <CorePostSegmentModel>[];
  void onBlock(BuildContext context) {
    VideoHost.of().onBlock(context, heroTag);
  }

  RxList<VideoSubtitleItem> subtitles = RxList<VideoSubtitleItem>();
  final Map<int, ({bool isData, String id})> vttSubtitles = {};
  late int vttSubtitlesIndex = -1;
  late bool showVP = true;
  late List<ViewPointSegment> viewPointList = [];

  // 设定字幕轨道
  Future<void> setSubtitle(int index) async {
    if (index <= 0) {
      await plPlayerController.videoPlayerController?.setSubtitleTrack(.no());
      vttSubtitlesIndex = index;
      return;
    }

    Future<void> setSub(({bool isData, String id}) subtitle) async {
      final sub = subtitles[index - 1];

      String subUri = subtitle.id;
      if (subtitle.isData) {
        subUri = 'memory://$subUri';
      }
      await plPlayerController.videoPlayerController?.setSubtitleTrack(
        SubtitleTrack(subUri, sub.lanDoc, sub.lan, uri: true),
      );
      vttSubtitlesIndex = index;
    }

    ({bool isData, String id})? subtitle = vttSubtitles[index - 1];
    if (subtitle != null) {
      await setSub(subtitle);
    } else {
      final result = await (appRead(videoRepositoryProvider)).vttSubtitles(
        subtitles[index - 1].subtitleUrl!,
      );
      if (!isClosed && result != null) {
        final subtitle = (isData: true, id: result);
        vttSubtitles[index - 1] = subtitle;
        await setSub(subtitle);
      }
    }
  }

  // interactive video
  int? graphVersion;
  late bool showSteinEdgeInfo = false;
  late bool hasSteinChoices = false;

  Future<void> getSteinEdgeInfo([int? edgeId]) async {
    hasSteinChoices = await VideoHost.of().getSteinEdgeInfo(
      heroTag: heroTag,
      bvid: bvid,
      graphVersion: graphVersion,
      edgeId: edgeId,
    );
  }

  late bool continuePlayingPart = Pref.continuePlayingPart;

  Future<void> _queryPlayInfo() async {
    vttSubtitles.clear();
    vttSubtitlesIndex = 0;
    if (plPlayerController.showViewPoints) {
      viewPointList.clear();
    }
    final res = await (appRead(videoRepositoryProvider)).playInfo(
      bvid: bvid,
      cid: cid.value,
      seasonId: seasonId?.toString(),
      epId: epId?.toString(),
    );
    if (res case Success(:final response)) {
      // interactive video
      if (isUgc && graphVersion == null) {
        try {
          if (VideoHost.of().isSteinGate(heroTag)) {
            graphVersion = response.interaction?['graphVersion'];
            getSteinEdgeInfo();
          }
        } catch (e) {
          if (kDebugMode) debugPrint('handle stein: $e');
        }
      }

      if (isUgc && continuePlayingPart) {
        continuePlayingPart = false;
        VideoHost.of().applyContinuePlayingPart(
          heroTag,
          lastPlayCid: response.lastPlayCid,
          currentCid: cid.value,
        );
      }

      if (plPlayerController.showViewPoints &&
          (response.viewPoints?.firstOrNull)?['type'] ==
              2) {
        try {
        viewPointList = response.viewPoints!.map((item) {
            final itemMap = item;
            final end = ((itemMap['to'] as num) / (data.timeLength! / 1000))
                .clamp(0.0, 1.0);
            return ViewPointSegment(
              end: end,
              title: itemMap['content'] as String? ?? '',
              url: itemMap['imgUrl'] as String? ?? '',
              from: itemMap['from'] as int?,
              to: itemMap['to'] as int?,
            );
          }).toList();
        } catch (_) {}
      }

      if ((response.subtitle)?['subtitles']
          case final List sub? when (sub.isNotEmpty)) {
        _setSubtitle(
          sub
              .map((e) => VideoSubtitleItem.fromMap(e as Map<String, dynamic>))
              .toList(),
        );
      } else if (!isLoginVideo) {
        final subs = await VideoHost.of().fetchDmSubtitles(
          aid: aid,
          cid: cid.value,
        );
        if (subs != null && subs.isNotEmpty) {
          _setSubtitle(subs);
        }
      }
    }
  }

  Future<void> _setSubtitle(List<VideoSubtitleItem> sub) async {
    subtitles.value = sub;
    final idx = switch (SubtitlePrefType.values[Pref.subtitlePreferenceV2]) {
      SubtitlePrefType.off => 0,
      SubtitlePrefType.on => 1,
      SubtitlePrefType.withoutAi => sub.first.lan.startsWith('ai') ? 0 : 1,
      SubtitlePrefType.auto =>
        !sub.first.lan.startsWith('ai') ||
                (PlatformUtils.isMobile &&
                    (await FlutterVolumeController.getVolume() ?? 0.0) <= 0.0)
            ? 1
            : 0,
    };
    await setSubtitle(idx);
  }

  void updateMediaListHistory(int aid) {
    if (args['sortField'] != null) {
      final mediaId = args['mediaId'];
      (appRead(videoRepositoryProvider)).medialistHistory(
        desc: _mediaDesc ? 1 : 0,
        oid: '$aid',
        upperMid: mediaId is int ? mediaId : int.parse('$mediaId'),
      );
    }
  }

  void makeHeartBeat() {
    if (VideoHost.of().playerHost.enableHeart &&
        !plPlayerController.playerStatus.isCompleted &&
        playedTime != null) {
      try {
        VideoHost.of().playerHost.playerMakeHeartBeat(
          progress: data.timeLength != null
              ? (data.timeLength! - playedTime!.inMilliseconds).abs() <= 1000
                    ? -1
                    : playedTime!.inSeconds
              : playedTime!.inSeconds,
          type: HeartBeatType.completed,
          isManual: true,
          aid: aid,
          bvid: bvid,
          cid: cid.value,
          epid: isUgc ? null : epId,
          seasonId: isUgc ? null : seasonId,
          pgcType: isUgc ? null : pgcType,
          videoType: videoType,
        );
      } catch (_) {}
    }
  }

  void showSBDetail() {
    VideoHost.of().showSBDetail(heroTag);
  }

  @override
  void dispose() {
    _isDisposed = true;
    block.dispose();
    cid.close();
    if (isFileSource) {
      cacheLocalProgress();
    }
    introScrollCtr?.dispose();
    introScrollCtr = null;
    tabCtr.dispose();
    _scrollCtr?.dispose();
    animController
      ?..removeListener(_animListener)
      ..dispose();
    subtitles.clear();
    vttSubtitles.clear();
    super.dispose();
  }

  void onReset({bool isStein = false}) {
    if (isFileSource) {
      cacheLocalProgress();
    }

    playedTime = null;
    defaultST = null;
    videoUrl = null;
    audioUrl = null;

    // danmaku
    savedDanmaku = null;

    // subtitle
    subtitles.clear();
    vttSubtitlesIndex = -1;
    vttSubtitles.clear();

    if (!isFileSource) {
      // language
      languages.value = null;
      currLang.value = null;

      // dm trend
      if (plPlayerController.showDmChart) {
        dmTrend.value = null;
      }

      // view point
      if (plPlayerController.showViewPoints) {
        viewPointList.clear();
      }

      // sponsor block
      if (VideoHost.of().playerHost.enableBlock) {
        resetBlock();
      }

      // interactive video
      if (!isStein) {
        graphVersion = null;
      }
      showSteinEdgeInfo = false;
      hasSteinChoices = false;
    }
  }

  late final Rx<LoadingState<List<double>>?> dmTrend =
      Rx<LoadingState<List<double>>?>(null);
  late bool showDmTrendChart = true;

  Future<void> _getDmTrend() async {
    dmTrend.value = LoadingState<List<double>>.loading();
    dmTrend.value = await VideoHost.of().fetchDmTrend(
      bvid: bvid,
      cid: cid.value,
    );
  }

  void showNoteList(BuildContext context) {
    VideoHost.of().showNoteList(context, heroTag);
  }

  void showMediaListPanel(BuildContext context) {
    VideoHost.of().showMediaListPanel(context, heroTag);
  }

  @pragma('vm:notify-debugger-on-exception')
  bool onSkipSegment() {
    try {
      if (VideoHost.of().playerHost.enableBlock) {
        if (block.listData.lastOrNull case final Object item) {
          block.onSkip(item, isSeek: false);
          block.onRemoveItem(block.listData.indexOf(item), item);
          return true;
        }
      }
    } catch (e, s) {
      Utils.reportError(e, s);
    }
    return false;
  }

  void toAudioPage() {
    VideoHost.of().openAudioPage(heroTag);
  }

  Future<void> onDownload(BuildContext context) {
    return VideoHost.of().showDownloadPanel(context, heroTag);
  }

  void editPlayUrl() {
    String videoUrl = this.videoUrl ?? '';
    String audioUrl = this.audioUrl ?? '';
    Widget textField({
      required String label,
      required String initialValue,
      required ValueChanged<String> onChanged,
    }) => TextFormField(
      minLines: 1,
      maxLines: 3,
      onChanged: onChanged,
      initialValue: initialValue,
      decoration: InputDecoration(
        label: Text(label),
        border: const OutlineInputBorder(),
      ),
    );
    showDialog(
      context: AppNavigator.context!,
      builder: (context) => AlertDialog(
        constraints: Style.dialogFixedConstraints,
        title: const Text('播放地址'),
        content: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textField(
              label: 'Video Url',
              initialValue: videoUrl,
              onChanged: (value) => videoUrl = value,
            ),
            textField(
              label: 'Audio Url',
              initialValue: audioUrl,
              onChanged: (value) => audioUrl = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppNavigator.back();
              this.videoUrl = videoUrl;
              this.audioUrl = audioUrl;
              playerInit();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @pragma('vm:notify-debugger-on-exception')
  Future<void> onCast() async {
    SmartDialog.showLoading();
    final res = await (appRead(videoRepositoryProvider)).tvPlayUrl(
      cid: cid.value,
      objectId: epId ?? aid,
      playurlType: epId != null ? 2 : 1,
      qn: currentVideoQa.value?.code,
    );
    SmartDialog.dismiss();
    if (res case Success(:final response)) {
      final first = response.durl?.firstOrNull;
      if (first == null || (first['url'] as String?)?.isEmpty != false) {
        SmartDialog.showToast('不支持投屏');
        return;
      }
      final List<String> playUrls = [
        first['url'] as String,
        if (first['backup_url'] is List)
          ...(first['backup_url'] as List).cast<String>(),
      ];
      final url = VideoHost.of().playerHost.getCdnUrl(playUrls);

      final title = VideoHost.of().videoTitle(heroTag);
      if (kDebugMode) {
        debugPrint(title);
      }
      AppNavigator.toNamed(
        '/dlna',
        parameters: {
          'url': url,
          'title': ?title,
        },
      );
    } else {
      res.toast();
    }
  }
}


/// 每视频页实例注册表 — view 创建 [VideoDetailController] 后登记，
/// host/部件按 [heroTag] 经 [videoDetailControllerProvider] 读取。
///
/// 注册表替代了 GetX 的 tag 注册（`Get.put(..., tag: heroTag)`）：
/// 页面 view 的 initState 写入、dispose 移除；family provider 查不到时
/// 抛出带上下文的 [StateError]（编译期类型安全，运行期错误信息明确）。
final Map<String, VideoDetailController> videoDetailRegistry = {};

final videoDetailControllerProvider =
    Provider.family<VideoDetailController, String>(
  (ref, heroTag) => videoDetailRegistry[heroTag] ??
      (throw StateError('VideoDetailController not registered for heroTag: $heroTag')),
);
