// 视频播放详情页（lib/pages/video/）宿主注入契约。
//
// 页面主框架（view/controller）零适配器依赖，所有 B站 专属能力
// （播放器扩展、弹幕、回复、简介、选集、下载、字幕等）通过本接口注入。
// 适配器侧实现：lib/adapters/bilibili/common/video_host.dart（BiliVideoHost）；
// OttoHub 实验实现：lib/adapters/ottohub/services/otto_video_host.dart。
//
// 接入方式（与 W3 member/mine host 一致）：双端 bridge register() 里
// `Get.lazyPut<VideoHost>(() => BiliVideoHost())`，页面用 `VideoHost.of()` 获取。

import 'dart:async' show Future;
import 'dart:ui' show Color;

import 'package:flutter/animation.dart' show Animation;
import 'package:flutter/widgets.dart' show
    AnimatedListState,
    BuildContext,
    GlobalKey,
    Key,
    ValueChanged,
    VoidCallback,
    Widget;

import 'package:skf/common/widgets/progress_bar/segment_progress_bar.dart'
    show Segment;
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/player/models/data_source.dart';
import 'package:skf/player/models/heart_beat_type.dart';
import 'package:skf/player/models/play_repeat.dart';
import 'package:skf/player/player_controller.dart';
import 'package:get/get.dart';
import 'package:skf/pages/video/controller.dart';
import 'package:skf/pages/video/video_models.dart';

/// 播放器宿主：暴露 B站 扩展播放器（PlPlayerController）上的页面所需成员。
abstract class VideoPlayerHost {
  /// B站: `PlPlayerController.getInstance()`。
  PlayerController get player;

  /// B站: `tryLook`（未登录时的试看画质开关）。
  bool get tryLook;

  /// B站: 音频响度归一化开关。
  bool get enableAudioNormalization;

  /// B站: 播放心跳开关。
  bool get enableHeart;

  /// B站: 片段跳过（赞助/片头片尾）总开关。
  bool get enableBlock;

  /// B站: 赞助片段开关。
  bool get enableSponsorBlock;

  /// B站: 番剧片头片尾跳过开关。
  bool get enablePgcSkip;

  /// 弹幕可见性（B站: `showDanmaku` 字段）。
  bool get playerDanmakuVisible;

  void setPlayerDanmakuVisible(bool value);

  /// 弹幕开关（B站: `enableShowDanmaku`），切换时持久化由宿主负责。
  bool get danmakuEnabled;

  void toggleDanmakuEnabled();

  /// 播放循环模式（B站: `playRepeat`）。
  PlayRepeat get playerPlayRepeat;

  /// 播放心跳上报。
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
  });

  /// 初始化播放数据源（B站: `PlPlayerController.setDataSource`）。
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
  });

  /// 注册播放回调（B站: `PlPlayerController.setPlayCallBack`）。
  void setPlayCallBack(PlayCallback? playCallBack);

  /// 播放计数（B站: `PlPlayerController.updatePlayCount`）。
  void updatePlayCount();

  /// 弹幕是否被 UP 主关闭（B站: `dmState.contains(cid)`）。
  bool dmStateContains(int cid);

  /// 高能进度条开关（B站: `showDmChart`，通用播放器字段）。
  bool get showDmChart;

  /// 按平台/CDN 偏好选择播放地址（B站: `VideoUtils.getCdnUrl`）。
  String getCdnUrl(List<String> urls, {bool isAudio = false});
}

/// 视频页面宿主：主框架（view/controller）的全部 B站 注入点。
abstract class VideoHost {
  /// 获取当前宿主（双端 bridge 注册）。
  static VideoHost of() => Get.find<VideoHost>();

  /// 播放器宿主（B站 扩展播放器表面）。
  VideoPlayerHost get playerHost;

  // ---------- 账号 / 配置 ----------

  /// 是否已登录主账号（B站: `Accounts.main.isLogin`）。
  bool get isLogin;

