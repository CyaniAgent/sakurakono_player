import 'dart:convert' show ascii;
import 'package:skf/router/app_navigator.dart';
import 'dart:io' show Platform;
import 'dart:math' show max, min;
import 'dart:ui' as ui;

import 'package:skf/adapters/bilibili/http/browser_ua.dart';
import 'package:skf/adapters/bilibili/http/constants.dart';
import 'package:skf/adapters/bilibili/http/video.dart';
import 'package:skf/adapters/bilibili/models/common/account_type.dart';
import 'package:skf/adapters/bilibili/models/common/audio_normalization.dart';
import 'package:skf/adapters/bilibili/models/common/video/video_type.dart';
import 'package:skf/adapters/bilibili/models/video/play/url.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_shot/data.dart';
import 'package:skf/adapters/bilibili/pages/danmaku/danmaku_model.dart';
import 'package:skf/adapters/bilibili/pages/setting_parts/models/play_settings.dart'
    show kMaxVolume;
import 'package:skf/adapters/bilibili/services/service_locator.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/bili_storage_pref.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/common/assets.dart';
import 'package:skf/core/player/core_player_service.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/player/models/data_source.dart';
import 'package:skf/player/models/data_status.dart';
import 'package:skf/player/models/heart_beat_type.dart';
import 'package:skf/player/models/play_status.dart';
import 'package:skf/player/player_controller.dart';
import 'package:skf/utils/asset_utils.dart';
import 'package:skf/utils/duration_utils.dart';
import 'package:skf/utils/image_utils.dart';
import 'package:skf/utils/path_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:archive/archive.dart' show getCrc32;
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as path;

