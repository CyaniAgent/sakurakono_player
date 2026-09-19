// OttoHub 适配器的视频页宿主实现。
//
// 视频页主框架为通用层(lib/pages/video/);播放器装配使用框架
// lib/player(PlayerView + PlayerController,media_kit 后端),数据来自
// OttoVideoRepository.videoUrl(ottohub SDK)。不支持的能力按契约返回
// no-op/false(页面自动降级)。
//
// 已接入:播放器装配(含弹幕层 OttoPlDanmaku)、投稿简介面板、评论面板
// (含评论 tab 计数与回顶)、相关视频面板、发弹幕面板、登录态
// (经 OttoAccountProvider)。能力接口(segmentSkip/notes/downloadPanel/
// audioMode/playlist/series 等)使用 DefaultPlayerCapabilities 默认降级。

import 'package:flutter/material.dart';

import 'package:skf/adapters/ottohub/services/otto_account_provider.dart';
import 'package:skf/adapters/ottohub/services/otto_danmaku_layer.dart';
import 'package:skf/adapters/ottohub/services/otto_video_intro_panel.dart';
import 'package:skf/adapters/ottohub/services/otto_video_page_hub.dart';
import 'package:skf/adapters/ottohub/services/otto_video_related_panel.dart';
import 'package:skf/adapters/ottohub/services/otto_video_reply_panel.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/player/core_player_service.dart';
import 'package:skf/core/contract/player/playback_source_capability.dart';
import 'package:skf/pages/video/controller.dart';
import 'package:skf/pages/video/video_host.dart';
import 'package:skf/pages/video/video_models.dart';
import 'package:skf/player/models/data_source.dart';
import 'package:skf/player/models/heart_beat_type.dart';
import 'package:skf/player/models/play_repeat.dart';
import 'package:skf/player/player_controller.dart';
import 'package:skf/player/player_view.dart';
import 'package:skf/router/app_navigator.dart';

class _OttoPlayerHost implements VideoPlayerHost {
  PlayerController? _player;

  @override
  PlayerController get player {
    // dispose() 会把 currentInstance 置空——以此为"已销毁"信号自动重建。
    if (_player == null || PlayerController.currentInstance != _player) {
      final fresh = PlayerController();
      PlayerController.currentInstance = fresh;
      fresh.playerCount = 1;
      _player = fresh;
    }
    return _player!;
  }

  @override
  PlayerController acquirePlayer() => player;

  @override
  bool get enableAudioNormalization => false;

  @override
  bool get enableHeart => false;

  @override
  bool get playerDanmakuVisible => false;

  @override
  void setPlayerDanmakuVisible(bool value) {}

  @override
  bool get danmakuEnabled => OttoDanmakuToggle.instance.enabled;

  @override
  void toggleDanmakuEnabled() => OttoDanmakuToggle.instance.toggle();

  @override
  PlayRepeat get playerPlayRepeat => PlayRepeat.listOrder;

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
  }) =>
      null;

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
    final player = acquirePlayer();
    return player.open(
      MediaDescriptor(
        uri: source.videoSource,
        audioUri: source.audioSource,
        title: bvid,
      ),
      source: source,
      seekTo: seekTo,
      autoplay: autoplay,
      isVertical: isVertical,
      width: width,
      height: height,
      duration: duration,
      onInit: onInit,
      autoFullScreenFlag: autoFullScreenFlag,
    );
  }

  @override
  void setPlayCallBack(PlayCallback? playCallBack) {}

  @override
  void updatePlayCount() {}

  @override
  bool dmStateContains(int cid) => false;

  @override
  bool get showDmChart => false;
}

/// OttoHub 视频页宿主。
class OttoVideoHost extends VideoHost {
  final _playerHost = _OttoPlayerHost();
  final _hub = OttoVideoPageHub();

  /// 页面销毁前 registry 里还能查到控制器;销毁过程中面板重建时返回 null。
  VideoDetailController? _controller(String heroTag) =>
      videoDetailRegistry[heroTag];

  @override
  VideoPlayerHost get playerHost => _playerHost;

  @override
  bool get isLogin => appRead(ottoAccountProvider).isLogin;

  @override
  bool get isVideoLogin => appRead(ottoAccountProvider).isLogin;

  @override
  PlaybackSourceCapability get playbackSource => _OttoPlaybackSource();

  @override
  Future<void> onVideoDetailDispose(String heroTag) async {
    _hub.dispose(heroTag);
  }

  @override
  Widget buildPlayer({
    required String heroTag,
    required double width,
    required double height,
    bool isPipMode = false,
    required bool isPortrait,
  }) {
    final player = playerHost.player;
    final vid = _controller(heroTag)?.cid;
    return PlayerView(
      maxWidth: width,
      maxHeight: height,
      plPlayerController: player,
      headerControl: ListenableBuilder(
        listenable: _hub.state(heroTag),
        builder: (context, _) =>
            _OttoPlayerHeader(title: videoTitle(heroTag) ?? ''),
      ),
      danmuWidget: vid == null || vid <= 0
          ? null
          : ListenableBuilder(
              listenable: player,
              builder: (_, _) => OttoPlDanmaku(
                key: ValueKey(vid),
                vid: vid,
                playerController: player,
                isFullScreen: player.isFullScreen,
                size: Size(width, height),
              ),
            ),
    );
  }

