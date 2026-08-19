/// Riverpod-based alternative to the GetX [VideoDetailController].
///
/// This is a transitional file — the GetX controller remains the production
/// controller. This Riverpod variant mirrors the essential state and lifecycle
/// for incremental migration.
///
/// The controller is auto-disposed when the video page is removed from the
/// navigation stack, and watches [accountProvider] for auth state reactivity.
library;


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/common/widgets/progress_bar/segment_progress_bar.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/video/video_models.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

/// Immutable snapshot of the video detail page state.
class VideoDetailState {
  const VideoDetailState({
    this.bvid = '',
    this.aid = 0,
    this.cid = 0,
    this.epId,
    this.seasonId,
    this.pgcType,
    this.heroTag = '',
    this.cover = '',
    this.videoType = CoreVideoType.ugc,
    this.isVertical = false,
    this.isFileSource = false,
    this.isPlayAll = false,
    this.isPortrait = true,
    this.videoState = false,
    this.autoPlay = false,
    this.currentVideoQa,
    this.currentAudioQa,
    this.currentDecodeFormats = VideoDecodeFormatType.AVC,
    this.scrollRatio = 0.0,
    this.seasonIndex = 0,
    this.videoLabel = '',
    this.showVP = true,
    this.viewPointList = const [],
    this.subtitles = const [],
    this.vttSubtitlesIndex = -1,
    this.graphVersion,
    this.showSteinEdgeInfo = false,
    this.hasSteinChoices = false,
    this.dmTrend,
    this.showDmTrendChart = true,
    this.continuePlayingPart = false,
  });

  // -- Route arguments --

  final String bvid;
  final int aid;
  final int cid;
  final int? epId;
  final int? seasonId;
  final int? pgcType;
  final String heroTag;
  final String cover;

  // -- Video type & source --

  final CoreVideoType videoType;
  final bool isVertical;
  final bool isFileSource;
  final bool isPlayAll;

  // -- Player state --

  final bool isPortrait;
  final bool videoState;
  final bool autoPlay;
  final VideoQuality? currentVideoQa;
  final AudioQuality? currentAudioQa;
  final VideoDecodeFormatType currentDecodeFormats;
  final double scrollRatio;
  final int seasonIndex;
  final String videoLabel;

  // -- View points / subtitles --

  final bool showVP;
  final List<ViewPointSegment> viewPointList;
  final List<VideoSubtitleItem> subtitles;
  final int vttSubtitlesIndex;

  // -- Interactive video --

  final int? graphVersion;
  final bool showSteinEdgeInfo;
  final bool hasSteinChoices;

  // -- Danmaku trend --

  final LoadingState<List<double>>? dmTrend;
  final bool showDmTrendChart;

  // -- Multi-part --

  final bool continuePlayingPart;

  bool get isUgc => videoType == CoreVideoType.ugc;

