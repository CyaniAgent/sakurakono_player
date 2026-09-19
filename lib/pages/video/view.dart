import 'dart:io' show Platform;
import 'package:skf/router/app_navigator.dart';
import 'dart:math';

import 'package:skf/common/assets.dart';
import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/custom_icon.dart';
import 'package:skf/common/widgets/flutter/pop_scope.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/keep_alive_wrapper.dart';
import 'package:skf/common/widgets/route_aware_mixin.dart';
import 'package:skf/common/widgets/scroll_physics.dart' show tabBarView;
import 'package:skf/common/widgets/sliver/video_header.dart';
import 'package:skf/common/widgets/svg/play_icon.dart';
import 'package:skf/pages/video/controller.dart';
import 'package:skf/pages/video/video_host.dart';
import 'package:skf/player/models/fullscreen_mode.dart';
import 'package:skf/player/utils/fullscreen.dart';
import 'package:skf/player/models/play_repeat.dart';
import 'package:skf/player/models/play_status.dart';
import 'package:skf/player/player_controller.dart';
import 'package:skf/utils/android/bindings.g.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/utils/image_utils.dart';
import 'package:skf/utils/max_screen_size.dart';
import 'package:skf/utils/mobile_observer.dart';
import 'package:skf/utils/theme_utils.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/foundation.dart' show kDebugMode, clampDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';

/// 视频播放详情页（通用层，零适配器依赖）。
///
/// 播放器/弹幕/回复/简介/选集等 B站 专属组件通过 [VideoHost] 注入装配，
/// 本页只保留布局、滚动、生命周期与播放状态机等通用逻辑。
class VideoDetailPageV extends StatefulWidget {
  const VideoDetailPageV({super.key});

  @override
  State<VideoDetailPageV> createState() => _VideoDetailPageVState();
}