/// B站 播放器扩展：叠加在通用核心 [PlayerController] 上的专属能力。
///
/// 覆盖：心跳（VideoHttp.heartBeat + aid/bvid/cid 字段）、videoshot 预览、
/// PiP（PageUtils.enterPip）、QA/CDN（BiliPref）、弹幕（DanmakuExtra +
/// canvas_danmaku）、音频归一化（AudioNormalization）、超分辨率
/// （SuperResolutionType）、音量上限（kMaxVolume）、media header
/// （BrowserUa/HttpString）等。核心逻辑在 [PlayerController]，本 mixin 通过
/// 核心钩子（onPlayerInit / onOpenStart / onHeartBeat / onEnterPip …）挂载
/// B站 专属行为，[setDataSource] 为 B站 侧统一播放入口。
mixin BiliPlayerMixin on PlayerController {
  // 记录历史记录
  int? _aid;
  String? _bvid;
  int? cid;
  int? _epid;
  int? _seasonId;
  int? _pgcType;
  VideoType _videoType = VideoType.ugc;

  String get bvid => _bvid!;

  late final tryLook = !Accounts.get(AccountType.video).isLogin && Pref.p1080;

  late final _audioNormalization = Pref.audioNormalization;
  late final enableAudioNormalization =
      Platform.isAndroid && _audioNormalization != '0';
  late final String _audioNormalizationParam =
      AudioNormalization.getParamFromConfig(_audioNormalization);

  // 与 PlPlayerController.loudnormRegExp（设置页检测用）保持一致的独立副本。
  static final RegExp _loudnormRegExp = RegExp('loudnorm=([^,]+)');

  bool enableHeart = true;

  /// 弹幕开关
  late final bool enableShowDanmaku = Pref.enableShowDanmaku;
  late final bool enableShowLiveDanmaku = Pref.enableShowLiveDanmaku;
  bool get enableShowDanmakuAdaptive =>
      isLive ? enableShowLiveDanmaku : enableShowDanmaku;

  // 弹幕相关配置
  late final enableTapDm = PlatformUtils.isMobile && Pref.enableTapDm;
  late RuleFilter filters = BiliPref.danmakuFilterRule;
  // 关联弹幕控制器
  DanmakuController<DanmakuExtra>? danmakuController;
  bool showDanmaku = true;
  Set<int> dmState = <int>{};
  late final mergeDanmaku = Pref.mergeDanmaku;
  late final String midHash = getCrc32(
    ascii.encode(Accounts.main.mid.toString()),
    0,
  ).toRadixString(16);
  late final double danmakuOpacity = Pref.danmakuOpacity;
  final bool showVipDanmaku = Pref.showVipDanmaku; // loop unswitching

  late final progressType = BiliPref.btmProgressBehavior;

  // 播放顺序相关
  late PlayRepeat playRepeat = BiliPref.playRepeat;

  // 超分辨率
  late final isAnim = _pgcType == 1 || _pgcType == 4;
  late SuperResolutionType superResolutionType =
      isAnim ? BiliPref.superResolutionType : SuperResolutionType.disable;

  String? shadersDirPath;
  Future<String> get copyShadersToExternalDirectory async {
    if (shadersDirPath != null) {
      return shadersDirPath!;
    }

    return shadersDirPath = await AssetUtils.getOrCopy(
      'assets/shaders',
      Assets.mpvAnime4KShaders.followedBy(Assets.mpvAnime4KShadersLite),
      path.join(appSupportDirPath, 'anime_shaders'),
    );
  }

  Future<void> setShader([SuperResolutionType? type, NativePlayer? pp]) async {
    if (type == null) {
      type = superResolutionType;
    } else {
      superResolutionType = type;
      if (isAnim && !tempPlayerConf) {
        setting.put(SettingBoxKey.superResolutionType, type.index);
      }
    }
    pp ??= videoPlayerController!;
    switch (type) {
      case SuperResolutionType.disable:
        return pp.command(const ['change-list', 'glsl-shaders', 'clr', '']);
      case SuperResolutionType.efficiency:
        return pp.command([
          'change-list',
          'glsl-shaders',
          'set',
          PathUtils.buildShadersAbsolutePath(
            await copyShadersToExternalDirectory,
            Assets.mpvAnime4KShadersLite,
          ),
        ]);
      case SuperResolutionType.quality:
        return pp.command([
          'change-list',
          'glsl-shaders',
          'set',
          PathUtils.buildShadersAbsolutePath(
            await copyShadersToExternalDirectory,
            Assets.mpvAnime4KShaders,
          ),
        ]);
    }
  }

  // videoshot 预览
  late final Map<String, ui.Image?> previewCache = {};
  LoadingState<VideoShotData>? videoShot;
  late bool showPreview = false;
  late final showSeekPreview = Pref.showSeekPreview;
  late final previewIndex = RxnInt();

  // ---------------------------------------------------------------------------
  // 核心钩子实现
  // ---------------------------------------------------------------------------

  @override
  void onPlayerInit() {
    if (!Accounts.heartbeat.isLogin || Pref.historyPause) {
      enableHeart = false;
    }
    mode = BiliPref.fullScreenMode;
  }

  @override
  String? get volumeMax => kMaxVolume.toString();

  @override
  void onPlayerCreated(NativePlayer player) {
    player.setMediaHeader(userAgent: BrowserUa.pc, referer: HttpString.baseUrl);
  }

  @override
  Future<void> onPlayerAttached(Player player) async {
    if (isAnim && superResolutionType != .disable) {
      await setShader();
    }
  }

  @override
  void onOpenStart() {
    danmakuController?.clear();
  }

  @override
  void onStatusChanged(PlayerStatus status, bool buffering, bool isLive) {
    videoPlayerServiceHandler?.onStatusChange(status, buffering, isLive);
  }

  @override
  void onPositionChanged(Duration position) {
    videoPlayerServiceHandler?.onPositionChange(position);
  }

  @override
  void onHeartBeat(int progress, {HeartBeatType type = .playing}) {
    makeHeartBeat(progress, type: type);
  }

  @override
  void onSeek() {
    danmakuController?.clear();
  }

  @override
  void onPlaybackSpeedChanged(double speed) {
    if (danmakuController != null) {
      try {
        DanmakuOption currentOption = danmakuController!.option;
        double defaultDuration = currentOption.duration * lastPlaybackSpeed;
        double defaultStaticDuration =
            currentOption.staticDuration * lastPlaybackSpeed;
        DanmakuOption updatedOption = currentOption.copyWith(
          duration: defaultDuration / speed,
          staticDuration: defaultStaticDuration / speed,
        );
        danmakuController!.updateOption(updatedOption);
      } catch (_) {}
    }
  }

  @override
  void onAudioSessionChanged(bool active) {
    audioSessionHandler?.setActive(active);
  }

  @override
  void onBackgroundPlayChanged(bool val) {
    videoPlayerServiceHandler?.enableBackgroundPlay = val;
  }

  @override
  void onSeekPreviewEnd() {
    if (showSeekPreview) {
      showPreview = false;
    }
  }

  @override
  void onEnterPip({
    required int? width,
    required int? height,
    required bool autoEnter,
    required bool isLive,
    required bool isPlaying,
  }) {
    PageUtils.enterPip(
      autoEnter: autoEnter,
      width: width,
      height: height,
      isLive: isLive,
      isPlaying: isPlaying,
    );
  }

  @override
  void onDisposeCleanup() {
    danmakuController = null;
    dmState.clear();
    if (showSeekPreview) {
      _clearPreview();
    }
  }

  @override
  void onDisposeEnd() {
    videoPlayerServiceHandler?.clear();
  }

  // ---------------------------------------------------------------------------
  // B站 统一播放入口
  // ---------------------------------------------------------------------------

  // 初始化资源
  Future<void> setDataSource(
    DataSource dataSource, {
    bool isLive = false,
    bool autoplay = true,
    // 初始化播放位置
    Duration? seekTo,
    // 初始化播放速度
    double speed = 1.0,
    int? width,
    int? height,
    Duration? duration,
    // 方向
    bool? isVertical,
    // 记录历史记录
    int? aid,
    String? bvid,
    int? cid,
    int? epid,
    int? seasonId,
    int? pgcType,
    VideoType? videoType,
    VoidCallback? onInit,
    Volume? volume,
    bool autoFullScreenFlag = false,
  }) async {
    try {
      processing = true;
      this.isLive = isLive;
      _videoType = videoType ?? VideoType.ugc;
      this.width = width;
      this.height = height;
      this.dataSource = dataSource;
      // 初始化数据加载状态
      dataStatus = DataStatus.loading;
      _aid = aid;
      _bvid = bvid;
      this.cid = cid;
      _epid = epid;
      _seasonId = seasonId;
      _pgcType = pgcType;

      if (showSeekPreview) {
        _clearPreview();
      }

      await open(
        MediaDescriptor(
          uri: dataSource.videoSource,
          audioUri: dataSource.audioSource,
        ),
        seekTo: seekTo,
        autoplay: autoplay,
        isLive: isLive,
        isVertical: isVertical,
        width: width,
        height: height,
        duration: duration,
        onInit: onInit,
        source: dataSource,
        adapterExtras: buildAdapterExtras(volume),
        autoFullScreenFlag: autoFullScreenFlag,
      );
    } catch (err, stackTrace) {
      dataStatus = DataStatus.error;
      if (kDebugMode) {
        debugPrint(stackTrace.toString());
        debugPrint('plPlayer err:  $err');
      }
    } finally {
      processing = false;
    }
  }

  /// 构建 B站 专属播放参数（音轨分离、音频归一化），合并进核心 extras。
  Map<String, String> buildAdapterExtras(Volume? volume) {
    final extras = <String, String>{};

    if (dataSource.audioSource case final audio? when (audio.isNotEmpty)) {
      if (!onlyPlayAudio) {
        extras['audio-files'] =
            '"${Platform.isWindows ? audio.replaceAll(';', r'\;') : audio.replaceAll(':', r'\:')}"';
      }
      if (enableAudioNormalization) {
        final String audioNormalization;
        if (volume != null && volume.isNotEmpty) {
          audioNormalization = _audioNormalizationParam.replaceFirstMapped(
            _loudnormRegExp,
            (i) =>
                'loudnorm=${volume.format(
                  Map.fromEntries(
                    i.group(1)!.split(':').map((item) {
                      final parts = item.split('=');
                      return MapEntry(parts[0].toLowerCase(), num.parse(parts[1]));
                    }),
                  ),
                )}',
          );
        } else {
          audioNormalization = _audioNormalizationParam.replaceFirst(
            _loudnormRegExp,
            AudioNormalization.getParamFromConfig(Pref.fallbackNormalization),
          );
        }
        if (audioNormalization.isNotEmpty) {
          extras['lavfi-complex'] = '"[aid1] $audioNormalization [ao]"';
        }
      }
    }

    return extras;
  }

  // 记录播放记录
  Future<void>? makeHeartBeat(
    int progress, {
    HeartBeatType type = .playing,
    bool isManual = false,
    dynamic aid,
    dynamic bvid,
    dynamic cid,
    dynamic epid,
    dynamic seasonId,
    dynamic pgcType,
    VideoType? videoType,
  }) {
    if (isLive ||
        !enableHeart ||
        progress == 0 ||
        (playerStatus.isPaused && !isManual)) {
      return null;
    }

    Future<void> send() {
      return VideoHttp.heartBeat(
        aid: aid ?? _aid,
        bvid: bvid ?? _bvid,
        cid: cid ?? this.cid,
        progress: progress,
        epid: epid ?? _epid,
        seasonId: seasonId ?? _seasonId,
        subType: pgcType ?? _pgcType,
        videoType: videoType ?? _videoType,
      );
    }

    switch (type) {
      case .playing:
        if (progress - heartDuration >= 5) {
          heartDuration = progress;
          return send();
        }
      case .status:
        if (progress - heartDuration >= 2) {
          heartDuration = progress;
          return send();
        }
      case .completed:
        if (playerStatus.isCompleted &&
            (durationInMilliseconds - positionInMilliseconds) <= 1000) {
          progress = -1;
        }
        return send();
    }
    return null;
  }

  void setPlayRepeat(PlayRepeat type) {
    playRepeat = type;
    if (!tempPlayerConf) video.put(VideoBoxKey.playRepeat, type.index);
  }

  void updatePreviewIndex(int seconds) {
    if (videoShot == null) {
      videoShot = LoadingState.loading();
      getVideoShot();
      return;
    }
    if (videoShot case Success(:final response)) {
      showPreview = true;
      previewIndex.value = max(
        0,
        (response.index.where((item) => item <= seconds).length - 2),
      );
    }
  }

  void _clearPreview() {
    showPreview = false;
    previewIndex.value = null;
    videoShot = null;
    for (final i in previewCache.values) {
      i?.dispose();
    }
    previewCache.clear();
  }

  Future<void> getVideoShot() async {
    videoShot = await VideoHttp.videoshot(bvid: bvid, cid: cid!);
  }

  Future<void> takeScreenshot() async {
    SmartDialog.showToast('截图中');
    final time = DurationUtils.formatDuration(
      positionInMilliseconds / 1000,
    ).replaceAll(':', '-');
    final image = await videoPlayerController?.screenshot();
    if (image != null) {
      SmartDialog.showToast('点击弹窗保存截图');
      showDialog(
        context: AppNavigator.context!,
        builder: (context) => GestureDetector(
          onTap: () async {
            final bytes = await image.toByteData(format: .png);
            if (bytes != null) {
              ImageUtils.saveByteImg(
                bytes: bytes.buffer.asUint8List(),
                fileName: 'screenshot_${cid}_$time',
              );
            }
            AppNavigator.back();
          },
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: min(MediaQuery.widthOf(context) / 3, 350),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 5,
                      color: ColorScheme.of(context).surface,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: RawImage(image: image),
                  ),
                ),
              ),
            ),
          ),
        ),
      ).whenComplete(image.dispose);
    } else {
      SmartDialog.showToast('截图失败');
    }
  }
}