  /// 视频账号是否已登录（B站: `Accounts.get(AccountType.video).isLogin`）。
  bool get isVideoLogin;

  /// 预设解码格式列表（B站: `BiliPref.preferCodecs`）。
  List<VideoDecodeFormatType> get preferCodecs;

  // ---------- 播放地址选择 ----------

  /// 根据播放数据 + 缓存画质/音质选择实际播放地址与解码格式
  /// （B站: VideoUtils/VideoQuality/AudioQuality 选择逻辑）。
  CorePlaybackConfig selectPlayback({
    required CorePlayUrlModel data,
    required int? cacheVideoQa,
    required int cacheAudioQa,
  });

  // ---------- 片段跳过（SponsorBlock）引擎 ----------

  /// 创建页面级片段跳过引擎（B站: BlockMixin 实现）。
  VideoBlock createBlock(VideoDetailController controller);

  // ---------- 账号相关操作 ----------

  /// 举报视频（B站: `PageUtils.reportVideo(aid)`）。
  void reportVideo(int aid);

  /// 播放器页面销毁回调（B站: `videoPlayerServiceHandler.onVideoDetailDispose`）。
  Future<void> onVideoDetailDispose(String heroTag);

  /// 清理横向 UP 主页控制器（B站: `Get.delete<HorizontalMemberPageController>`）。
  void disposeMemberPage(String heroTag);

  // ---------- 播放器 / 覆盖层构建 ----------

  /// 构建播放器整机（B站: PLVideoPlayer + HeaderControl + PlDanmaku 装配，
  /// 含 showEpisodes/showViewPoints 槽位）。
  Widget buildPlayer({
    required String heroTag,
    required double width,
    required double height,
    bool isPipMode = false,
    required bool isPortrait,
  });

  /// 播放器上的额外覆盖层（跳过列表 / 互动视频选项，B站 专属）。
  List<Widget> buildPlayerOverlays({
    required String heroTag,
    required bool isFullScreen,
    required double maxHeight,
  });

  /// 键盘控制焦点包装（B站: PlayerFocus；未启用时返回 null）。
  Widget? buildKeyboardFocus({
    required Widget child,
    required String heroTag,
    required VoidCallback onSendDanmaku,
    required bool Function() canPlay,
    required bool Function() onSkipSegment,
  });

  /// 设置弹窗入口（B站: HeaderControlState.showSettingSheet）。
  void showSettingSheet(GlobalKey headerKey);

  // ---------- 简介 / 选集 / 回复 / 相关 ----------

  /// 本地离线简介面板（B站: LocalIntroPanel）。
  Widget buildLocalIntroPanel({required Key key, required String heroTag});

  /// 投稿视频简介面板（B站: UgcIntroPanel，内部接线 showEpisodes/showAiBottomSheet/onShowMemberPage）。
  Widget buildUgcIntroPanel({
    required Key key,
    required String heroTag,
    required bool isPortrait,
    required bool isHorizontal,
  });

  /// 相关视频面板（B站: RelatedVideoPanel）。
  Widget buildRelatedPanel({required Key key, required String heroTag});

  /// 番剧简介页（B站: PgcIntroPage，内部接线 showEpisodes/showIntroDetail）。
  Widget buildPgcIntroPage({
    required Key key,
    required String heroTag,
    required int cid,
    required double maxWidth,
    required bool isLandscape,
  });

  /// 播放列表 tab 面板（B站: PagesPanel/SeasonPanel/EpisodePanel 装配）。
  Widget buildSeasonPanel({required String heroTag});

  /// 评论 tab 面板（B站: VideoReplyPanel）。
  Widget buildReplyPanel({required Key key, required String heroTag, bool isNested = false});

  /// 评论 tab 标签（含数量，B站: VideoReplyController.count）。
  Widget buildReplyTabLabel({required String heroTag});

  /// 评论列表滚回顶部。
  void animateReplyToTop(String heroTag);

