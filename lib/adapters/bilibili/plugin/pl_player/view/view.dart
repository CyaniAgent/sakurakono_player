import 'dart:math' as math;
import 'package:skf/router/app_navigator.dart';
import 'dart:ui' as ui;

import 'package:skf/adapters/bilibili/common/constants.dart';
import 'package:skf/adapters/bilibili/models/video/play/url.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/episode.dart'
    as ugc;
import 'package:skf/adapters/bilibili/models_new/video/video_detail/ugc_season.dart';
import 'package:skf/adapters/bilibili/pages/common/common_intro_controller.dart';
import 'package:skf/adapters/bilibili/pages/danmaku/danmaku_model.dart';
import 'package:skf/adapters/bilibili/pages/live_room/widgets/bottom_control.dart'
    as live_bottom;
import 'package:skf/pages/video/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/pgc/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/post_panel/popup_menu_text.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/post_panel/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/widgets/header_control.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/controller.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/widgets/mpv_convert_webp.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/widgets/play_pause_btn.dart';
import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/cropped_image.dart';
import 'package:skf/common/widgets/custom_icon.dart';
import 'package:skf/common/widgets/disabled_icon.dart';
import 'package:skf/common/widgets/loading_widget.dart';
import 'package:skf/common/widgets/player_bar.dart';
import 'package:skf/common/widgets/progress_bar/segment_progress_bar.dart';
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/player/models/bottom_control_type.dart';
import 'package:skf/player/models/play_status.dart';
import 'package:skf/player/models/video_fit_type.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:skf/adapters/bilibili/common/video_host.dart';
import 'package:skf/adapters/bilibili/utils/bili_storage_pref.dart';
import 'package:flutter/services.dart';
import 'package:skf/player/models/player_overlay_source.dart';
import 'package:skf/player/models/player_view_contracts.dart';
import 'package:skf/player/player_view.dart';
import 'package:skf/player/widgets/common_btn.dart';
import 'package:skf/player/widgets/video_time.dart';
import 'package:skf/utils/cache_manager.dart';
import 'package:skf/utils/connectivity_utils.dart';
import 'package:skf/utils/duration_utils.dart';
import 'package:skf/utils/image_utils.dart';
import 'package:skf/utils/path_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/utils.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

part 'widgets.dart';

/// B站 播放器 view：通用外壳 [PlayerView] + B站 注入内容（QA 弹窗、选集、
/// 弹幕动作、超分、live 弹幕报告、高能进度条、拖动预览等）。
class PLVideoPlayer extends StatefulWidget {
  const PLVideoPlayer({
    required this.maxWidth,
    required this.maxHeight,
    required this.plPlayerController,
    this.videoDetailController,
    this.introController,
    required this.headerControl,
    this.bottomControl,
    this.danmuWidget,
    this.showEpisodes,
    this.showViewPoints,
    this.fill = Colors.black,
    this.alignment = Alignment.center,
    super.key,
  });

  final double maxWidth;
  final double maxHeight;
  final PlPlayerController plPlayerController;
  final VideoDetailController? videoDetailController;
  final CommonIntroController? introController;
  final Widget headerControl;
  final Widget? bottomControl;
  final Widget? danmuWidget;
  final void Function([
    int?,
    UgcSeason?,
    List<ugc.BaseEpisodeItem>?,
    String?,
    int?,
    int?,
  ])?
  showEpisodes;
  final VoidCallback? showViewPoints;
  final Color fill;
  final Alignment alignment;

  @override
  State<PLVideoPlayer> createState() => _PLVideoPlayerState();
}

class _PLVideoPlayerState extends State<PLVideoPlayer> {
  late final CommonIntroController introController = widget.introController!;
  late final VideoDetailController videoDetailController =
      widget.videoDetailController!;

  int? tmpSubtitlePaddingB;

  _BiliDmTapInteraction? _dmTap;
  _BiliSeekPreview? _seekPreview;
  _VideoOverlaySource? _overlaySource;

  PlPlayerController get plPlayerController => widget.plPlayerController;

