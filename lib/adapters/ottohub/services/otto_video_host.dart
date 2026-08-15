// OttoHub 适配器的视频页宿主桩实现。
//
// OttoHub 复用 Bilibili 路由表（`routes => BiliBridge.registerRoutes()`），
// 视频页主框架为通用层（lib/pages/video/）；OttoHub 播放能力由 SDK 承载，
// 本桩仅保证编译通过，播放器/弹幕/回复/下载等 B站 专属能力在 OttoHub
// 模式下均抛 `not_implemented`（与 OttoHub stub 约定一致）。

import 'dart:ui' show Color;

import 'package:flutter/widgets.dart'
    show
    BuildContext,
    GlobalKey,
    Key,
    ValueChanged,
    VoidCallback,
    Widget;

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
  Never _err() => throw UnimplementedError('not_implemented');

  @override
  PlayerController get player => _err();

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
  bool dmStateContains(int cid) => _err();

  @override
  bool get showDmChart => false;
  @override
  String getCdnUrl(List<String> urls, {bool isAudio = false}) =>
      urls.isEmpty ? '' : urls.first;
}

/// OttoHub 视频页宿主桩。
class OttoVideoHost implements VideoHost {
  final _playerHost = _OttoPlayerHost();

  Never _err() => throw UnimplementedError('not_implemented');

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
  }) =>
      _err();

  @override
  VideoBlock createBlock(VideoDetailController controller) => _err();

  @override
  void reportVideo(int aid) => _err();

  @override
  Future<void> onVideoDetailDispose(String heroTag) async {}

  @override
  void disposeMemberPage(String heroTag) {}

  @override
  Widget buildPlayer({
    required double width,
    required double height,
    bool isPipMode = false,
    required bool isPortrait,
  }) =>
      _err();

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
      _err();

  @override
  Widget buildUgcIntroPanel({
    required Key key,
    required String heroTag,
    required bool isPortrait,
    required bool isHorizontal,
  }) =>
      _err();

  @override
  Widget buildRelatedPanel({required Key key, required String heroTag}) =>
      _err();

  @override
  Widget buildPgcIntroPage({
    required Key key,
    required String heroTag,
    required int cid,
    required double maxWidth,
    required bool isLandscape,
  }) =>
      _err();

  @override
  Widget buildSeasonPanel({required String heroTag}) => _err();

  @override
  Widget buildReplyPanel({
    required Key key,
    required String heroTag,
    bool isNested = false,
  }) =>
      _err();

  @override
  Widget buildReplyTabLabel({required String heroTag}) => _err();

  @override
  void animateReplyToTop(String heroTag) {}

  @override
  bool shouldShowSeasonPanel(String heroTag, {required bool isPortrait}) =>
      false;

  @override
  Future<void> showShootDanmakuSheet({
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
  void showMediaListPanel(BuildContext context, String heroTag) => _err();

  @override
  void showNoteList(BuildContext context, String heroTag) => _err();

  @override
  Future<void> showDownloadPanel(BuildContext context, String heroTag) async {}

  @override
  void openAudioPage(String heroTag) => _err();

  @override
  void onBlock(BuildContext context, String heroTag) => _err();

  @override
  void showSBDetail(String heroTag) => _err();

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