  /// 是否显示播放列表 tab（B站: ugc 视频详情含多 P/合集）。
  bool shouldShowSeasonPanel(String heroTag, {required bool isPortrait});

  // ---------- 弹幕 / 简介控制 ----------

  /// 发送弹幕面板（B站: PublishRoute + SendDanmakuPanel）。
  Future<void> showShootDanmakuSheet({
    required String heroTag,
    required String bvid,
    required int cid,
    required int progress,
    String? initialValue,
    void Function(String?)? onSave,
    ({int? mode, int? fontSize, Color? color})? dmConfig,
    ValueChanged<({int mode, int fontSize, Color color})>? onSaveDmConfig,
  });

  /// 简介控制器定时器（B站: CommonIntroController）。
  void startIntroTimer(String heroTag);

  void cancelIntroTimer(String heroTag);

  /// 简介控制器销毁（B站: ugc 额外关闭 videoDetail Rx）。
  void disposeIntro(String heroTag);
  /// 播放完毕自动播放下一个（B站: `introController.nextPlay()`）。
  bool nextPlay(String heroTag);

  /// 稍后再看（B站: `introController.viewLater`）。
  Future<void> viewLater(String heroTag);

  // ---------- 底部弹层 / 页面动作 ----------

  /// 播放列表弹层（B站: MediaListPanel，读 VideoDetailController 状态）。
  void showMediaListPanel(BuildContext context, String heroTag);

  /// 笔记列表弹层（B站: NoteListPage）。
  void showNoteList(BuildContext context, String heroTag);

  /// 下载面板（B站: DownloadPanel + DownloadService）。
  Future<void> showDownloadPanel(BuildContext context, String heroTag);

  /// 听音频（B站: AudioPage.toAudioPage）。
  void openAudioPage(String heroTag);

  /// 片段标记弹层（B站: PostPanel）。
  void onBlock(BuildContext context, String heroTag);

  /// 赞助片段详情（B站: `showSBDetail`）。
  void showSBDetail(String heroTag);

  // ---------- 互动视频 / 高能进度条 / 字幕 ----------

  /// 互动视频选项查询；返回是否包含选项（B站: `/x/stein/edgeinfo_v2`）。
  Future<bool> getSteinEdgeInfo({
    required String heroTag,
    required String bvid,
    required int? graphVersion,
    int? edgeId,
  });

  /// 高能进度条数据（B站: `/pbp/data`）。
  Future<LoadingState<List<double>>> fetchDmTrend({
    required String bvid,
    required int cid,
  });

  /// 未登录时通过弹幕 gRPC 获取字幕（B站: DmGrpc.dmView）。
  Future<List<VideoSubtitleItem>?> fetchDmSubtitles({
    required int aid,
    required int cid,
  });

  // ---------- 来源参数辅助 ----------

  /// 播放列表来源是否"稍后再看"（B站: SourceType.watchLater）。
  bool isWatchLaterSource(Object? sourceType);

  /// 播放列表来源是否"收藏夹"（B站: SourceType.fav）。
  bool isFavSource(Object? sourceType);

  /// 播放列表来源 mediaType（B站: SourceType.mediaType）。
  int sourceMediaType(Object? sourceType);

  /// 是否本地文件来源（B站: SourceType.file）。
  bool isFileSourceSource(Object? sourceType);

  /// 是否播放列表来源（非普通/非文件，B站: SourceType != normal && != file）。
  bool isPlayAllSource(Object? sourceType);

  /// 分P尺寸回退查询（B站: UgcIntroController.videoDetail.pages）。
  ({int width, int height})? partDimension(String heroTag, int cid);

  /// 应用番剧片头/片尾跳过数据（B站: clipInfoList → resetBlock + handleSBData）。
  void applyPgcClipInfo(String heroTag, List<Map<String, dynamic>>? clipInfoList);

  /// 续播分P提示（B站: lastPlayCid 不在当前页时提示跳转）。
  void applyContinuePlayingPart(String heroTag, {
    required int? lastPlayCid,
    required int currentCid,
  });