  @override
  Widget build(BuildContext context) {
    return PlayerView(
      maxWidth: widget.maxWidth,
      maxHeight: widget.maxHeight,
      plPlayerController: widget.plPlayerController,
      headerControl: widget.headerControl,
      bottomControl: widget.bottomControl,
      danmuWidget: widget.danmuWidget,
      overlaySource:
          _overlaySource ??= _VideoOverlaySource(videoDetailController),
      dmChartBuilder: buildDmChart,
      seekPreview: _seekPreview ??= _BiliSeekPreview(widget.plPlayerController),
      dmTapInteraction: widget.plPlayerController.enableTapDm
          ? _dmTap ??= _BiliDmTapInteraction(
              widget.plPlayerController,
              videoDetailController,
              () => widget.maxWidth,
              () => widget.bottomControl,
            )
          : null,
      buildBottomBar: _buildBottomBar,
      onControlsVisibilityChanged: _onControlVisibilityChanged,
      onPointerExitControls: () =>
          widget.videoDetailController?.showSteinEdgeInfo.value ?? false,
      onScreenshotTap: widget.plPlayerController.takeScreenshot,
      onScreenshotLongPress: screenshotWebp,
      progressType: widget.plPlayerController.progressType,
      fill: widget.fill,
      alignment: widget.alignment,
    );
  }

  /// 控制栏可见性联动：B站 头部时钟/电量 + 字幕内边距。
  void _onControlVisibilityChanged(bool visible) {
    if ((widget.headerControl.key as GlobalKey<TimeBatteryMixin>).currentState
        case final state?) {
      if (state.mounted) {
        state.getBatteryLevelIfNeeded();
        state.provider
          ?..startIfNeeded()
          ..muted = !visible;
        if (visible) {
          state.startClock();
        } else {
          state.stopClock();
        }
      }
    }

    if (widget.videoDetailController case final controller?) {
      if (controller.vttSubtitlesIndex.value != 0) {
        if (visible) {
          const int minPadding = 70;
          if (plPlayerController.subtitlePaddingB < minPadding) {
            tmpSubtitlePaddingB = plPlayerController.subtitlePaddingB;
            plPlayerController
              ..subtitlePaddingB = minPadding
              ..subtitleConfig = plPlayerController.getSubConfig;
          }
        } else {
          if (tmpSubtitlePaddingB != null) {
            plPlayerController
              ..subtitlePaddingB = tmpSubtitlePaddingB!
              ..subtitleConfig = plPlayerController.getSubConfig;
            tmpSubtitlePaddingB = null;
          }
        }
      }
    }
  }

