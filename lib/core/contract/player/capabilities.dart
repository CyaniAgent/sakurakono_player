// 播放能力声明与默认(不支持)实现。
//
// 适配器覆写 getter 返回自身实现;未覆写时使用 Unsupported 实现:
// `supported == false` + 方法全部 no-op,页面据此降级隐藏入口/面板。

import 'package:flutter/widgets.dart';

import 'package:skf/common/widgets/progress_bar/segment_progress_bar.dart'
    show Segment;
import 'package:skf/core/contract/player/audio_mode_capability.dart';
import 'package:skf/core/contract/player/playback_models.dart';
import 'package:skf/core/contract/player/danmaku_trend_capability.dart';
import 'package:skf/core/contract/player/download_capability.dart';
import 'package:skf/core/contract/player/interactive_capability.dart';
import 'package:skf/core/contract/player/notes_capability.dart';
import 'package:skf/core/contract/player/playback_source_capability.dart';
import 'package:skf/core/contract/player/playlist_capability.dart';
import 'package:skf/core/contract/player/segment_skip_capability.dart';
import 'package:skf/core/contract/player/series_capability.dart';
import 'package:skf/core/contract/player/subtitle_capability.dart';
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/video/video_models.dart';

/// 播放能力集合。实现方通常 `with DefaultPlayerCapabilities` 后
/// 仅覆写支持的能力。
abstract class PlayerCapabilities {
  SegmentSkipCapability get segmentSkip;
  SeriesCapability get series;
  PlaylistCapability get playlist;
  NotesCapability get notes;
  AudioModeCapability get audioMode;
  InteractiveCapability get interactive;
  SubtitleCapability get subtitle;
  DanmakuTrendCapability get danmakuTrend;
  DownloadPanelCapability get downloadPanel;
  PlaybackSourceCapability get playbackSource;
}

/// 全部能力 = 不支持的默认实现。
mixin DefaultPlayerCapabilities implements PlayerCapabilities {
  @override
  SegmentSkipCapability get segmentSkip => const _UnsupportedSegmentSkip();

  @override
  SeriesCapability get series => const _UnsupportedSeries();

  @override
  PlaylistCapability get playlist => const _UnsupportedPlaylist();

  @override
  NotesCapability get notes => const _UnsupportedNotes();

  @override
  AudioModeCapability get audioMode => const _UnsupportedAudioMode();

  @override
  InteractiveCapability get interactive => const _UnsupportedInteractive();

  @override
  SubtitleCapability get subtitle => const _UnsupportedSubtitle();

  @override
  DanmakuTrendCapability get danmakuTrend => const _UnsupportedDanmakuTrend();

  @override
  DownloadPanelCapability get downloadPanel => const _UnsupportedDownloadPanel();

  @override
  PlaybackSourceCapability get playbackSource =>
      const _UnsupportedPlaybackSource();
}

class _UnsupportedSegmentSkip implements SegmentSkipCapability {
  const _UnsupportedSegmentSkip();

  @override
  bool get supported => false;

  @override
  bool get enableBlock => false;

  @override
  bool get enableSponsorBlock => false;

  @override
  SegmentSkipEngine createEngine(dynamic videoDetailController) =>
      const _UnsupportedSegmentSkipEngine();

  @override
  void onBlock(BuildContext context, String heroTag) {}

  @override
  void showSBDetail(String heroTag) {}
}

class _UnsupportedSegmentSkipEngine implements SegmentSkipEngine {
  const _UnsupportedSegmentSkipEngine();

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

class _UnsupportedSeries implements SeriesCapability {
  const _UnsupportedSeries();

  @override
  bool get supported => false;

  @override
  bool get enablePgcSkip => false;

  @override
  Widget buildSeriesIntroPage({
    required Key key,
    required String heroTag,
    required int cid,
    required double maxWidth,
    required bool isLandscape,
  }) =>
      const SizedBox.shrink();

  @override
  Widget buildSeasonPanel({required String heroTag}) => const SizedBox.shrink();

  @override
  bool shouldShowSeasonPanel(String heroTag, {required bool isPortrait}) =>
      false;

  @override
  void applyClipInfo(String heroTag, List<Map<String, dynamic>>? clipInfoList) {}
}

class _UnsupportedPlaylist implements PlaylistCapability {
  const _UnsupportedPlaylist();

  @override
  bool get supported => false;

  @override
  void showMediaListPanel(BuildContext context, String heroTag) {}

  @override
  void onChangeEpisodeFromMedia(String heroTag, CoreMediaListItemModel item) {}

  @override
  void applyContinuePlayingPart(
    String heroTag, {
    required int? lastPlayCid,
    required int currentCid,
  }) {}

  @override
  bool isWatchLaterSource(Object? sourceType) => false;

  @override
  bool isFavSource(Object? sourceType) => false;

  @override
  int sourceMediaType(Object? sourceType) => 0;

  @override
  bool isPlayAllSource(Object? sourceType) => false;

  @override
  bool isFileSourceSource(Object? sourceType) => false;
}

class _UnsupportedNotes implements NotesCapability {
  const _UnsupportedNotes();

  @override
  bool get supported => false;

  @override
  void showNoteList(BuildContext context, String heroTag) {}
}

class _UnsupportedAudioMode implements AudioModeCapability {
  const _UnsupportedAudioMode();

  @override
  bool get supported => false;

  @override
  void openAudioPage(String heroTag) {}
}

class _UnsupportedInteractive implements InteractiveCapability {
  const _UnsupportedInteractive();

  @override
  bool get supported => false;

  @override
  Future<bool> getSteinEdgeInfo({
    required String heroTag,
    required String bvid,
    required int? graphVersion,
    int? edgeId,
  }) =>
      Future.value(false);

  @override
  bool isSteinGate(String heroTag) => false;
}

class _UnsupportedSubtitle implements SubtitleCapability {
  const _UnsupportedSubtitle();

  @override
  bool get supported => false;

  @override
  Future<List<VideoSubtitleItem>?> fetchSubtitles({
    required int aid,
    required int cid,
  }) =>
      Future.value(null);
}

class _UnsupportedDanmakuTrend implements DanmakuTrendCapability {
  const _UnsupportedDanmakuTrend();

  @override
  bool get supported => false;

  @override
  Future<LoadingState<List<double>>> fetchTrend({
    required String bvid,
    required int cid,
  }) =>
      Future.value(const Error('not supported'));
}

class _UnsupportedDownloadPanel implements DownloadPanelCapability {
  const _UnsupportedDownloadPanel();

  @override
  bool get supported => false;

  @override
  Future<void> showDownloadPanel(BuildContext context, String heroTag) async {}
}

class _UnsupportedPlaybackSource implements PlaybackSourceCapability {
  const _UnsupportedPlaybackSource();

  @override
  bool get supported => false;

  @override
  List<VideoDecodeFormatType> get preferCodecs =>
      const <VideoDecodeFormatType>[];

  @override
  CorePlaybackConfig selectPlayback({
    required CorePlayUrlModel data,
    required int? cacheVideoQa,
    required int cacheAudioQa,
  }) =>
      CorePlaybackConfig(
        videoUrl: '',
        audioUrl: '',
        videoQaCode: cacheVideoQa ?? 0,
        decodeFormat: VideoDecodeFormatType.values.first,
      );

  @override
  ({int width, int height})? partDimension(String heroTag, int cid) => null;
}