  VideoDetailState copyWith({
    String? bvid,
    int? aid,
    int? cid,
    int? epId,
    bool clearEpId = false,
    int? seasonId,
    bool clearSeasonId = false,
    int? pgcType,
    bool clearPgcType = false,
    String? heroTag,
    String? cover,
    CoreVideoType? videoType,
    bool? isVertical,
    bool? isFileSource,
    bool? isPlayAll,
    bool? isPortrait,
    bool? videoState,
    bool? autoPlay,
    VideoQuality? currentVideoQa,
    bool clearVideoQa = false,
    AudioQuality? currentAudioQa,
    bool clearAudioQa = false,
    VideoDecodeFormatType? currentDecodeFormats,
    double? scrollRatio,
    int? seasonIndex,
    String? videoLabel,
    bool? showVP,
    List<ViewPointSegment>? viewPointList,
    List<VideoSubtitleItem>? subtitles,
    int? vttSubtitlesIndex,
    int? graphVersion,
    bool clearGraphVersion = false,
    bool? showSteinEdgeInfo,
    bool? hasSteinChoices,
    LoadingState<List<double>>? dmTrend,
    bool clearDmTrend = false,
    bool? showDmTrendChart,
    bool? continuePlayingPart,
  }) {
    return VideoDetailState(
      bvid: bvid ?? this.bvid,
      aid: aid ?? this.aid,
      cid: cid ?? this.cid,
      epId: clearEpId ? null : (epId ?? this.epId),
      seasonId: clearSeasonId ? null : (seasonId ?? this.seasonId),
      pgcType: clearPgcType ? null : (pgcType ?? this.pgcType),
      heroTag: heroTag ?? this.heroTag,
      cover: cover ?? this.cover,
      videoType: videoType ?? this.videoType,
      isVertical: isVertical ?? this.isVertical,
      isFileSource: isFileSource ?? this.isFileSource,
      isPlayAll: isPlayAll ?? this.isPlayAll,
      isPortrait: isPortrait ?? this.isPortrait,
      videoState: videoState ?? this.videoState,
      autoPlay: autoPlay ?? this.autoPlay,
      currentVideoQa: clearVideoQa ? null : (currentVideoQa ?? this.currentVideoQa),
      currentAudioQa: clearAudioQa ? null : (currentAudioQa ?? this.currentAudioQa),
      currentDecodeFormats: currentDecodeFormats ?? this.currentDecodeFormats,
      scrollRatio: scrollRatio ?? this.scrollRatio,
      seasonIndex: seasonIndex ?? this.seasonIndex,
      videoLabel: videoLabel ?? this.videoLabel,
      showVP: showVP ?? this.showVP,
      viewPointList: viewPointList ?? this.viewPointList,
      subtitles: subtitles ?? this.subtitles,
      vttSubtitlesIndex: vttSubtitlesIndex ?? this.vttSubtitlesIndex,
      graphVersion: clearGraphVersion ? null : (graphVersion ?? this.graphVersion),
      showSteinEdgeInfo: showSteinEdgeInfo ?? this.showSteinEdgeInfo,
      hasSteinChoices: hasSteinChoices ?? this.hasSteinChoices,
      dmTrend: clearDmTrend ? null : (dmTrend ?? this.dmTrend),
      showDmTrendChart: showDmTrendChart ?? this.showDmTrendChart,
      continuePlayingPart: continuePlayingPart ?? this.continuePlayingPart,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Riverpod StateNotifier that mirrors the essential state and lifecycle of
/// the GetX-based [VideoDetailController].
///
/// Heavy adapter-dependent logic (player init, danmaku, sponsor block, etc.)
/// is deliberately excluded — those remain in the GetX controller until the
/// adapter bridge is ported to Riverpod providers.
class VideoDetailNotifier extends StateNotifier<VideoDetailState> {
  VideoDetailNotifier(this._ref, Map<String, dynamic> args)
      : super(const VideoDetailState()) {
    _initFromArgs(args);
  }

  final Ref _ref;

  // -- Derived convenience accessors (not in state to avoid rebuilds) --

  /// Whether the current user is logged in — reactively watched.
  bool get isLoginVideo =>
      _ref.read(accountProvider).isLogin;

  /// Computed: show reply section.
  bool get showReply => !state.isFileSource && state.isUgc;

  /// Computed: show related videos.
  bool get showRelatedVideo => !state.isFileSource;

  // -- Lifecycle --

  void _initFromArgs(Map<String, dynamic> args) {
    final videoType = _coreVideoTypeFromArgs(args['videoType']);

    CoreVideoType? actualVideoType;
    if (videoType == CoreVideoType.pgc) {
      if (!isLoginVideo) {
        actualVideoType = CoreVideoType.ugc;
      }
    } else if (args['pgcApi'] == true) {
      actualVideoType = CoreVideoType.pgc;
    }

    final sourceType = args['sourceType'];
    final isFileSource = args['sourceType'] != null &&
        _isFileSourceSourceType(sourceType);
    final isPlayAll = args['sourceType'] != null &&
        _isPlayAllSource(sourceType);

    state = VideoDetailState(
      bvid: args['bvid'] as String? ?? '',
      aid: args['aid'] as int? ?? 0,
      cid: args['cid'] as int? ?? 0,
      epId: args['epId'] as int?,
      seasonId: args['seasonId'] as int?,
      pgcType: args['pgcType'] as int?,
      heroTag: args['heroTag'] as String? ?? '',
      cover: args['cover'] as String? ?? '',
      videoType: actualVideoType ?? videoType,
      isVertical: args['isVertical'] as bool? ?? false,
      isFileSource: isFileSource,
      isPlayAll: isPlayAll,
      autoPlay: args['autoPlay'] as bool? ?? false,
      continuePlayingPart: args['continuePlayingPart'] as bool? ?? false,
    );
  }

  /// Called when the video page is removed from the navigation stack.
  @override
  void dispose() {
    super.dispose();
  }

  // -- State mutations --

  void setVideoState(bool loaded) {
    state = state.copyWith(videoState: loaded);
  }

  void setAutoPlay(bool value) {
    state = state.copyWith(autoPlay: value);
  }

  void setCurrentVideoQa(VideoQuality qa) {
    state = state.copyWith(currentVideoQa: qa);
  }

  void setCurrentAudioQa(AudioQuality? qa) {
    state = state.copyWith(
      currentAudioQa: qa,
      clearAudioQa: qa == null,
    );
  }

  void setCurrentDecodeFormats(VideoDecodeFormatType fmt) {
    state = state.copyWith(currentDecodeFormats: fmt);
  }

  void setVertical(bool vertical) {
    state = state.copyWith(isVertical: vertical);
  }

  void setPortrait(bool portrait) {
    state = state.copyWith(isPortrait: portrait);
  }

  void setScrollRatio(double ratio) {
    state = state.copyWith(scrollRatio: ratio);
  }

  void setSeasonIndex(int index) {
    state = state.copyWith(seasonIndex: index);
  }

  void setVideoLabel(String label) {
    state = state.copyWith(videoLabel: label);
  }

  void toggleShowVP() {
    state = state.copyWith(showVP: !state.showVP);
  }

  void setViewPointList(List<ViewPointSegment> list) {
    state = state.copyWith(viewPointList: list);
  }

  void setSubtitles(List<VideoSubtitleItem> list) {
    state = state.copyWith(subtitles: list);
  }

  void setVttSubtitlesIndex(int index) {
    state = state.copyWith(vttSubtitlesIndex: index);
  }

  void setGraphVersion(int? version) {
    state = state.copyWith(
      graphVersion: version,
      clearGraphVersion: version == null,
    );
  }

  void setShowSteinEdgeInfo(bool show) {
    state = state.copyWith(showSteinEdgeInfo: show);
  }

  void setHasSteinChoices(bool has) {
    state = state.copyWith(hasSteinChoices: has);
  }

  void setDmTrend(LoadingState<List<double>>? trend) {
    state = state.copyWith(
      dmTrend: trend,
      clearDmTrend: trend == null,
    );
  }

  void setShowDmTrendChart(bool show) {
    state = state.copyWith(showDmTrendChart: show);
  }

  /// Reset transient state for episode/part change.
  void onReset() {
    state = state.copyWith(
      videoState: false,
      currentVideoQa: null,
      clearVideoQa: true,
      currentAudioQa: null,
      clearAudioQa: true,
      subtitles: const [],
      vttSubtitlesIndex: -1,
      viewPointList: const [],
      dmTrend: null,
      clearDmTrend: true,
      showSteinEdgeInfo: false,
      hasSteinChoices: false,
      graphVersion: null,
      clearGraphVersion: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provider for a single video detail controller instance.
///
/// Parameterized by the route arguments [Map<String, dynamic>]. The controller
/// auto-disposes when the video page is removed from the navigation stack.
final videoDetailProvider = StateNotifierProvider.autoDispose
    .family<VideoDetailNotifier, VideoDetailState, Map<String, dynamic>>(
  (ref, args) {
    final notifier = VideoDetailNotifier(ref, args);

    // Subscribe to auth state changes so [isLoginVideo] stays current.
    ref.listen<AccountState>(accountProvider, (prev, next) {
      // If login state changed, the notifier can react.
      // For now this is a no-op — actual adapter integration will override
      // the provider with a Bilibili-specific notifier.
    });

    return notifier;
  },
);

// ---------------------------------------------------------------------------
// Helpers (pure, adapter-free)
// ---------------------------------------------------------------------------

CoreVideoType _coreVideoTypeFromArgs(Object? raw) {
  return switch (raw) {
    'pgc' => CoreVideoType.pgc,
    'pugv' => CoreVideoType.pugv,
    _ => CoreVideoType.ugc,
  };
}

bool _isFileSourceSourceType(Object? sourceType) {
  return sourceType?.toString().toLowerCase() == 'file';
}

bool _isPlayAllSource(Object? sourceType) {
  final str = sourceType?.toString().toLowerCase();
  return str == 'playall' || str == 'fav' || str == 'watchlater';
}
