// OttoHub 适配器的视频页宿主桩实现。
//
// OttoHub 复用 Bilibili 路由表（`routes => BiliBridge.registerRoutes()`），
// 视频页主框架为通用层（lib/pages/video/）；OttoHub 播放能力由 SDK 承载，
// 本桩仅保证页面可打开不崩：播放器返回可构造的 PlayerController 实例（不实际
// 播放），面板/弹层返回占位或空实现（防御性降级，不抛异常）。


import 'package:flutter/material.dart';


import 'package:skf/common/widgets/progress_bar/segment_progress_bar.dart';
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/models/user_types.dart';

import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/video/controller.dart';
import 'package:skf/pages/video/video_host.dart';
import 'package:skf/pages/video/video_models.dart';
import 'package:skf/player/models/data_source.dart';
import 'package:skf/player/models/heart_beat_type.dart';
import 'package:skf/player/models/play_repeat.dart';
import 'package:skf/player/player_controller.dart';

class _OttoPlayerHost implements VideoPlayerHost {
  PlayerController? _player;

  @override
  PlayerController get player => _player ??= PlayerController();

  @override
  PlayerController acquirePlayer() => player;

  @override
  bool get tryLook => false;

  @override
  bool get enableAudioNormalization => false;

  @override
  bool get enableHeart => false;

  @override
  bool get enableBlock => false;

  @override
  bool get enableSponsorBlock => false;

  @override
  bool get enablePgcSkip => false;

  @override
  bool get playerDanmakuVisible => false;

  @override
  void setPlayerDanmakuVisible(bool value) {}

  @override
  bool get danmakuEnabled => false;

  @override
  void toggleDanmakuEnabled() {}

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
  }) async {}

  @override
  void setPlayCallBack(PlayCallback? playCallBack) {}

  @override
  void updatePlayCount() {}

  @override
  bool dmStateContains(int cid) => false;

  @override
  bool get showDmChart => false;
  @override
  String getCdnUrl(List<String> urls, {bool isAudio = false}) =>
      urls.isEmpty ? '' : urls.first;
}

/// OttoHub 视频页宿主桩。
class OttoVideoHost extends VideoHost {
  final _playerHost = _OttoPlayerHost();


  @override
  VideoPlayerHost get playerHost => _playerHost;

  @override
  bool get isLogin => false;

  @override
  bool get isVideoLogin => false;

  @override
  List<VideoDecodeFormatType> get preferCodecs => const <VideoDecodeFormatType>[];

  @override
  CorePlaybackConfig selectPlayback({
    required CorePlayUrlModel data,
    required int? cacheVideoQa,
    required int cacheAudioQa,
  }) {
    return CorePlaybackConfig(
      videoUrl: '',
      audioUrl: '',
      videoQaCode: VideoQuality.fluent360.code,
      decodeFormat: VideoDecodeFormatType.AVC,
    );
  }

  @override
  VideoBlock createBlock(VideoDetailController controller) => _OttoVideoBlock();

  @override
  void reportVideo(int aid) {}

  @override
  Future<void> onVideoDetailDispose(String heroTag) async {}

  @override
  Widget buildPlayer({
    required String heroTag,
    required double width,
    required double height,
    bool isPipMode = false,
    required bool isPortrait,
  }) {
    return const SizedBox.expand();
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
      const SizedBox.shrink();

  @override
  Widget buildUgcIntroPanel({
    required Key key,
    required String heroTag,
    required bool isPortrait,
    required bool isHorizontal,
  }) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildRelatedPanel({required Key key, required String heroTag}) =>
      const SizedBox.shrink();

  @override
  Widget buildPgcIntroPage({
    required Key key,
    required String heroTag,
    required int cid,
    required double maxWidth,
    required bool isLandscape,
  }) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildSeasonPanel({required String heroTag}) => const SizedBox.shrink();

  @override
  Widget buildReplyPanel({
    required Key key,
    required String heroTag,
    bool isNested = false,
  }) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildReplyTabLabel({required String heroTag}) => const SizedBox.shrink();

  @override
  void animateReplyToTop(String heroTag) {}

  @override
  bool shouldShowSeasonPanel(String heroTag, {required bool isPortrait}) =>
      false;

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
  }) async {}

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
  void showMediaListPanel(BuildContext context, String heroTag) {}

  @override
  void showNoteList(BuildContext context, String heroTag) {}

  @override
  Future<void> showDownloadPanel(BuildContext context, String heroTag) async {}

  @override
  void openAudioPage(String heroTag) {}

  @override
  void onBlock(BuildContext context, String heroTag) {}

  @override
  void showSBDetail(String heroTag) {}

  @override
  Future<bool> getSteinEdgeInfo({
    required String heroTag,
    required String bvid,
    required int? graphVersion,
    int? edgeId,
  }) async =>
      false;

  @override
  Future<LoadingState<List<double>>> fetchDmTrend({
    required String bvid,
    required int cid,
  }) async =>
      const Error(null);

  @override
  Future<List<VideoSubtitleItem>?> fetchDmSubtitles({
    required int aid,
    required int cid,
  }) async =>
      null;

  @override
  bool isWatchLaterSource(Object? sourceType) => false;

  @override
  bool isFavSource(Object? sourceType) => false;

  @override
  int sourceMediaType(Object? sourceType) => -1;

  @override
  bool isFileSourceSource(Object? sourceType) => false;

  @override
  bool isPlayAllSource(Object? sourceType) => false;

  @override
  ({int width, int height})? partDimension(String heroTag, int cid) => null;

  @override
  void applyPgcClipInfo(String heroTag, List<Map<String, dynamic>>? clipInfoList) {}

  @override
  void applyContinuePlayingPart(String heroTag, {
    required int? lastPlayCid,
    required int currentCid,
  }) {}

  @override
  bool isSteinGate(String heroTag) => false;

  @override
  String? videoTitle(String heroTag) => null;

  @override
  void onChangeEpisodeFromMedia(String heroTag, CoreMediaListItemModel item) {}

  @override
  CoreFileEntryInfo? fileEntryInfo(Object? entry) => null;

  @override
  bool get isShutdownTimerWaiting => false;

  @override
  void handleShutdownTimer() {}
}

/// OttoHub 片段跳过引擎桩：全部 no-op，不抛异常。
class _OttoVideoBlock implements VideoBlock {
  @override
  List<Segment> get segmentProgressList => const <Segment>[];

  @override
  GlobalKey<AnimatedListState> get listKey => GlobalKey<AnimatedListState>();

  @override
  List<Object> get listData => const <Object>[];

  @override
  bool get isBlock => false;

  @override
  bool get enableBlock => false;

  @override
  void initSkip() {}

  @override
  void resetBlock() {}

  @override
  void handleSBData(List<CoreSegmentItemModel> list) {}

  @override
  Future<void> querySponsorBlock({required String bvid, required int cid}) async {}

  @override
  void onAddItem(Object item) {}

  @override
  void onRemoveItem(int index, Object item) {}

  @override
  Future<void>? onSkip(Object item, {bool isSeek = true}) => null;

  @override
  Duration? getFirstSegment([int pos = 0]) => null;

  @override
  Widget buildItem(Object item, Animation<double> animation) =>
      const SizedBox.shrink();

  @override
  void cancelBlockListener() {}

  @override
  void showSBDetail() {}

  @override
  void dispose() {}
}