  @override
  List<Widget> buildPlayerOverlays({
    required String heroTag,
    required bool isFullScreen,
    required double maxHeight,
  }) =>
      const <Widget>[];

  @override
  Widget? buildKeyboardFocus({
    required Widget child,
    required String heroTag,
    required VoidCallback onSendDanmaku,
    required bool Function() canPlay,
    required bool Function() onSkipSegment,
  }) =>
      null;

  @override
  void showSettingSheet(GlobalKey headerKey) {}

  @override
  Widget buildLocalIntroPanel({required Key key, required String heroTag}) =>
      const SliverToBoxAdapter(child: SizedBox.shrink());

  @override
  Widget buildUgcIntroPanel({
    required Key key,
    required String heroTag,
    required bool isPortrait,
    required bool isHorizontal,
  }) {
    final bvid = _controller(heroTag)?.bvid;
    if (bvid == null || bvid.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return OttoVideoIntroPanel(
      key: key,
      hub: _hub,
      heroTag: heroTag,
      bvid: bvid,
    );
  }

  @override
  Widget buildRelatedPanel({required Key key, required String heroTag}) {
    final bvid = _controller(heroTag)?.bvid;
    if (bvid == null || bvid.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return OttoVideoRelatedPanel(key: key, bvid: bvid);
  }

  @override
  Widget buildReplyPanel({
    required Key key,
    required String heroTag,
    bool isNested = false,
  }) {
    final ctl = _controller(heroTag);
    final vid = ctl?.aid ?? (ctl == null ? null : int.tryParse(ctl.bvid));
    if (vid == null || vid <= 0) {
      return const SizedBox.shrink();
    }
    return OttoVideoReplyPanel(
      key: key,
      hub: _hub,
      heroTag: heroTag,
      vid: vid,
      isNested: isNested,
    );
  }

  @override
  Widget buildReplyTabLabel({required String heroTag}) {
    final state = _hub.state(heroTag);
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => Tab(
        text: state.commentCount > 0 ? '评论 ${state.commentCount}' : '评论',
      ),
    );
  }

  @override
  void animateReplyToTop(String heroTag) {
    final ctr = _hub.replyScrollCtrs[heroTag];
    if (ctr != null && ctr.hasClients) {
      ctr.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

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
  }) {
    // OttoHub 弹幕按视频(vid)维度,cid 即 vid。
    return showOttoSendDanmakuSheet(
      vid: cid,
      progress: progress,
      initialValue: initialValue,
      onSave: onSave,
      dmConfig: dmConfig,
      onSaveDmConfig: onSaveDmConfig,
    );
  }

  @override
  void startIntroTimer(String heroTag) {}

  @override
  void cancelIntroTimer(String heroTag) {}

  @override
  void disposeIntro(String heroTag) {}

  @override
  bool nextPlay(String heroTag) => false;

  @override
  Future<void> viewLater(String heroTag) async {}

  @override
  ({int width, int height})? partDimension(String heroTag, int cid) => null;

  @override
  CoreFileEntryInfo? fileEntryInfo(Object? entry) => null;

  @override
  String? videoTitle(String heroTag) {
    final title = _hub.state(heroTag).title;
    return title.isEmpty ? null : title;
  }

  @override
  bool get isShutdownTimerWaiting => false;

  @override
  void handleShutdownTimer() {}
}

/// OttoHub 播放地址选择:取服务器返回的第一个直链(mp4 优先,m3u8 兜底)。
class _OttoPlaybackSource implements PlaybackSourceCapability {
  @override
  bool get supported => true;

  @override
  List<VideoDecodeFormatType> get preferCodecs => const <VideoDecodeFormatType>[];

  @override
  CorePlaybackConfig selectPlayback({
    required CorePlayUrlModel data,
    required int? cacheVideoQa,
    required int cacheAudioQa,
  }) {
    final urls = <String>[
      for (final d in data.durl ?? <Map<String, dynamic>>[])
        if (d['url'] is String) d['url'] as String,
    ];
    return CorePlaybackConfig(
      videoUrl: urls.isNotEmpty ? urls.first : '',
      audioUrl: '',
      videoQaCode: cacheVideoQa ?? data.quality ?? 0,
      decodeFormat: VideoDecodeFormatType.AVC,
      width: null,
      height: null,
    );
  }

  @override
  ({int width, int height})? partDimension(String heroTag, int cid) => null;
}

/// 最小播放器头部:返回按钮(标题由页面框架展示)。
class _OttoPlayerHeader extends StatelessWidget {
  const _OttoPlayerHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: AppNavigator.back,
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