class _VideoDetailPageVState extends State<VideoDetailPageV>
    with RouteAware, RouteAwareMixin, WidgetsBindingObserver, TickerProviderStateMixin {
  final heroTag = AppNavigator.arguments['heroTag'];

  late final VideoDetailController videoDetailController;
  late final PlayerController plPlayerController;

  final host = VideoHost.of();

  bool get autoExitFullscreen =>
      videoDetailController.plPlayerController.autoExitFullscreen;

  bool get autoPlayEnable =>
      videoDetailController.plPlayerController.autoPlayEnable;

  bool get enableVerticalExpand =>
      videoDetailController.plPlayerController.enableVerticalExpand;

  bool get pipNoDanmaku =>
      videoDetailController.plPlayerController.pipNoDanmaku;

  bool isShowing = true;

  bool get isFullScreen =>
      videoDetailController.plPlayerController.isFullScreen;

  bool get _shouldShowSeasonPanel =>
      host.series.shouldShowSeasonPanel(heroTag, isPortrait: isPortrait);

  final videoReplyPanelKey = GlobalKey();
  final videoRelatedKey = GlobalKey();
  final videoIntroKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // 每页访问获取播放器实例（已销毁则重建），必须先于 setPlayCallBack
    plPlayerController = host.playerHost.acquirePlayer();
    host.playerHost.setPlayCallBack(playCallBack);
    videoDetailController = VideoDetailController(vsync: this);
    videoDetailRegistry[heroTag] = videoDetailController;
    videoDetailController.initController();

    if (videoDetailController.removeSafeArea) {
      hideSystemBar();
    }

    videoSourceInit();

    addObserverMobile(this);
  }

  // 获取视频资源，初始化播放器
  void videoSourceInit() {
    videoDetailController.queryVideoUrl(autoFullScreenFlag: true);
    if (videoDetailController.autoPlay) {
      plPlayerController
        ..addStatusLister(playerListener)
        ..addPositionListener(positionListener);
    }
  }

  void positionListener(Duration position) {
    videoDetailController.playedTime = position;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isResume = state == .resumed;
    videoDetailController.plPlayerController.visible = isResume;
    if (isResume) {
      if (!host.playerHost.playerDanmakuVisible) {
        host.startIntroTimer(heroTag);
        host.playerHost.setPlayerDanmakuVisible(true);
      }
    } else if (state == .paused) {
      host.cancelIntroTimer(heroTag);
      host.playerHost.setPlayerDanmakuVisible(false);
    }
  }

  Future<void>? playCallBack() {
    if (!isShowing) {
      plPlayerController
        ..addStatusLister(playerListener)
        ..addPositionListener(positionListener);
    }
    return plPlayerController.play();
  }

  // 播放器状态监听
  Future<void> playerListener(PlayerStatus status) async {
    final isPlaying = status.isPlaying;
    try {
      if (videoDetailController.scrollCtr.hasClients) {
        if (isPlaying) {
          if (!videoDetailController.isExpanding &&
              videoDetailController.scrollCtr.offset != 0 &&
              !videoDetailController.animationController.isAnimating) {
            videoDetailController.isExpanding = true;
            videoDetailController.animationController.forward(
              from:
                  1 -
                  videoDetailController.scrollCtr.offset /
                      videoDetailController.videoHeight,
            );
          } else {
            videoDetailController.refreshPage();
          }
        } else {
          videoDetailController.refreshPage();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('handle player status: $e');
    }

    if (status.isCompleted) {
      try {
        if (videoDetailController.hasSteinChoices) {
          videoDetailController.showSteinEdgeInfo = true;
          return;
        }
      } catch (_) {}

      bool exitFlag = true;

      /// 顺序播放 列表循环
      if (host.isShutdownTimerWaiting) {
        host.handleShutdownTimer();
      } else {
        switch (host.playerHost.playerPlayRepeat) {
          case PlayRepeat.singleCycle:
            exitFlag = false;
            plPlayerController.play(repeat: true);
          case PlayRepeat.listOrder:
          case PlayRepeat.listCycle:
          case PlayRepeat.autoPlayRelated:
            exitFlag = !host.nextPlay(heroTag);
          case PlayRepeat.pause:
        }
      }

      if (exitFlag) {
        if (autoExitFullscreen) {
          plPlayerController.triggerFullScreen(status: false);
          if (plPlayerController.controlsLock) {
            plPlayerController.onLockControl(false);
          }
        } else {
          if (plPlayerController.controlsLock &&
              (!Platform.isAndroid || !AndroidHelper.isPipMode)) {
            plPlayerController.onLockControl(false);
          }
        }
      }
    }
  }
  // 继续播放或重新播放
  void continuePlay() {
    plPlayerController.play();
  }

  /// 未开启自动播放时触发播放
  Future<void>? handlePlay() {
    if (!videoDetailController.isFileSource) {
      if (videoDetailController.isQuerying) {
        if (kDebugMode) debugPrint('handlePlay: querying');
        return null;
      }
      if (videoDetailController.videoUrl == null ||
          videoDetailController.audioUrl == null) {
        if (kDebugMode) {
          debugPrint('handlePlay: videoUrl/audioUrl not initialized');
        }
        videoDetailController.queryVideoUrl();
        return null;
      }
    }
    videoDetailController.autoPlay = true;
    plPlayerController
      ..addStatusLister(playerListener)
      ..addPositionListener(positionListener);
    if (plPlayerController.preInitPlayer) {
      if (plPlayerController.autoEnterFullScreen) {
        plPlayerController.triggerFullScreen();
      }
      return plPlayerController.play();
    } else {
      return videoDetailController.playerInit(
        autoplay: true,
        autoFullScreenFlag: true,
      );
    }
  }

  @override
  void dispose() {
    // disposeIntro 内部 appRead(videoDetailControllerProvider) ——
    // 必须在 registry.remove 之前调用，否则 StateError 被 catch 吞掉导致
    // intro timer 未取消（GetX 时代 find 始终成功）。
    if (!videoDetailController.isFileSource) {
      host.disposeIntro(heroTag);
    }
    videoDetailRegistry.remove(heroTag);
    videoDetailController.dispose();
    plPlayerController
      ..removeStatusLister(playerListener)
      ..removePositionListener(positionListener);

    if (!videoDetailController.removeSafeArea) {
      showSystemBar();
    }

    if (!videoDetailController.plPlayerController.isCloseAll) {
      host.onVideoDetailDispose(heroTag);
      videoDetailController.makeHeartBeat();
      // Windows media_kit:controller 先于 Video widget unmount 释放会在
      // native 层访问已释放纹理导致进程崩溃 —— 推迟到本帧之后释放。
      final player = plPlayerController;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        player.dispose();
      });
    }
    removeObserverMobile(this);

    super.dispose();
  }

  @override
  // 离开当前页面时
  void didPushNext() {
    super.didPushNext();
    isShowing = false;

    removeObserverMobile(this);

    if (Platform.isAndroid && !videoDetailController.setSystemBrightness) {
      ScreenBrightnessPlatform.instance.resetApplicationScreenBrightness();
    }

    host.cancelIntroTimer(heroTag);

    videoDetailController
      ..videoState = false
      ..cancelBlockListener()
      ..playerStatus = plPlayerController.playerStatus
      ..brightness = plPlayerController.brightness;
    videoDetailController.makeHeartBeat();
    plPlayerController
      ..removeStatusLister(playerListener)
      ..removePositionListener(positionListener)
      ..pause();
  }

  @override
  // 返回当前页面时
  void didPopNext() {
    super.didPopNext();

    if (videoDetailController.plPlayerController.isCloseAll) {
      return;
    }

    isShowing = true;

    addObserverMobile(this);

    plPlayerController.isLive = false;
    if (videoDetailController.plPlayerController.playerStatus.isPlaying &&
        videoDetailController.playerStatus != PlayerStatus.playing) {
      videoDetailController.plPlayerController.pause();
    }

    host.playerHost.setPlayCallBack(playCallBack);

    host.startIntroTimer(heroTag);

    if (mounted &&
        Platform.isAndroid &&
        !videoDetailController.setSystemBrightness) {
      if (videoDetailController.brightness != null) {
        plPlayerController.brightness =
            videoDetailController.brightness!;
        if (videoDetailController.brightness != -1.0) {
          ScreenBrightnessPlatform.instance.setApplicationScreenBrightness(
            videoDetailController.brightness!,
          );
        } else {
          ScreenBrightnessPlatform.instance.resetApplicationScreenBrightness();
        }
      } else {
        ScreenBrightnessPlatform.instance.resetApplicationScreenBrightness();
      }
    }

    plPlayerController
      ..addStatusLister(playerListener)
      ..addPositionListener(positionListener);
    if (videoDetailController.autoPlay) {
      videoDetailController.playerInit(
        autoplay: videoDetailController.playerStatus?.isPlaying ?? false,
      );
    } else if (videoDetailController.plPlayerController.preInitPlayer &&
        !videoDetailController.isQuerying &&
        videoDetailController.videoUrl != null) {
      videoDetailController.playerInit();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (videoDetailController.removeSafeArea) {
      padding = .zero;
    } else {
      padding = MediaQuery.viewPaddingOf(context);
    }

    final size = MediaQuery.sizeOf(context);
    maxWidth = size.width;
    maxHeight = size.height;
    isWindowMode = MaxScreenSize.isWindowMode(
      width: maxWidth * videoDetailController.uiScale,
      height: maxHeight * videoDetailController.uiScale,
    );
    videoDetailController.plPlayerController.screenRatio = maxHeight / maxWidth;

    final shortestSide = size.shortestSide;
    final minVideoHeight = shortestSide / Style.aspectRatio16x9;
    final maxVideoHeight = max(size.longestSide * 0.65, shortestSide);
    videoDetailController
      ..isPortrait = isPortrait = maxHeight >= maxWidth
      ..minVideoHeight = minVideoHeight
      ..maxVideoHeight = maxVideoHeight
      ..videoHeight = videoDetailController.isVertical
          ? maxVideoHeight
          : minVideoHeight;

    themeData = videoDetailController.plPlayerController.darkVideoPage
        ? ThemeUtils.darkTheme
        : Theme.of(context);
  }

  bool removeAppBar(bool isFullScreen) =>
      videoDetailController.removeSafeArea ||
      (isWindowMode && isFullScreen && !isPortrait);

  Widget get childWhenDisabled {
    return ListenableBuilder(
      listenable: plPlayerController, builder: (context, _) {
        final isFullScreen = this.isFullScreen;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: removeAppBar(isFullScreen)
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: ListenableBuilder(
                    listenable: videoDetailController, builder: (context, _) {
                      final scrollRatio =
                          videoDetailController.scrollRatio;
                      return AppBar(
                        toolbarHeight: 0,
                        backgroundColor: isPortrait && scrollRatio > 0
                            ? Color.lerp(
                                Colors.black,
                                themeData.colorScheme.surface,
                                scrollRatio,
                              )
                            : Colors.black,
                        systemOverlayStyle: Platform.isAndroid
                            ? SystemUiOverlayStyle(
                                statusBarIconBrightness:
                                    isPortrait && scrollRatio >= 0.5
                                    ? (themeData.brightness == Brightness.dark ? Brightness.light : Brightness.dark)
                                    : .light,
                                systemNavigationBarIconBrightness:
                                    themeData.brightness == Brightness.dark
                                    ? Brightness.light
                                    : Brightness.dark,
                              )
                            : null,
                      );
                    },
                  ),
                ),
          body: ExtendedNestedScrollView(
            key: videoDetailController.scrollKey,
            controller: videoDetailController.scrollCtr,
            onlyOneScrollInBody: true,
            pinnedHeaderSliverHeightBuilder: () {
              double pinnedHeight = this.isFullScreen || !isPortrait
                  ? maxHeight - (isWindowMode && !isPortrait ? 0 : padding.top)
                  : videoDetailController.isExpanding ||
                        videoDetailController.isCollapsing
                  ? videoDetailController.animHeight
                  : videoDetailController.isCollapsing ||
                        (plPlayerController.playerStatus.isPlaying)
                  ? videoDetailController.minVideoHeight
                  : kToolbarHeight;
              if (videoDetailController.isExpanding &&
                  videoDetailController.animationController.value == 1) {
                videoDetailController.isExpanding = false;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  videoDetailController.scrollRatio = 0;
                  videoDetailController.refreshPage();
                });
              } else if (videoDetailController.isCollapsing &&
                  videoDetailController.animationController.value == 1) {
                videoDetailController.isCollapsing = false;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  videoDetailController.refreshPage();
                });
              }
              return pinnedHeight;
            },
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              final height = isFullScreen || !isPortrait
                  ? maxHeight - (isWindowMode && !isPortrait ? 0 : padding.top)
                  : videoDetailController.isExpanding ||
                        videoDetailController.isCollapsing
                  ? videoDetailController.animHeight
                  : videoDetailController.videoHeight;
              return [
                VideoHeader(
                  minExtent: kToolbarHeight,
                  maxExtent: height,
                  minVideoHeight: videoDetailController.minVideoHeight,
                  onScrollRatioChanged: (value) =>
                      videoDetailController.scrollRatio = value,
                  child: Stack(
                    clipBehavior: .none,
                    children: [
                      SizedBox(
                        width: maxWidth,
                        height: height,
                        child: videoPlayer(width: maxWidth, height: height),
                      ),
                      _buildHeaderOverlay(),
                    ],
                  ),
                ),
              ];
            },
            body: Scaffold(
              key: videoDetailController.childKey,
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  buildTabBar(onTap: videoDetailController.animToTop),
                  Expanded(
                    child: tabBarView(
                      controller: videoDetailController.tabCtr,
                      children: [
                        videoIntro(
                          isHorizontal: false,
                          needCtr: false,
                          isNested: true,
                        ),
                        if (videoDetailController.showReply)
                          videoReplyPanel(isNested: true),
                        if (_shouldShowSeasonPanel) seasonPanel,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlayToolBar(double scrollRatio) {
    final IconData icon;
    final String playStat;
    if (videoDetailController.playedTime == null) {
      icon = Icons.play_arrow_rounded;
      playStat = '立即';
    } else if (plPlayerController.isCompleted) {
      icon = CustomIcons.replay_rounded;
      playStat = '重新';
    } else {
      icon = Icons.play_arrow_rounded;
      playStat = '继续';
    }
    final playBtn = Row(
      spacing: 2,
      mainAxisSize: .min,
      children: [
        Icon(icon, color: themeData.colorScheme.primary),
        Text(
          '$playStat播放',
          style: TextStyle(color: themeData.colorScheme.primary),
        ),
      ],
    );
    return Opacity(
      opacity: videoDetailController.scrollRatio,
      child: Container(
        color: themeData.colorScheme.surface,
        alignment: .topCenter,
        child: SizedBox(
          height: kToolbarHeight,
          child: Stack(
            clipBehavior: .none,
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
                        onPressed:
                            videoDetailController.plPlayerController.onCloseAll,
                      ),
                    ),
                  ],
                ),
              ),
              Center(child: playBtn),
              Align(
                alignment: .centerRight,
                child: videoDetailController.playedTime == null
                    ? _moreBtn(themeData.colorScheme.onSurface)
                    : SizedBox(
                        width: 42,
                        height: 34,
                        child: IconButton(
                          tooltip: "更多设置",
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.zero),
                          ),
                          onPressed: () =>
                              host.showSettingSheet(
                                  videoDetailController.headerCtrKey),
                          icon: Icon(
                            Icons.more_vert_outlined,
                            size: 19,
                            color: themeData.colorScheme.onSurface,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderOverlay() {
    return ListenableBuilder(
      listenable: videoDetailController, builder: (context, _) {
        final scrollRatio = videoDetailController.scrollRatio;
        if (scrollRatio == 0) {
          return const SizedBox.shrink();
        }
        return Positioned.fill(
          bottom: -2,
          child: GestureDetector(
            onTap: () {
              if (!videoDetailController.isFileSource) {
                if (videoDetailController.isQuerying) {
                  if (kDebugMode) {
                    debugPrint('handlePlay: querying');
                  }
                  return;
                }
                if (videoDetailController.videoUrl == null ||
                    videoDetailController.audioUrl == null) {
                  if (kDebugMode) {
                    debugPrint('handlePlay: videoUrl/audioUrl not initialized');
                  }
                  videoDetailController.queryVideoUrl();
                  return;
                }
              }
              if (videoDetailController.playedTime == null) {
                handlePlay();
              } else {
                plPlayerController.onDoubleTapCenter();
              }
            },
            behavior: .opaque,
            child: _buildOverlayToolBar(scrollRatio),
          ),
        );
      },
    );
  }

  Widget get childWhenDisabledLandscape => ListenableBuilder(
    listenable: plPlayerController, builder: (context, _) {
      final isFullScreen = this.isFullScreen;
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: removeAppBar(isFullScreen)
            ? null
            : AppBar(backgroundColor: Colors.black, toolbarHeight: 0),
        body: Padding(
          padding: isFullScreen
              ? EdgeInsets.zero
              : padding.copyWith(top: 0, bottom: 0),
          child: childWhenDisabledLandscapeInner(isFullScreen),
        ),
      );
    },
  );

  Widget childSplit(double ratio) {
    final double videoHeight = maxHeight - padding.vertical;
    final double width = videoHeight * ratio;
    final videoWidth = isFullScreen ? maxWidth : width;
    final introWidth = maxWidth - width - padding.horizontal;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: videoWidth,
          height: videoHeight,
          child: videoPlayer(
            width: videoWidth,
            height: videoHeight,
          ),
        ),
        Offstage(
          offstage: isFullScreen,
          child: SizedBox(
            width: introWidth,
            height: maxHeight - padding.top,
            child: Scaffold(
              key: videoDetailController.childKey,
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTabBar(),
                  Expanded(
                    child: tabBarView(
                      controller: videoDetailController.tabCtr,
                      children: [
                        videoIntro(
                          width: introWidth,
                          height: maxHeight,
                        ),
                        if (videoDetailController.showReply) videoReplyPanel(),
                        if (_shouldShowSeasonPanel) seasonPanel,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget childWhenDisabledLandscapeInner(bool isFullScreen) {
    if (enableVerticalExpand) {
      return ListenableBuilder(listenable: videoDetailController, builder: (context, _) {
        if (videoDetailController.isVertical && !isPortrait) {
          final double videoHeight = maxHeight - padding.vertical;
          final double width = videoHeight / Style.aspectRatio16x9;
          final videoWidth = isFullScreen ? maxWidth : width;
          final introWidth = (maxWidth - padding.horizontal - width) / 2;
          final introHeight = maxHeight - padding.top;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Offstage(
                offstage: isFullScreen,
                child: SizedBox(
                  width: introWidth,
                  height: introHeight,
                  child: videoIntro(
                    width: introWidth,
                    height: introHeight,
                  ),
                ),
              ),
              SizedBox(
                width: videoWidth,
                height: videoHeight,
                child: videoPlayer(
                  width: videoWidth,
                  height: videoHeight,
                ),
              ),
              Offstage(
                offstage: isFullScreen,
                child: SizedBox(
                  width: introWidth,
                  height: introHeight,
                  child: Scaffold(
                    key: videoDetailController.childKey,
                    resizeToAvoidBottomInset: false,
                    backgroundColor: Colors.transparent,
                    body: Column(
                      children: [
                        buildTabBar(showIntro: false),
                        Expanded(
                          child: tabBarView(
                            controller: videoDetailController.tabCtr,
                            children: [
                              if (videoDetailController.showReply)
                                videoReplyPanel(),
                              if (_shouldShowSeasonPanel) seasonPanel,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return _childWhenDisabledLandscapeInner(isFullScreen);
      });
    }
    return _childWhenDisabledLandscapeInner(isFullScreen);
  }

  Widget _childWhenDisabledLandscapeInner(bool isFullScreen) {
    double width =
        clampDouble(maxHeight / maxWidth * 1.08, 0.5, 0.7) * maxWidth;
    if (maxWidth >= 560) {
      width = maxWidth - clampDouble(maxWidth - width, 280, 425);
    }
    final videoWidth = isFullScreen ? maxWidth : width;
    final double height = width / Style.aspectRatio16x9;
    final videoHeight = isFullScreen
        ? maxHeight - (isWindowMode && !isPortrait ? 0 : padding.top)
        : height;
    if (height > maxHeight) {
      return childSplit(Style.aspectRatio16x9);
    }
    final introHeight = maxHeight - height - padding.top;
    final showIntro =
        videoDetailController.isUgc && videoDetailController.showRelatedVideo;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: videoWidth,
              height: videoHeight,
              child: videoPlayer(
                width: videoWidth,
                height: videoHeight,
              ),
            ),
            if (!videoDetailController.isFileSource)
              Offstage(
                offstage: isFullScreen,
                child: SizedBox(
                  width: width,
                  height: introHeight,
                  child: videoIntro(
                    width: width,
                    height: introHeight,
                    needRelated: false,
                    needCtr: false,
                  ),
                ),
              ),
          ],
        ),
        Offstage(
          offstage: isFullScreen,
          child: SizedBox(
            width: maxWidth - width - padding.horizontal,
            height: maxHeight - padding.top,
            child: Scaffold(
              key: videoDetailController.childKey,
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTabBar(
                    introText: '相关视频',
                    showIntro: videoDetailController.isFileSource
                        ? true
                        : showIntro,
                  ),
                  Expanded(
                    child: tabBarView(
                      controller: videoDetailController.tabCtr,
                      children: [
                        if (videoDetailController.isFileSource)
                          localIntroPanel()
                        else if (showIntro)
                          KeepAliveWrapper(
                            child: CustomScrollView(
                              key: const PageStorageKey('skf-video-intro'),
                              controller:
                                  videoDetailController.effectiveIntroScrollCtr,
                              slivers: [
                                host.buildRelatedPanel(
                                  key: videoRelatedKey,
                                  heroTag: heroTag,
                                ),
                              ],
                            ),
                          ),
                        if (videoDetailController.showReply) videoReplyPanel(),
                        if (_shouldShowSeasonPanel) seasonPanel,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget get childWhenDisabledAlmostSquare => ListenableBuilder(listenable: plPlayerController, builder: (context, _) {
    final isFullScreen = this.isFullScreen;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: removeAppBar(isFullScreen)
          ? null
          : AppBar(backgroundColor: Colors.black, toolbarHeight: 0),
      body: Padding(
        padding: isFullScreen
            ? EdgeInsets.zero
            : padding.copyWith(top: 0, bottom: 0),
        child: childWhenDisabledAlmostSquareInner(isFullScreen),
      ),
    );
  });

  Widget childWhenDisabledAlmostSquareInner(bool isFullScreen) {
    if (enableVerticalExpand) {
      return ListenableBuilder(
        listenable: videoDetailController, builder: (context, _) {
          if (videoDetailController.isVertical && !isPortrait) {
            return childSplit(9 / 16);
          }

          return _childWhenDisabledAlmostSquareInner(isFullScreen);
        },
      );
    }

    return _childWhenDisabledAlmostSquareInner(isFullScreen);
  }

  Widget _childWhenDisabledAlmostSquareInner(bool isFullScreen) {
    final shouldShowSeasonPanel = _shouldShowSeasonPanel;
    final double height = maxHeight / 2.5;
    final videoHeight = isFullScreen
        ? maxHeight - (isWindowMode && !isPortrait ? 0 : padding.top)
        : height;
    final bottomHeight = maxHeight - height - padding.top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: maxWidth,
          height: videoHeight,
          child: videoPlayer(
            width: maxWidth,
            height: videoHeight,
          ),
        ),
        Offstage(
          offstage: isFullScreen,
          child: SizedBox(
            width: maxWidth - padding.horizontal,
            height: bottomHeight,
            child: Scaffold(
              key: videoDetailController.childKey,
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTabBar(needIndicator: false),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: videoIntro(
                            width: () {
                              double flex = 1;
                              if (videoDetailController.showReply) flex++;
                              if (shouldShowSeasonPanel) flex++;
                              return maxWidth / flex;
                            }(),
                            height: bottomHeight,
                          ),
                        ),
                        if (videoDetailController.showReply)
                          Expanded(child: videoReplyPanel()),
                        if (shouldShowSeasonPanel) Expanded(child: seasonPanel),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget get manualPlayerWidget => ListenableBuilder(listenable: videoDetailController, builder: (context, _) {
    if (!videoDetailController.autoPlay) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              primary: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  const SizedBox(
                    width: 42,
                    height: 34,
                    child: IconButton(
                      tooltip: '返回',
                      icon: Icon(
                        FontAwesomeIcons.arrowLeft,
                        size: 15,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 1.5,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      onPressed: AppNavigator.back,
                    ),
                  ),
                  SizedBox(
                    width: 42,
                    height: 34,
                    child: IconButton(
                      tooltip: '返回主页',
                      icon: const Icon(
                        FontAwesomeIcons.house,
                        size: 15,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 1.5,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      onPressed:
                          videoDetailController.plPlayerController.onCloseAll,
                    ),
                  ),
                ],
              ),
              actions: [
                _moreBtn(
                  Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 1.5,
                      color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 10,
            child: IconButton(
              tooltip: '播放',
              onPressed: handlePlay,
              icon: const PlayIcon(),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  });

  Widget _moreBtn(Color color, {List<Shadow>? shadows}) => PopupMenuButton(
    icon: Icon(
      size: 22,
      Icons.more_vert,
      color: color,
      shadows: shadows,
    ),
    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      PopupMenuItem(
        onTap: () => host.viewLater(heroTag),
        child: const Text('稍后再看'),
      ),
      if (videoDetailController.epId == null)
        PopupMenuItem(
          onTap: () => videoDetailController.showNoteList(context),
          child: const Text('查看笔记'),
        ),
      if (!videoDetailController.isFileSource)
        PopupMenuItem(
          onTap: () => videoDetailController.onDownload(this.context),
          child: const Text('缓存视频'),
        ),
      if (videoDetailController.cover.isNotEmpty)
        PopupMenuItem(
          onTap: () =>
              ImageUtils.downloadImg([videoDetailController.cover]),
          child: const Text('保存封面'),
        ),
      if (!videoDetailController.isFileSource && videoDetailController.isUgc)
        PopupMenuItem(
          onTap: videoDetailController.toAudioPage,
          child: const Text('听音频'),
        ),
    ],
  );

  Widget plPlayer({
    required double width,
    required double height,
    bool isPipMode = false,
  }) => popScope(
    key: videoDetailController.videoPlayerKey,
    canPop:
        !isFullScreen &&
        !videoDetailController.plPlayerController.isDesktopPip &&
        (videoDetailController.horizontalScreen || isPortrait),
    onPopInvokedWithResult:
        videoDetailController.plPlayerController.onPopInvokedWithResult,
    child: ListenableBuilder(
      listenable: videoDetailController, builder: (context, _) =>
          !videoDetailController.videoState ||
              !videoDetailController.autoPlay ||
              plPlayerController.videoController == null
          ? const SizedBox.shrink()
          : host.buildPlayer(
              heroTag: heroTag,
              width: width,
              height: height,
              isPipMode: isPipMode,
              isPortrait: isPortrait,
            ),
    ),
  );

  late ThemeData themeData;
  late bool isPortrait;
  late double maxWidth;
  late double maxHeight;
  bool isWindowMode = false;
  late EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (videoDetailController.plPlayerController.isPipMode) {
      child = plPlayer(width: maxWidth, height: maxHeight, isPipMode: true);
    } else if (!videoDetailController.horizontalScreen) {
      child = childWhenDisabled;
    } else if (maxWidth / maxHeight >= kScreenRatio) {
      child = childWhenDisabledLandscape;
    } else if (maxWidth / Style.aspectRatio16x9 < 0.4 * maxHeight) {
      child = childWhenDisabled;
    } else {
      child = childWhenDisabledAlmostSquare;
    }
    if (videoDetailController.plPlayerController.keyboardControl) {
      final focus = host.buildKeyboardFocus(
        child: child,
        heroTag: heroTag,
        onSendDanmaku: videoDetailController.showShootDanmakuSheet,
        canPlay: () {
          if (videoDetailController.autoPlay) {
            return true;
          }
          handlePlay();
          return false;
        },
        onSkipSegment: videoDetailController.onSkipSegment,
      );
      if (focus != null) {
        child = focus;
      }
    }
    return videoDetailController.plPlayerController.darkVideoPage
        ? Theme(data: themeData, child: child)
        : child;
  }

  Widget buildTabBar({
    bool needIndicator = true,
    String? introText,
    bool showIntro = true,
    VoidCallback? onTap,
  }) {
    List<String> tabs = [
      if (showIntro)
        videoDetailController.isFileSource ? '离线视频' : introText ?? '简介',
      if (videoDetailController.showReply) '评论',
      if (_shouldShowSeasonPanel) '播放列表',
    ];
    if (videoDetailController.tabCtr.length != tabs.length) {
      videoDetailController.tabCtr.dispose();
      videoDetailController.tabCtr = TabController(
        vsync: this,
        length: tabs.length,
        initialIndex: tabs.isEmpty
            ? 0
            : videoDetailController.tabCtr.index.clamp(0, tabs.length - 1),
      );
    }

    final flag = !needIndicator || tabs.length == 1;
    Widget tabBar() => TabBar(
      labelColor: flag ? themeData.colorScheme.onSurface : null,
      indicator: flag ? const BoxDecoration() : null,
      padding: EdgeInsets.zero,
      controller: videoDetailController.tabCtr,
      labelStyle:
          TabBarTheme.of(context).labelStyle?.copyWith(fontSize: 13) ??
          const TextStyle(fontSize: 13),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      dividerColor: Colors.transparent,
      dividerHeight: 0,
      onTap: (value) {
        void animToTop() {
          if (onTap != null) {
            onTap();
            return;
          }
          String text = tabs[value];
          if (videoDetailController.isFileSource ||
              text == '简介' ||
              text == '相关视频') {
            videoDetailController.introScrollCtr?.animToTop();
          } else if (text.startsWith('评论')) {
            host.animateReplyToTop(heroTag);
          }
        }

        if (flag) {
          animToTop();
        } else if (!videoDetailController.tabCtr.indexIsChanging) {
          animToTop();
        }
      },
      tabs: tabs.map((text) {
        if (text == '评论') {
          return host.buildReplyTabLabel(heroTag: heroTag);
        } else {
          return Tab(text: text);
        }
      }).toList(),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeData.dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SizedBox(
        height: 45,
        child: Row(
          children: [
            if (tabs.isEmpty)
              const Spacer()
            else
              Flexible(
                flex: tabs.length == 3 ? 2 : 1,
                child: tabBar(),
              ),
            Flexible(
              flex: 1,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: TextButton(
                        style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.zero),
                        ),
                        onPressed: videoDetailController.showShootDanmakuSheet,
                        child: Text(
                          '发弹幕',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeData.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: Builder(
                        builder: (_) {
                          final enableShowDanmaku = host.playerHost.danmakuEnabled;
                          return IconButton(
                            onPressed: () => host.playerHost.toggleDanmakuEnabled(),
                            icon: Icon(
                              size: 22,
                              enableShowDanmaku
                                  ? CustomIcons.dm_on
                                  : CustomIcons.dm_off,
                              color: enableShowDanmaku
                                  ? themeData.colorScheme.secondary
                                  : themeData.colorScheme.outline,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget videoPlayer({required double width, required double height}) {
    final isFullScreen = this.isFullScreen;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.black)),

        plPlayer(width: width, height: height),

        ListenableBuilder(listenable: videoDetailController, builder: (context, _) {
          if (!videoDetailController.autoPlay) {
            return Positioned.fill(
              bottom: -1,
              child: GestureDetector(
                onTap: handlePlay,
                behavior: .opaque,
                child:
                  NetworkImgLayer(
                    type: .emote,
                    quality: 60,
                    src: videoDetailController.cover,
                    width: width,
                    height: height,
                    cacheWidth: true,
                    getPlaceHolder: () => Center(
                      child: Image.asset(Assets.loading),
                    ),
                  ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        manualPlayerWidget,

        ...host.buildPlayerOverlays(
          heroTag: heroTag,
          isFullScreen: isFullScreen,
          maxHeight: maxHeight,
        ),
      ],
    );
  }

  Widget localIntroPanel({
    bool needCtr = true,
  }) {
    return CustomScrollView(
      controller: needCtr
          ? videoDetailController.effectiveIntroScrollCtr
          : null,
      physics: !needCtr
          ? const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics())
          : null,
      key: const PageStorageKey('skf-video-local-intro'),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: 7, bottom: padding.bottom + 100),
          sliver: host.buildLocalIntroPanel(
            key: videoRelatedKey,
            heroTag: heroTag,
          ),
        ),
      ],
    );
  }

  Widget videoIntro({
    double? width,
    double? height,
    bool? isHorizontal,
    bool needRelated = true,
    bool needCtr = true,
    bool isNested = false,
  }) {
    if (videoDetailController.isFileSource) {
      return localIntroPanel(needCtr: needCtr);
    }
    Widget introPanel() {
      Widget child = CustomScrollView(
        key: const PageStorageKey('skf-video-intro'),
        controller: needCtr
            ? videoDetailController.effectiveIntroScrollCtr
            : null,
        physics: !needCtr
            ? const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              )
            : null,
        slivers: [
          if (videoDetailController.isUgc) ...[
            host.buildUgcIntroPanel(
              key: videoIntroKey,
              heroTag: heroTag,
              isPortrait: isPortrait,
              isHorizontal: isHorizontal ?? width! / height! >= kScreenRatio,
            ),
            if (needRelated && videoDetailController.showRelatedVideo) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: Style.safeSpace,
                  ),
                  child: Divider(
                    height: 1,
                    indent: 12,
                    endIndent: 12,
                    color: themeData.colorScheme.outline.withValues(
                      alpha: 0.08,
                    ),
                  ),
                ),
              ),
              host.buildRelatedPanel(key: videoRelatedKey, heroTag: heroTag),
            ],
          ] else
            host.series.buildSeriesIntroPage(
              key: videoIntroKey,
              heroTag: heroTag,
              cid: videoDetailController.cid,
              maxWidth: width ?? maxWidth,
              isLandscape: !isPortrait,
            ),
          SliverToBoxAdapter(
            child: SizedBox(
              height:
                  (videoDetailController.isPlayAll && !isPortrait
                      ? 80
                      : Style.safeSpace) +
                  padding.bottom,
            ),
          ),
        ],
      );
      if (isNested) {
        child = ExtendedVisibilityDetector(
          uniqueKey: const Key('intro-panel'),
          child: child,
        );
      }
      return KeepAliveWrapper(child: child);
    }

    if (videoDetailController.isPlayAll) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          introPanel(),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12 + padding.bottom,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => videoDetailController.showMediaListPanel(context),
                borderRadius: const BorderRadius.all(Radius.circular(14)),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.secondaryContainer.withValues(
                      alpha: 0.95,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_play, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        videoDetailController.watchLaterTitle,
                        style: TextStyle(
                          color: themeData.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_up_rounded, size: 26),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return introPanel();
  }

  Widget get seasonPanel =>
      host.series.buildSeasonPanel(heroTag: heroTag);

  Widget videoReplyPanel({bool isNested = false}) => host.buildReplyPanel(
    key: videoReplyPanelKey,
    heroTag: heroTag,
    isNested: isNested,
  );
}