  /// 是否为互动视频（B站: videoDetail.rights.isSteinGate）。
  bool isSteinGate(String heroTag);

  /// 视频标题（B站: intro 控制器 videoDetail.title，失败返回 null）。
  String? videoTitle(String heroTag);

  /// 从媒体列表项切换分P（B站: UgcIntroController.onChangeEpisode）。
  void onChangeEpisodeFromMedia(String heroTag, CoreMediaListItemModel item);

  /// 本地文件条目信息（B站: BiliDownloadEntryInfo）。
  CoreFileEntryInfo? fileEntryInfo(Object? entry);

  /// 关屏定时器是否等待中（B站: shutdownTimerService.isWaiting）。
  bool get isShutdownTimerWaiting;

  /// 处理关屏定时器（B站: shutdownTimerService.handleWaiting）。
  void handleShutdownTimer();
}

/// 播放地址选择结果。
class CorePlaybackConfig {
  final String videoUrl;
  final String audioUrl;
  final int videoQaCode;
  final int? audioQaCode;
  final VideoDecodeFormatType decodeFormat;
  final int? width;
  final int? height;

  const CorePlaybackConfig({
    required this.videoUrl,
    required this.audioUrl,
    required this.videoQaCode,
    required this.decodeFormat,
    this.audioQaCode,
    this.width,
    this.height,
  });
}

/// 本地文件条目（B站 BiliDownloadEntryInfo 的页域镜像）。
class CoreFileEntryInfo {
  final int preferedVideoQuality;
  final int? width;
  final int? height;
  final int totalTimeMilli;
  final String? typeTag;
  final int mediaType;
  final bool hasDashAudio;

  const CoreFileEntryInfo({
    required this.preferedVideoQuality,
    this.width,
    this.height,
    required this.totalTimeMilli,
    this.typeTag,
    required this.mediaType,
    required this.hasDashAudio,
  });
}

/// 片段跳过引擎（页面级状态，B站 BlockMixin 实现）。
abstract class VideoBlock {
  /// 片段进度条列表。
  RxList<Segment> get segmentProgressList;

  /// 跳过提示列表 key。
  GlobalKey<AnimatedListState> get listKey;

  /// 跳过提示列表数据（SegmentModel 或分P索引）。
  List<Object> get listData;

  /// 是否启用片段跳过逻辑。
  bool get isBlock;

  /// 片段跳过总开关（赞助 + 片头片尾）。
  bool get enableBlock;

  /// 初始化位置监听（播放到片段自动跳过）。
  void initSkip();

  /// 重置片段状态。
  void resetBlock();

  /// 处理片段数据。
  void handleSBData(List<CoreSegmentItemModel> list);

  /// 查询赞助片段（B站: SponsorBlockRepository）。
  Future<void> querySponsorBlock({required String bvid, required int cid});

  /// 添加跳过提示项。
  void onAddItem(Object item);

  /// 移除跳过提示项。
  void onRemoveItem(int index, Object item);

  /// 执行跳过。
  Future<void>? onSkip(Object item, {bool isSeek = true});

  /// 首个待跳片段起点（B站: BlockMixin.getFirstSegment）。
  Duration? getFirstSegment([int pos = 0]);

  /// 构建跳过提示项。
  Widget buildItem(Object item, Animation<double> animation);

  /// 取消片段位置监听。
  void cancelBlockListener();

  /// 赞助片段详情弹层。
  void showSBDetail();

  /// 释放监听与定时器。
  void dispose();
}

/// 从路由参数解析视频类型（兼容适配器 VideoType 与 CoreVideoType 两种入参）。
CoreVideoType coreVideoTypeFromArgs(Object? v) {
  final name = v?.toString() ?? 'VideoType.ugc';
  if (name.contains('ugc')) return CoreVideoType.ugc;
  if (name.contains('pgc')) return CoreVideoType.pgc;
  if (name.contains('pugv')) return CoreVideoType.pugv;
  return CoreVideoType.ugc;
}
