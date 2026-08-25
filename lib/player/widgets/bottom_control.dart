import 'package:skf/common/widgets/progress_bar/audio_video_progress_bar.dart';
import 'package:skf/common/widgets/progress_bar/segment_progress_bar.dart';
import 'package:skf/player/models/player_overlay_source.dart';
import 'package:skf/player/models/player_view_contracts.dart';
import 'package:skf/player/player_controller.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 通用播放器底部控制栏：进度条 + 分段/分段信息/高能进度条覆盖层。
///
/// 数据来自 [PlayerOverlaySource]（适配器注入），高能进度条图表由
/// [PlayerDmChartBuilder] 构建，拖动预览由 [PlayerSeekPreview] 提供。
class BottomControl extends StatelessWidget {
  const BottomControl({
    super.key,
    required this.maxWidth,
    required this.isFullScreen,
    required this.controller,
    required this.buildBottomControl,
    required this.overlaySource,
    this.dmChartBuilder,
    this.seekPreview,
  });

  final double maxWidth;
  final bool isFullScreen;
  final PlayerController controller;
  final ValueGetter<Widget> buildBottomControl;
  final PlayerOverlaySource overlaySource;
  final PlayerDmChartBuilder? dmChartBuilder;
  final PlayerSeekPreview? seekPreview;

  void onDragStart(ThumbDragDetails duration) {
    feedBack();
    controller
      ..position = duration.seconds
      ..isSeeking = true;
  }

  void onDragUpdate(ThumbDragDetails duration) {
    if (!controller.isFileSource && seekPreview?.enabled == true) {
      seekPreview!.updateIndex(duration.seconds);
    }
    controller.position = duration.seconds;
  }

  void onSeek(int milliseconds) {
    controller
      ..onSeekEnd()
      ..seekTo(Duration(milliseconds: milliseconds), isSeek: false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final primary = colorScheme.brightness == Brightness.light
        ? colorScheme.inversePrimary
        : colorScheme.primary;
    final thumbGlowColor = primary.withAlpha(80);
    final bufferedBarColor = primary.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 7),
            child: ListenableBuilder(
              listenable: controller,
              builder: (_, __) {
                final viewPointsVisible = overlaySource.viewPointList.isNotEmpty &&
                    overlaySource.showVP.value;
                return Offstage(
                  offstage: !controller.showControls,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      ListenableBuilder(
                        listenable: controller,
                        builder: (_, __) => ProgressBar(
                          progress: controller.position,
                          buffered: controller.buffered,
                          total: controller.duration,
                          progressBarColor: primary,
                          baseBarColor: const Color(0x33FFFFFF),
                          bufferedBarColor: bufferedBarColor,
                          thumbColor: primary,
                          thumbGlowColor: thumbGlowColor,
                          barHeight: 3.5,
                          thumbRadius: 7,
                          thumbGlowRadius: 25,
                          onDragStart: onDragStart,
                          onDragUpdate: onDragUpdate,
                          onSeek: onSeek,
                        ),
                      ),
                      if (overlaySource.enableBlock &&
                          overlaySource.segmentProgressList.isNotEmpty)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 5.25,
                          child: SegmentProgressBar(
                            segments: overlaySource.segmentProgressList,
                          ),
                        ),
                      if (controller.showViewPoints &&
                          overlaySource.viewPointList.isNotEmpty &&
                          overlaySource.showVP.value)
                        Padding(
                          padding: const .only(bottom: 8.75),
                          child: ViewPointSegmentProgressBar(
                            segments: overlaySource.viewPointList,
                            onSeek: PlatformUtils.isDesktop
                                ? (position) => controller.seekTo(
                                      position,
                                      isSeek: false,
                                    )
                                : null,
                          ),
                        ),
                      if (overlaySource.showDmTrendChart)
                        if (overlaySource.dmTrend case final list?)
                          if (dmChartBuilder case final builder?)
                            builder(
                              primary,
                              list,
                              offset: 4.5,
                              viewPointsVisible: viewPointsVisible,
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
          buildBottomControl(),
        ],
      ),
    );
  }
}
