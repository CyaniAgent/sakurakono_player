/// Transitional Riverpod-based version of the video detail page.
///
/// This file mirrors the essential layout and player structure from
/// [VideoDetailPageV] but uses the Riverpod [videoDetailProvider]
/// instead of the GetX controller. The existing GetX page remains
/// the production page — this is additive only.
library;

import 'dart:io' show Platform;
import 'dart:math';

import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/sliver/video_header.dart';
import 'package:skf/common/widgets/svg/play_icon.dart';
import 'package:skf/pages/video/video_controller_riverpod.dart';
import 'package:skf/pages/video/video_host.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/max_screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Transitional Riverpod-based video detail page.
///
/// Uses [videoDetailProvider] for state management instead of GetX.
/// Focused on the essential layout: player + title/controls.
class VideoDetailPageRiverpod extends ConsumerStatefulWidget {
  const VideoDetailPageRiverpod({super.key});

  @override
  ConsumerState<VideoDetailPageRiverpod> createState() =>
      _VideoDetailPageRiverpodState();
}

class _VideoDetailPageRiverpodState
    extends ConsumerState<VideoDetailPageRiverpod>
    with WidgetsBindingObserver {
  late final VideoHost host;
  late final String heroTag;

  // -- Screen metrics --
  late ThemeData themeData;
  late bool isPortrait;
  late double maxWidth;
  late double maxHeight;
  bool isWindowMode = false;
  late EdgeInsets padding;

  @override
  void initState() {
    super.initState();
    host = VideoHost.of();
    heroTag = AppNavigator.arguments['heroTag'] as String? ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    padding = MediaQuery.viewPaddingOf(context);

    final size = MediaQuery.sizeOf(context);
    maxWidth = size.width;
    maxHeight = size.height;
    isWindowMode = MaxScreenSize.isWindowMode(
      width: maxWidth,
      height: maxHeight,
    );


    isPortrait = maxHeight >= maxWidth;

    themeData = Theme.of(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isResume = state == .resumed;
    if (isResume) {
      host.startIntroTimer(heroTag);
    } else if (state == .paused) {
      host.cancelIntroTimer(heroTag);
    }
  }

  @override
  void dispose() {
    host.disposeMemberPage(heroTag);
    super.dispose();
  }

  // -- Convenience accessors from Riverpod state --

  double _computeVideoHeight(VideoDetailState vs) {
    if (vs.isVertical) {
      return max(maxHeight * 0.65, maxHeight / Style.aspectRatio16x9);
    }
    return maxHeight / Style.aspectRatio16x9;
  }

  // -- Build --

  @override
  Widget build(BuildContext context) {
    final vs = ref.watch(videoDetailProvider(heroTag.isNotEmpty ? {'heroTag': heroTag} : {}));

    final videoHeight = _computeVideoHeight(vs);
    final height = videoHeight;

    return Theme(
      data: themeData,
      child: _PortraitLayout(
        host: host,
        heroTag: heroTag,
        vs: vs,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        videoHeight: height,
        padding: padding,
        isPortrait: isPortrait,
        themeData: themeData,
        onPlay: _handlePlay,
      ),
    );
  }

  Future<void>? _handlePlay() {
    // Placeholder — full playback init will be wired when the adapter
    // bridge is ported to Riverpod providers.
    return null;
  }
}

// ---------------------------------------------------------------------------
// Portrait layout — the primary layout for phone-width screens.
// ---------------------------------------------------------------------------

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({
    required this.host,
    required this.heroTag,
    required this.vs,
    required this.maxWidth,
    required this.maxHeight,
    required this.videoHeight,
    required this.padding,
    required this.isPortrait,
    required this.themeData,
    required this.onPlay,
  });

  final VideoHost host;
  final String heroTag;
  final VideoDetailState vs;
  final double maxWidth;
  final double maxHeight;
  final double videoHeight;
  final EdgeInsets padding;
  final bool isPortrait;
  final ThemeData themeData;
  final Future<void>? Function() onPlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          toolbarHeight: 0,
          backgroundColor: vs.scrollRatio > 0
              ? Color.lerp(
                  Colors.black,
                  themeData.colorScheme.surface,
                  vs.scrollRatio,
                )
              : Colors.black,
          systemOverlayStyle: Platform.isAndroid
              ? SystemUiOverlayStyle(
                  statusBarIconBrightness: vs.scrollRatio >= 0.5
                      ? (themeData.brightness == Brightness.dark
                          ? Brightness.light
                          : Brightness.dark)
                      : .light,
                  systemNavigationBarIconBrightness:
                      themeData.brightness == Brightness.dark
                          ? Brightness.light
                          : Brightness.dark,
                )
              : null,
        ),
      ),
      body: Column(
        children: [
          // -- Video header / player --
          VideoHeader(
            minExtent: kToolbarHeight,
            maxExtent: videoHeight,
            minVideoHeight: videoHeight,
            onScrollRatioChanged: (_) {},
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: maxWidth,
                  height: videoHeight,
                  child: _VideoPlayerArea(
                    host: host,
                    heroTag: heroTag,
                    vs: vs,
                    width: maxWidth,
                    height: videoHeight,
                    onPlay: onPlay,
                  ),
                ),
                _buildHeaderOverlay(),
              ],
            ),
          ),

          // -- Title + controls area --
          Expanded(
            child: _TitleSection(
              vs: vs,
              themeData: themeData,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderOverlay() {
    if (vs.scrollRatio == 0) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      bottom: -2,
      child: Opacity(
        opacity: vs.scrollRatio,
        child: Container(
          color: themeData.colorScheme.surface,
          alignment: .topCenter,
          child: SizedBox(
            height: kToolbarHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: .centerLeft,
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      SizedBox(
                        width: 42,
                        height: 34,
                        child: IconButton(
                          tooltip: '返回',
                          icon: Icon(
                            FontAwesomeIcons.arrowLeft,
                            size: 15,
                            color: themeData.colorScheme.onSurface,
                          ),
                          onPressed: AppNavigator.back,
                        ),
                      ),
                      SizedBox(
                        width: 42,
                        height: 34,
                        child: IconButton(
                          tooltip: '返回主页',
                          icon: Icon(
                            FontAwesomeIcons.house,
                            size: 15,
                            color: themeData.colorScheme.onSurface,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Row(
                    spacing: 2,
                    mainAxisSize: .min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: themeData.colorScheme.primary,
                      ),
                      Text(
                        '继续播放',
                        style: TextStyle(
                          color: themeData.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Video player area — black background + cover overlay.
// ---------------------------------------------------------------------------

class _VideoPlayerArea extends StatelessWidget {
  const _VideoPlayerArea({
    required this.host,
    required this.heroTag,
    required this.vs,
    required this.width,
    required this.height,
    required this.onPlay,
  });

  final VideoHost host;
  final String heroTag;
  final VideoDetailState vs;
  final double width;
  final double height;
  final Future<void>? Function() onPlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(
          child: ColoredBox(color: Colors.black),
        ),

        // Cover image when not playing
        if (!vs.autoPlay)
          Positioned.fill(
            bottom: -1,
            child: GestureDetector(
              onTap: onPlay,
              behavior: .opaque,
              child: NetworkImgLayer(
                type: .emote,
                quality: 60,
                src: vs.cover,
                width: width,
                height: height,
                cacheWidth: true,
                getPlaceHolder: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),

        // Play button overlay (manual play mode)
        if (!vs.autoPlay)
          Positioned(
            right: 12,
            bottom: 10,
            child: IconButton(
              tooltip: '播放',
              onPressed: onPlay,
              icon: const PlayIcon(),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Title section — minimal info below the player.
// ---------------------------------------------------------------------------

class _TitleSection extends StatelessWidget {
  const _TitleSection({
    required this.vs,
    required this.themeData,
  });

  final VideoDetailState vs;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeData.dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video label / quality tag
          if (vs.videoLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  vs.videoLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeData.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),

          // View point / chapter info
          if (vs.viewPointList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${vs.viewPointList.length} 个看点',
                style: TextStyle(
                  fontSize: 13,
                  color: themeData.colorScheme.secondary,
                ),
              ),
            ),

          // Season index (for multi-part videos)
          if (vs.seasonIndex > 0)
            Text(
              '第 ${vs.seasonIndex + 1} 集',
              style: TextStyle(
                fontSize: 13,
                color: themeData.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