  // 动态构建底部控制条
  Widget _buildBottomBar() {
    final videoDetail = introController.videoDetail;
    final isSeason = videoDetail.ugcSeason != null;
    final isPart = videoDetail.pages != null && videoDetail.pages!.length > 1;
    final isPgc = !videoDetailController.isUgc;
    final isPlayAll = videoDetailController.isPlayAll;
    final anySeason = isSeason || isPart || isPgc || isPlayAll;
    final isFullScreen = plPlayerController.isFullScreen;
    final double widgetWidth =
        widget.maxWidth > widget.maxHeight && isFullScreen ? 42 : 35;

    Widget progressWidget(
      BottomControlType bottomControl,
    ) => switch (bottomControl) {
      /// 播放暂停
      BottomControlType.playOrPause => PlayOrPauseButton(
        plPlayerController: plPlayerController,
      ),

      /// 上一集
      BottomControlType.pre => ComBtn(
        width: widgetWidth,
        height: 30,
        tooltip: '上一集',
        icon: const Icon(
          Icons.skip_previous,
          size: 22,
          color: Colors.white,
        ),
        onTap: () {
          if (!introController.prevPlay()) {
            SmartDialog.showToast('已经是第一集了');
          }
        },
      ),

      /// 下一集
      BottomControlType.next => ComBtn(
        width: widgetWidth,
        height: 30,
        tooltip: '下一集',
        icon: const Icon(
          Icons.skip_next,
          size: 22,
          color: Colors.white,
        ),
        onTap: () {
          if (!introController.nextPlay()) {
            SmartDialog.showToast('已经是最后一集了');
          }
        },
      ),

      /// 时间进度
      BottomControlType.time => Obx(
        () => VideoTime(
          position: DurationUtils.formatDuration(
            plPlayerController.position,
          ),
          duration: DurationUtils.formatDuration(
            plPlayerController.duration,
          ),
        ),
      ),

      /// 高能进度条
      BottomControlType.dmChart => Obx(
        () {
          final list = videoDetailController.dmTrend.value?.dataOrNull;
          if (list != null && list.isNotEmpty) {
            final show = videoDetailController.showDmTrendChart.value;
            return ComBtn(
              width: widgetWidth,
              height: 30,
              tooltip: '高能进度条',
              icon: DisabledIcon(
                disable: !show,
                child: const Icon(
                  Icons.show_chart,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              onTap: () =>
                  videoDetailController.showDmTrendChart.value = !show,
            );
          }
          return const SizedBox.shrink();
        },
      ),

      /// 超分辨率
      BottomControlType.superResolution => Obx(
        () {
          final type = plPlayerController.superResolutionType.value;
          return PopupMenuButton<SuperResolutionType>(
            tooltip: '超分辨率',
            requestFocus: false,
            initialValue: type,
            color: Colors.black.withValues(alpha: 0.8),
            itemBuilder: (context) {
              return SuperResolutionType.values
                  .map(
                    (type) => PopupMenuItem<SuperResolutionType>(
                      height: 35,
                      padding: const EdgeInsets.only(left: 30),
                      value: type,
                      onTap: () => plPlayerController.setShader(type),
                      child: Text(
                        type.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                type.label,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          );
        },
      ),

      /// 分段信息
      BottomControlType.viewPoints => Obx(
        () {
          if (videoDetailController.viewPointList.isNotEmpty) {
            return ComBtn(
              width: widgetWidth,
              height: 30,
              tooltip: '分段信息',
              icon: DisabledIcon(
                iconSize: 22,
                color: Colors.white,
                disable: !videoDetailController.showVP.value,
                child: const Icon(
                  CustomIcons.view_headline_rotate_90,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              onTap: widget.showViewPoints,
              onLongPress: () {
                Feedback.forLongPress(context);
                videoDetailController.showVP.toggle();
              },
              onSecondaryTap: PlatformUtils.isMobile
                  ? null
                  : () => videoDetailController.showVP.toggle(),
            );
          }
          return const SizedBox.shrink();
        },
      ),

      /// 选集
      BottomControlType.episode => ComBtn(
        width: widgetWidth,
        height: 30,
        tooltip: '选集',
        icon: const Icon(
          Icons.list,
          size: 22,
          color: Colors.white,
        ),
        onTap: () {
          if (videoDetailController.isFileSource) {
            // NOTE: file sources have no part list — the episode button is
            // intentionally a no-op for local files.
            return;
          }
          // part -> playAll -> season(pgc)
          if (isPlayAll && !isPart) {
            widget.showEpisodes?.call();
            return;
          }
          int? index;
          int currentCid = plPlayerController.cid!;
          String bvid = plPlayerController.bvid;
          List<ugc.BaseEpisodeItem> episodes = [];
          if (isSeason) {
            final sections = videoDetail.ugcSeason!.sections!;
            for (int i = 0; i < sections.length; i++) {
              final episodesList = sections[i].episodes!;
              for (final item in episodesList) {
                if (item.cid == currentCid) {
                  index = i;
                  episodes = episodesList;
                  break;
                }
              }
            }
          } else if (isPart) {
            episodes = videoDetail.pages!;
          } else if (isPgc) {
            episodes =
                (introController as PgcIntroController).pgcItem.episodes!;
          }
          widget.showEpisodes?.call(
            index,
            isSeason ? videoDetail.ugcSeason! : null,
            isSeason ? null : episodes,
            bvid,
            IdUtils.bv2av(bvid),
            isSeason && isPart
                ? videoDetailController.seasonCid ?? currentCid
                : currentCid,
          );
        },
      ),

      /// 画面比例
      BottomControlType.fit => Obx(
        () {
          final fit = plPlayerController.videoFit;
          return PopupMenuButton<VideoFitType>(
            tooltip: '画面比例',
            requestFocus: false,
            initialValue: fit,
            color: Colors.black.withValues(alpha: 0.8),
            itemBuilder: (context) {
              return VideoFitType.values
                  .map(
                    (boxFit) => PopupMenuItem<VideoFitType>(
                      height: 35,
                      padding: const EdgeInsets.only(left: 30),
                      value: boxFit,
                      onTap: () => plPlayerController.toggleVideoFit(boxFit),
                      child: Text(
                        boxFit.desc,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                fit.desc,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          );
        },
      ),

      BottomControlType.aiTranslate => Obx(
        () {
          final list = videoDetailController.languages.value;
          if (list != null && list.isNotEmpty) {
            return PopupMenuButton<String>(
              tooltip: '翻译',
              requestFocus: false,
              initialValue: videoDetailController.currLang.value,
              color: Colors.black.withValues(alpha: 0.8),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    height: 35,
                    value: '',
                    onTap: () => videoDetailController.setLanguage(''),
                    child: const Text(
                      "关闭翻译",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...list.map((e) {
                    return PopupMenuItem<String>(
                      height: 35,
                      value: e.lang,
                      onTap: () => videoDetailController.setLanguage(e.lang!),
                      child: Text(
                        e.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                ];
              },
              child: SizedBox(
                width: widgetWidth,
                height: 30,
                child: const Icon(
                  Icons.translate,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),

      /// 字幕
      BottomControlType.subtitle => Obx(
        () {
          if (videoDetailController.subtitles.isNotEmpty) {
            final val = videoDetailController.vttSubtitlesIndex.value;
            return PopupMenuButton<int>(
              tooltip: '字幕',
              requestFocus: false,
              initialValue: val,
              color: Colors.black.withValues(alpha: 0.8),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    height: 35,
                    onTap: () => videoDetailController.setSubtitle(0),
                    child: const Text(
                      "关闭字幕",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...videoDetailController.subtitles.mapIndexed((i, e) {
                    return PopupMenuItem<int>(
                      value: i + 1,
                      height: 35,
                      onTap: () => videoDetailController.setSubtitle(i + 1),
                      child: Text(
                        e.lanDoc ?? e.lan,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const .new(color: Colors.white, fontSize: 13),
                      ),
                    );
                  }),
                ];
              },
              child: SizedBox(
                width: widgetWidth,
                height: 30,
                child: val == 0
                    ? const Icon(
                        Icons.closed_caption_off_outlined,
                        size: 22,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.closed_caption_off_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),

      /// 播放速度
      BottomControlType.speed => Obx(
        () => PopupMenuButton<double>(
          tooltip: '倍速',
          requestFocus: false,
          initialValue: plPlayerController.playbackSpeed,
          color: Colors.black.withValues(alpha: 0.8),
          itemBuilder: (context) {
            return plPlayerController.speedList
                .map(
                  (double speed) => PopupMenuItem<double>(
                    height: 35,
                    padding: const EdgeInsets.only(left: 30),
                    value: speed,
                    onTap: () => plPlayerController.setPlaybackSpeed(speed),
                    child: Text(
                      "${speed}X",
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      semanticsLabel: "$speed倍速",
                    ),
                  ),
                )
                .toList();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "${plPlayerController.playbackSpeed}X",
              style: const TextStyle(color: Colors.white, fontSize: 13),
              semanticsLabel: "${plPlayerController.playbackSpeed}倍速",
            ),
          ),
        ),
      ),

      BottomControlType.qa => Obx(
        () {
          final VideoQuality? currentVideoQa =
              videoDetailController.currentVideoQa.value;
          if (currentVideoQa == null) {
            return const SizedBox.shrink();
          }
          final PlayUrlModel videoInfo = playUrlModelFromCore(videoDetailController.data);
          if (videoInfo.dash == null) {
            return const SizedBox.shrink();
          }
          final videoFormat = videoInfo.supportFormats!;
          final totalQaSam = videoFormat.length;
          final usefulQaSam = videoInfo.dash!.video!
              .map((i) => i.id)
              .toSet()
              .length;
          return PopupMenuButton<int>(
            tooltip: '画质',
            requestFocus: false,
            initialValue: currentVideoQa.code,
            color: Colors.black.withValues(alpha: 0.8),
            itemBuilder: (context) {
              return List.generate(
                totalQaSam,
                (index) {
                  final item = videoFormat[index];
                  final enabled = index >= totalQaSam - usefulQaSam;
                  return PopupMenuItem<int>(
                    enabled: enabled,
                    height: 35,
                    padding: const EdgeInsets.only(left: 15, right: 10),
                    value: item.quality,
                    onTap: () async {
                      if (currentVideoQa.code == item.quality) {
                        return;
                      }
                      final int quality = item.quality!;
                      final newQa = VideoQuality.fromCode(quality);
                      videoDetailController
                        ..plPlayerController.cacheVideoQa = newQa.code
                        ..currentVideoQa.value = newQa
                        ..updatePlayer();

                      SmartDialog.showToast("画质已变为：${newQa.desc}");

                      // update
                      if (!plPlayerController.tempPlayerConf) {
                        GStorage.setting.put(
                          await ConnectivityUtils.isWiFi
                              ? SettingBoxKey.defaultVideoQa
                              : SettingBoxKey.defaultVideoQaCellular,
                          quality,
                        );
                      }
                    },
                    child: Text(
                      item.newDesc ?? '',
                      style: enabled
                          ? const TextStyle(color: Colors.white, fontSize: 13)
                          : const TextStyle(
                              color: Color(0x62FFFFFF),
                              fontSize: 13,
                            ),
                    ),
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                currentVideoQa.shortDesc,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          );
        },
      ),

      /// 全屏
      BottomControlType.fullscreen => ComBtn(
        width: widgetWidth,
        height: 30,
        tooltip: isFullScreen ? '退出全屏' : '全屏',
        icon: isFullScreen
            ? const Icon(Icons.fullscreen_exit, size: 24, color: Colors.white)
            : const Icon(Icons.fullscreen, size: 24, color: Colors.white),
        onTap: () =>
            plPlayerController.triggerFullScreen(status: !isFullScreen),
        onSecondaryTap: () => plPlayerController.triggerFullScreen(
          status: !isFullScreen,
          inAppFullScreen: true,
        ),
      ),
    };

    final isNotFileSource = !plPlayerController.isFileSource;

    List<BottomControlType> userSpecifyItemLeft = [
      .playOrPause,
      .time,
      if (!isNotFileSource || anySeason) ...[.pre, .next],
    ];

    final flag =
        isFullScreen || plPlayerController.isDesktopPip || widget.maxWidth >= 500;
    final List<BottomControlType> userSpecifyItemRight = [
      if (isNotFileSource && plPlayerController.showDmChart) .dmChart,
      if (plPlayerController.isAnim) .superResolution,
      if (isNotFileSource && plPlayerController.showViewPoints) .viewPoints,
      if (isNotFileSource && anySeason) .episode,
      if (flag) .fit,
      if (isNotFileSource) .aiTranslate,
      .subtitle,
      .speed,
      if (isNotFileSource && flag) .qa,
      if (!plPlayerController.isDesktopPip) .fullscreen,
    ];
    return PlayerBar(
      children: [
        Row(
          mainAxisSize: .min,
          children: userSpecifyItemLeft.map(progressWidget).toList(),
        ),
        Row(
          mainAxisSize: .min,
          children: userSpecifyItemRight.map(progressWidget).toList(),
        ),
      ],
    );
  }

  Future<void> screenshotWebp() async {
    final PlayUrlModel videoInfo = playUrlModelFromCore(videoDetailController.data);
    final ids = videoInfo.dash!.video!.map((i) => i.id!).toSet();
    final video = _findVideoByQa(videoInfo, ids.min);

    VideoQuality qa = video.quality;
    String? url = video.baseUrl;
    if (url == null) return;

    final ctr = plPlayerController;
    final theme = Theme.of(context);
    final currentPos = ctr.positionInMilliseconds / 1000.0;
    final duration = ctr.durationInMilliseconds / 1000.0;
    final model = CorePostSegmentModel(
      segment: CoreDoublePair(first: currentPos, second: currentPos),
      category: CoreSegmentType.sponsor,
      actionType: CoreActionType.skip,
    );
    final isPlay = ctr.playerStatus.isPlaying;
    if (isPlay) ctr.pause();

    WebpPreset preset = WebpPreset.def;

    final success =
        await showDialog<bool>(
          context: AppNavigator.context!,
          builder: (context) => AlertDialog(
            title: const Text('动态截图'),
            content: Column(
              spacing: 12,
              mainAxisSize: MainAxisSize.min,
              children: [
                PostPanel.segmentWidget(
                  theme,
                  item: model,
                  currentPos: () => currentPos,
                  videoDuration: duration,
                ),
                PopupMenuText(
                  title: '选择画质',
                  value: () => qa.code,
                  onSelected: (value) {
                    final video = _findVideoByQa(videoInfo, value);
                    url = video.baseUrl;
                    qa = video.quality;
                    return false;
                  },
                  itemBuilder: (context) => videoInfo.supportFormats!
                      .map(
                        (i) => PopupMenuItem(
                          enabled: ids.contains(i.quality),
                          value: i.quality,
                          child: Text(i.newDesc ?? ''),
                        ),
                      )
                      .toList(),
                  getSelectTitle: (_) => qa.shortDesc,
                ),
                PopupMenuText(
                  title: 'webp预设',
                  value: () => preset,
                  onSelected: (value) {
                    preset = value;
                    return false;
                  },
                  itemBuilder: (context) => WebpPreset.values
                      .map((i) => PopupMenuItem(value: i, child: Text(i.name)))
                      .toList(),
                  getSelectTitle: (i) => '${i.name}(${i.desc})',
                ),
                Text(
                  '*转码使用CPU，速度可能慢于播放，请不要选择过长的时间段或过高画质',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (model.segment.first < model.segment.second) {
                    AppNavigator.back(result: true);
                  }
                },
                child: const Text('确定'),
              ),
            ],
          ),
        ) ??
        false;
    if (!success) return;

    double progress = 0.0;
    final name =
        '${ctr.cid}-${model.segment.first.toStringAsFixed(3)}_${model.segment.second.toStringAsFixed(3)}.webp';
    final file = '$tmpDirPath/$name';

    final mpv = MpvConvertWebp(
      url!,
      file,
      model.segment.first,
      model.segment.second,
      progress: progress,
      preset: preset,
    );
    final future = mpv.convert().whenComplete(
      () => SmartDialog.dismiss(status: SmartStatus.loading),
    );

    SmartDialog.showLoading(
      backType: SmartBackType.normal,
      builder: (_) => LoadingWidget(progress: progress, msg: '正在保存，可能需要较长时间'),
      onDismiss: () async {
        if (progress < 1.0) {
          mpv.dispose();
        }
        if (await future) {
          await ImageUtils.saveFileImg(
            filePath: file,
            fileName: name,
            needToast: true,
          );
        } else {
          SmartDialog.showToast('转码出现错误或已取消');
        }
        if (isPlay) ctr.play();
      },
    );
  }
}

/// B站 弹幕点按交互注入：[PlayerDmTapInteraction] 实现。
class _BiliDmTapInteraction implements PlayerDmTapInteraction {
  _BiliDmTapInteraction(
    this._plPlayerController,
    this._videoDetailController,
    this._getMaxWidth,
    this._getBottomControl,
  );

  final PlPlayerController _plPlayerController;
  final VideoDetailController _videoDetailController;
  final double Function() _getMaxWidth;
  final Widget? Function() _getBottomControl;

  DanmakuItem<DanmakuExtra>? _suspendedDm;
  late double _dy = 0;
  late final Rxn<Offset> _dmOffset = Rxn<Offset>();

  @override
  bool get enabled => true;

  @override
  bool get visible => _plPlayerController.enableShowDanmaku.value;

  @override
  Stream<bool> get visibilityChanges =>
      _plPlayerController.enableShowDanmaku.stream;

  @override
  void handleTapDown(TapDownDetails details) {
    final ctr = _plPlayerController.danmakuController;
    if (ctr != null) {
      final pos = details.localPosition;
      final res = ctr.findSingleDanmaku(pos);
      if (res != null) {
        final (dy, item) = res;
        if (item != _suspendedDm) {
          _suspendedDm?.suspend = false;
          if (item.content.extra == null) {
            _dmOffset.value = null;
            return;
          }
          _suspendedDm = item..suspend = true;
          _dy = dy;
        }
      } else {
        _suspendedDm?.suspend = false;
        _dmOffset.value = null;
      }
    }
  }

  @override
  bool handleTapUp(TapUpDetails details) {
    if (_suspendedDm == null) return false;
    if (_suspendedDm!.suspend) {
      _dmOffset.value = details.localPosition;
    } else {
      _suspendedDm = null;
    }
    return true;
  }

  @override
  void cancel() {
    if (_suspendedDm != null) {
      _suspendedDm?.suspend = false;
      _suspendedDm = null;
      _dmOffset.value = null;
    }
  }

  @override
  Widget buildOverlay(BuildContext context) {
    return Obx(() {
      if (!_plPlayerController.enableShowDanmaku.value) {
        return const SizedBox.shrink();
      }
      final dmOffset = _dmOffset.value;
      if (dmOffset != null && _suspendedDm != null) {
        return _buildDmAction(context, _suspendedDm!, dmOffset);
      }
      return const SizedBox.shrink();
    });
  }

  static const _overlaySpacing = 5.0;
  static const _actionItemWidth = 40.0;
  static const _actionItemHeight = 35.0 - _triangleHeight;

  static final _timeRegExp = RegExp(r'(?:\d+[:：])?\d+[:：][0-5]?\d(?!\d)');

  int? _getValidOffset(String data) {
    if (_timeRegExp.firstMatch(data) case final timeStr?) {
      final offset = DurationUtils.parseDuration(timeStr.group(0));
      if (0 < offset &&
          offset * 1000 < _videoDetailController.data.timeLength!) {
        return offset;
      }
    }
    return null;
  }

  Widget _dmActionItem(
    Widget child, {
    required Future<void>? Function() onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await onTap();
        cancel();
      },
      child: SizedBox(
        width: _actionItemWidth,
        height: _actionItemHeight,
        child: Center(
          child: child,
        ),
      ),
    );
  }

  Widget _buildDmAction(
    BuildContext context,
    DanmakuItem<DanmakuExtra> item,
    Offset offset,
  ) {
    final dx = offset.dx;
    final maxWidth = _getMaxWidth();
    // fullscreen
    if (dx > maxWidth) {
      cancel();
      return const SizedBox.shrink();
    }

    final seekOffset = _getValidOffset(item.content.text);

    final overlayWidth = _actionItemWidth * (seekOffset == null ? 3 : 4);

    final top = _dy + item.height + _triangleHeight + 2;

    final realLeft = dx + overlayWidth / 2;

    final left = realLeft.clamp(
      _overlaySpacing + overlayWidth,
      maxWidth - _overlaySpacing,
    );

    final right = maxWidth - left;
    final triangleOffset = realLeft - left;

    if (right > (maxWidth - item.xPosition)) {
      cancel();
      return const SizedBox.shrink();
    }

    final extra = item.content.extra;

    return Positioned(
      right: right,
      top: top,
      child: _DanmakuTip(
        offset: triangleOffset,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: switch (extra) {
            null => throw UnimplementedError(),
            VideoDanmaku() => [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _dmActionItem(
                    extra.isLike
                        ? const Icon(
                            size: 20,
                            CustomIcons.player_dm_tip_like_solid,
                            color: Colors.white,
                          )
                        : const Icon(
                            size: 20,
                            CustomIcons.player_dm_tip_like,
                            color: Colors.white,
                          ),
                    onTap: () => HeaderControl.likeDanmaku(
                      extra,
                      _plPlayerController.cid!,
                    ),
                  ),
                  if (extra.like > 0)
                    Positioned(
                      left: _actionItemWidth - 10.5,
                      top: 0,
                      child: Text(
                        extra.like.toString(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              _dmActionItem(
                const Icon(
                  size: 19,
                  CustomIcons.player_dm_tip_copy,
                  color: Colors.white,
                ),
                onTap: () => Utils.copyText(item.content.text),
              ),
              if (item.content.selfSend)
                _dmActionItem(
                  const Icon(
                    size: 20,
                    CustomIcons.player_dm_tip_recall,
                    color: Colors.white,
                  ),
                  onTap: () => HeaderControl.deleteDanmaku(
                    extra.id,
                    _plPlayerController.cid!,
                  ),
                )
              else
                _dmActionItem(
                  const Icon(
                    size: 20,
                    CustomIcons.player_dm_tip_back,
                    color: Colors.white,
                  ),
                  onTap: () => HeaderControl.reportDanmaku(
                    context,
                    extra: extra,
                    ctr: _plPlayerController,
                  ),
                ),
              if (seekOffset != null)
                _dmActionItem(
                  const Icon(
                    size: 18,
                    Icons.gps_fixed_outlined,
                    color: Colors.white,
                  ),
                  onTap: () => _plPlayerController.seekTo(
                    Duration(seconds: seekOffset),
                    isSeek: false,
                  ),
                ),
            ],
            LiveDanmaku() => [
              _dmActionItem(
                const Icon(
                  size: 20,
                  MdiIcons.accountOutline,
                  color: Colors.white,
                ),
                onTap: () => AppNavigator.toNamed('/member?mid=${extra.mid}'),
              ),
              _dmActionItem(
                const Icon(
                  size: 19,
                  CustomIcons.player_dm_tip_copy,
                  color: Colors.white,
                ),
                onTap: () => Utils.copyText(item.content.text),
              ),
              _dmActionItem(
                const Icon(
                  size: 20,
                  CustomIcons.player_dm_tip_back,
                  color: Colors.white,
                ),
                onTap: () => HeaderControl.reportLiveDanmaku(
                  context,
                  roomId: (_getBottomControl() as live_bottom.BottomControl)
                      .liveRoomCtr
                      .roomId,
                  msg: item.content.text,
                  extra: extra,
                ),
              ),
            ],
          },
        ),
      ),
    );
  }
}

/// B站 拖动预览注入：[PlayerSeekPreview] 实现。
class _BiliSeekPreview implements PlayerSeekPreview {
  _BiliSeekPreview(this._plPlayerController);

  final PlPlayerController _plPlayerController;

  @override
  bool get enabled => _plPlayerController.showSeekPreview;

  @override
  void updateIndex(int seconds) => _plPlayerController.updatePreviewIndex(
    seconds,
  );

  @override
  void hide() => _plPlayerController.showPreview.value = false;

  @override
  Widget build(
    BuildContext context, {
    required double maxWidth,
    required double maxHeight,
    required ValueGetter<bool> isMounted,
  }) {
    return buildSeekPreviewWidget(
      _plPlayerController,
      maxWidth,
      maxHeight,
      isMounted,
    );
  }
}

/// B站 进度条覆盖层数据源：[PlayerOverlaySource] 适配实现。
class _VideoOverlaySource implements PlayerOverlaySource {
  _VideoOverlaySource(this._controller);

  final VideoDetailController _controller;

  @override
  bool get enableBlock => (_controller.plPlayerController as PlPlayerController).enableBlock;

  @override
  List<Segment> get segmentProgressList => _controller.segmentProgressList;

  @override
  List<ViewPointSegment> get viewPointList => _controller.viewPointList;

  @override
  RxBool get showVP => _controller.showVP;

  @override
  bool get showDmTrendChart => _controller.showDmTrendChart.value;

  @override
  List<double>? get dmTrend => _controller.dmTrend.value?.dataOrNull;
}

/// 按画质码选择视频流（优先预设解码格式；原 VideoDetailController.findVideoByQa）。
VideoItem _findVideoByQa(PlayUrlModel data, int qa) {
  final videoList = data.dash!.video!.where((i) => i.id == qa).toList();
  if (videoList.isEmpty) {
    return data.dash!.video!.first;
  }
  final preferCodecs = BiliPref.preferCodecs;
  VideoItem? bestVideo;
  int bestIndex = preferCodecs.length;
  for (final video in videoList) {
    final c = video.codecs!;
    for (int i = 0; i < bestIndex; i++) {
      if (preferCodecs[i].codes.any(c.startsWith)) {
        bestIndex = i;
        bestVideo = video;
        break;
      }
    }
  }
  return bestVideo ?? videoList.first;
}