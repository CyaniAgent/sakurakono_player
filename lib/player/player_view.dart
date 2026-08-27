import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:skf/common/assets.dart';
import 'package:skf/common/widgets/gesture/immediate_tap_gesture_recognizer.dart';
import 'package:skf/common/widgets/gesture/mouse_interactive_viewer.dart';
import 'package:skf/common/widgets/gesture/player_gesture_recognizer.dart';
import 'package:skf/common/widgets/player_bar.dart';
import 'package:skf/common/widgets/progress_bar/audio_video_progress_bar.dart';
import 'package:skf/common/widgets/progress_bar/segment_progress_bar.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/player/models/bottom_progress_behavior.dart';
import 'package:skf/player/models/double_tap_type.dart';
import 'package:skf/player/models/gesture_type.dart';
import 'package:skf/player/models/data_status.dart';
import 'package:skf/player/models/player_overlay_source.dart';
import 'package:skf/player/models/player_view_contracts.dart';
import 'package:skf/player/models/video_fit_type.dart';
import 'package:skf/player/player_controller.dart';
import 'package:skf/player/widgets/app_bar_ani.dart';
import 'package:skf/player/widgets/backward_seek.dart';
import 'package:skf/player/widgets/bottom_control.dart';
import 'package:skf/player/widgets/common_btn.dart';
import 'package:skf/player/widgets/forward_seek.dart';
import 'package:skf/player/widgets/video_time.dart';
import 'package:skf/utils/android/bindings.g.dart';
import 'package:skf/utils/duration_utils.dart';
import 'package:skf/utils/extension/num_ext.dart';
import 'package:skf/utils/mobile_observer.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';
import 'package:window_manager/window_manager.dart';

/// 通用播放器 UI 外壳：视频渲染、手势（双击/滑动/长按）、控制栏
/// （播放/暂停/进度/音量/倍速/画面比例/全屏/锁定/截图）、字幕显示、
/// 缓冲加载、PiP chrome、控制栏自动隐藏。
///
/// 零适配器依赖：B站 专属内容（QA 弹窗、选集、弹幕动作、超分、live 弹幕
/// 报告、高能进度条、拖动预览等）通过注入槽接入：
/// - [headerControl] / [bottomControl] / [danmuWidget]：头部/底部/弹幕层组件
/// - [overlaySource]：分段/分段信息/高能进度条数据
/// - [dmChartBuilder]：高能进度条图表构建器
/// - [dmTapInteraction]：弹幕点按动作浮层
/// - [seekPreview]：拖动预览
/// - [buildBottomBar]：底部按钮条构建器（默认使用通用项）
/// - [onControlsVisibilityChanged] / [onPointerExitControls]：控制栏状态联动
/// - [onScreenshotTap] / [onScreenshotLongPress]：截图动作
class PlayerView extends StatefulWidget {
  const PlayerView({
    required this.maxWidth,
    required this.maxHeight,
    required this.plPlayerController,
    required this.headerControl,
    this.bottomControl,
    this.danmuWidget,
    this.overlaySource,
    this.dmChartBuilder,
    this.dmTapInteraction,
    this.seekPreview,
    this.buildBottomBar,
    this.onControlsVisibilityChanged,
    this.onPointerExitControls,
    this.onScreenshotTap,
    this.onScreenshotLongPress,
    this.progressType,
    this.fill = Colors.black,
    this.alignment = Alignment.center,
    super.key,
  });

  final double maxWidth;
  final double maxHeight;
  final PlayerController plPlayerController;

  /// 头部控制栏（B站: HeaderControl / LiveHeaderControl）。
  final Widget headerControl;

  /// 整体替换底部控制栏（B站 live 房间传入自己的 BottomControl）。
  final Widget? bottomControl;

  /// 弹幕层（B站: PlDanmaku / LiveDanmaku）。
  final Widget? danmuWidget;

  /// 进度条覆盖层数据源（分段/分段信息/高能进度条）。
  final PlayerOverlaySource? overlaySource;

  /// 高能进度条图表构建器（B站: fl_chart 折线图）。
  final PlayerDmChartBuilder? dmChartBuilder;

  /// 弹幕点按交互（B站: 点赞/复制/删除/举报 动作浮层）。
  final PlayerDmTapInteraction? dmTapInteraction;

  /// 拖动预览（B站: video shot 截图精灵图）。
  final PlayerSeekPreview? seekPreview;

  /// 底部按钮条构建器；为 null 时使用通用默认项。
  final ValueGetter<Widget>? buildBottomBar;

  /// 控制栏可见性变化回调（B站: 时钟/电量 + 字幕内边距联动）。
  final ValueChanged<bool>? onControlsVisibilityChanged;

  /// 鼠标移出播放器时控制栏状态值（B站: showSteinEdgeInfo）。
  final ValueGetter<bool>? onPointerExitControls;

  /// 截图按钮点击（B站: mpv 截图保存）。
  final VoidCallback? onScreenshotTap;

  /// 截图按钮长按（B站: 动态 webp 截图）。
  final VoidCallback? onScreenshotLongPress;

  /// 底部进度条展示行为；为 null 时使用 [BtmProgressBehavior.alwaysShow]。
  final BtmProgressBehavior? progressType;

  final Color fill;
  final Alignment alignment;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController _animationController;
  late VideoController videoController;

  final _playerKey = GlobalKey();
  final _videoKey = GlobalKey();

  double _brightnessValue = 0.0;
  bool _brightnessIndicator = false;
  Timer? _brightnessTimer;

  late bool showRestoreScaleBtn = false;

  GestureType? _gestureType;
  Offset? _initialFocalPoint;

  bool _pauseDueToPauseUponEnteringBackgroundMode = false;

  StreamSubscription? _brightnessListener;
  void _onBrightnessChanged(double value) {
    if (mounted && _gestureType != .left) {
      _brightnessValue = value;
    }
  }

  void _getSystemBrightness() {
    ScreenBrightnessPlatform.instance.system.then((res) {
      if (mounted) {
        _brightnessValue = res;
      }
    });
  }

  void _getAppBrightness() {
    ScreenBrightnessPlatform.instance.application.then((res) {
      if (mounted) {
        _brightnessValue = res;
      }
    });
  }

  void _onVolumeChanged(double value) {
    if (mounted && !plPlayerController.volumeInterceptEventStream) {
      plPlayerController.volume = value;
      if (Platform.isIOS && !FlutterVolumeController.showSystemUI) {
        plPlayerController
          ..volumeIndicator = true
          ..volumeTimer?.cancel()
          ..volumeTimer = Timer(
            const Duration(milliseconds: 800),
            () {
              if (mounted) {
                plPlayerController.volumeIndicator = false;
              }
            },
          );
      }
    }
  }

  void _getCurrVolume() {
    FlutterVolumeController.getVolume().then((res) {
      if (mounted) {
        plPlayerController.volume = res!;
      }
    });
  }

  VoidCallback? _controlsListener;
  void _onControlChanged() {
    final visible = plPlayerController.showControls && !plPlayerController.controlsLock;

    widget.onControlsVisibilityChanged?.call(visible);

    if (visible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    addObserverMobile(this);

    _controlsListener = _onControlChanged;
    plPlayerController.addListener(_controlsListener!);

    _transformationController = TransformationController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    videoController = plPlayerController.videoController!;

    if (PlatformUtils.isMobile) {
      Future.microtask(() {
        try {
          FlutterVolumeController.updateShowSystemUI(true);
          _getCurrVolume();
          FlutterVolumeController.addListener(
            _onVolumeChanged,
            emitOnStart: false,
          );
        } catch (_) {}

        try {
          if (Platform.isIOS || plPlayerController.setSystemBrightness) {
            _getSystemBrightness();
            _brightnessListener = ScreenBrightnessPlatform
                .instance
                .onSystemScreenBrightnessChanged
                .listen(_onBrightnessChanged);
          } else {
            _getAppBrightness();
            _brightnessListener = ScreenBrightnessPlatform
                .instance
                .onApplicationScreenBrightnessChanged
                .listen(_onBrightnessChanged);
          }
        } catch (_) {}
      });
    }

    final dmTap = widget.dmTapInteraction;
    if (dmTap != null && dmTap.enabled) {
      _tapGestureRecognizer = ImmediateTapGestureRecognizer(
        onTapDown: dmTap.visible ? _onTapDown : null,
        onTapUp: _onTapUp,
        onTapCancel: dmTap.cancel,
      );

      _danmakuListener = dmTap.visibilityChanges.listen((value) {
        if (!value) dmTap.cancel();
        _tapGestureRecognizer.onTapDown = value ? _onTapDown : null;
      });
    } else {
      _tapGestureRecognizer = ImmediateTapGestureRecognizer(onTapUp: _onTapUp);
    }

    _doubleTapGestureRecognizer = DoubleTapGestureRecognizer()
      ..onDoubleTapDown = _onDoubleTapDown;

    _scaleGestureRecognizer = PlayerScaleGestureRecognizer(
      debugOwner: this,
      dragStartBehavior: .start,
      allowedButtonsFilter: (buttons) => buttons == kPrimaryButton,
      trackpadScrollToScaleFactor: const Offset(
        0,
        -1 / kDefaultMouseScrollToScaleFactor,
      ),
      trackpadScrollCausesScale: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!plPlayerController.continuePlayInBackground) {
      late final player = plPlayerController.videoPlayerController;
      if (const <AppLifecycleState>[.paused, .detached].contains(state)) {
        if (player != null && player.state.playing) {
          _pauseDueToPauseUponEnteringBackgroundMode = true;
          player.pause();
        }
      } else {
        if (_pauseDueToPauseUponEnteringBackgroundMode) {
          _pauseDueToPauseUponEnteringBackgroundMode = false;
          player?.play();
        }
      }
    }
  }

  Future<void> setBrightness(double value) async {
    _brightnessValue = value;
    try {
      if (Platform.isIOS || plPlayerController.setSystemBrightness) {
        await ScreenBrightnessPlatform.instance.setSystemScreenBrightness(
          value,
        );
      } else {
        await ScreenBrightnessPlatform.instance.setApplicationScreenBrightness(
          value,
        );
      }
    } catch (_) {}
    _brightnessIndicator = true;
    _brightnessTimer?.cancel();
    _brightnessTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _brightnessIndicator = false;
      }
    });
    plPlayerController.brightness = value;
  }

  @override
  void dispose() {
    removeObserverMobile(this);
    _danmakuListener?.cancel();
    _tapGestureRecognizer.dispose();
    _longPressRecognizer?.dispose();
    _doubleTapGestureRecognizer.dispose();
    _scaleGestureRecognizer.dispose();
    _brightnessListener?.cancel();
    if (_controlsListener != null) {
      plPlayerController.removeListener(_controlsListener!);
    }
    _animationController.dispose();
    _transformationController.dispose();
    widget.dmTapInteraction?.cancel();
    if (PlatformUtils.isMobile) {
      FlutterVolumeController.removeListener();
    }
    super.dispose();
  }

  PlayerController get plPlayerController => widget.plPlayerController;

  bool get isFullScreen => plPlayerController.isFullScreen;

  late final TransformationController _transformationController;

  late ColorScheme colorScheme;
  late double maxWidth;
  late double maxHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorScheme = ColorScheme.of(context);
  }

  @override
  void didUpdateWidget(covariant PlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (Platform.isAndroid && AndroidHelper.isPipMode) {
      plPlayerController.controls = false;
    }
  }

  void _onPanStart(ScaleStartDetails details) {
    _gestureType = null;
    _initialFocalPoint = details.localFocalPoint;
  }

  void _onScaleUpdate(double scale) {
    showRestoreScaleBtn = scale != 1.0;
  }

  void _onHorizontalDragStart() {
    plPlayerController.isSeeking = true;
  }

  void _onHorizontalDragUpdate(double dx) {
    final curPos =
        plPlayerController.seekToPos?.inMilliseconds ??
        plPlayerController.position * 1000;
    final posDelta = (plPlayerController.sliderScale * dx / maxWidth).round();
    final newPos = (curPos + posDelta).clamp(
      0,
      plPlayerController.durationInMilliseconds,
    );
    final seconds = newPos ~/ 1000;
    plPlayerController
      ..seekToPos = Duration(milliseconds: newPos)
      ..position = seconds;
    if (!plPlayerController.isFileSource &&
        widget.seekPreview?.enabled == true) {
      widget.seekPreview!.updateIndex(seconds);
    }
  }

  void _onHorizontalDragEnd() {
    plPlayerController.onSeekEnd();
    if (plPlayerController.seekToPos case final seekToPos?) {
      plPlayerController
        ..seekTo(seekToPos, isSeek: false)
        ..seekToPos = null;
    } else {
      plPlayerController.position =
          plPlayerController.videoPlayerController?.state.position.inSeconds ??
          0;
    }
  }

  void _onPanUpdate(ScaleUpdateDetails details) {
    if (_gestureType == null) {
      final cumulativeDelta = details.localFocalPoint - _initialFocalPoint!;
      if (cumulativeDelta.distanceSquared < 1) return;
      final dx = cumulativeDelta.dx.abs();
      final dy = cumulativeDelta.dy.abs();
      if (dx > 3 * dy) {
        _onHorizontalDragStart();
        _gestureType = .horizontal;
      } else if (dy > 3 * dx) {
        if (!plPlayerController.enableSlideVolumeBrightness &&
            !plPlayerController.enableSlideFS) {
          return;
        }

        final double tapPosition = details.localFocalPoint.dx;
        final double sectionWidth = maxWidth / 3;
        if (tapPosition < sectionWidth) {
          if (!plPlayerController.enableSlideVolumeBrightness) {
            return;
          }
          // 左边区域
          if (PlatformUtils.isDesktop) {
            _gestureType = .right;
          } else {
            _gestureType = .left;
          }
        } else if (tapPosition < sectionWidth * 2) {
          if (!plPlayerController.enableSlideFS) {
            return;
          }
          // 全屏
          _gestureType = .center;
        } else {
          if (!plPlayerController.enableSlideVolumeBrightness) {
            return;
          }
          // 右边区域
          _gestureType = .right;
        }
      }
      return;
    }

    Offset delta = details.focalPointDelta;

    if (_gestureType == .horizontal) {
      // live模式下禁用
      if (plPlayerController.isLive) return;

      final height = maxHeight * 0.125;
      if (details.localFocalPoint.dy <= height &&
          (details.localFocalPoint.dx >= maxWidth * 0.875 ||
              details.localFocalPoint.dx <= maxWidth * 0.125)) {
        if (!plPlayerController.hasToasted) {
          plPlayerController
            ..seekToPos = null
            ..hasToasted = true;
          if (widget.seekPreview?.enabled == true) {
            widget.seekPreview!.hide();
          }
          SmartDialog.showAttach(
            targetContext: context,
            alignment: Alignment.center,
            animationTime: const Duration(milliseconds: 200),
            animationType: SmartAnimationType.fade,
            displayTime: const Duration(milliseconds: 1500),
            maskColor: Colors.transparent,
            builder: (context) => Container(
              padding: const .symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: const .all(.circular(6)),
                color: colorScheme.secondaryContainer,
              ),
              child: Text(
                '松开手指，取消进退',
                style: TextStyle(color: colorScheme.onSecondaryContainer),
              ),
            ),
          );
        }
        return;
      } else if (plPlayerController.hasToasted) {
        plPlayerController.hasToasted = false;
      }

      _onHorizontalDragUpdate(delta.dx);
    } else if (_gestureType == .left) {
      // 左边区域 👈
      final double level = maxHeight * 3;
      final double brightness = (_brightnessValue - delta.dy / level)
          .clamp(0.0, 1.0);
      setBrightness(brightness);
    } else if (_gestureType == .center) {
      // 全屏
      const double threshold = 2.5; // 滑动阈值
      double cumulativeDy = details.localFocalPoint.dy - _initialFocalPoint!.dy;

      void fullScreenTrigger(bool status) {
        plPlayerController.triggerFullScreen(status: status);
      }

      if (cumulativeDy > threshold) {
        _gestureType = .center_down;
        if (isFullScreen ^ plPlayerController.fullScreenGestureReverse) {
          fullScreenTrigger(
            plPlayerController.fullScreenGestureReverse,
          );
        }
      } else if (cumulativeDy < -threshold) {
        _gestureType = .center_up;
        if (!isFullScreen ^ plPlayerController.fullScreenGestureReverse) {
          fullScreenTrigger(
            !plPlayerController.fullScreenGestureReverse,
          );
        }
      }
    } else if (_gestureType == .right) {
      // 右边区域
      final double level = maxHeight * 0.5;
      EasyThrottle.throttle(
        'setVolume',
        const Duration(milliseconds: 20),
        () {
          final double volume = clampDouble(
            plPlayerController.volume - delta.dy / level,
            0.0,
            plPlayerController.maxVolume,
          );
          plPlayerController.setVolume(volume);
        },
      );
    }
  }

  void _onPanEnd(ScaleEndDetails details) {
    if (_gestureType == .horizontal) {
      _onHorizontalDragEnd();
    }
    _initialFocalPoint = null;
    _gestureType = null;
  }

  void onDoubleTapDownMobile(TapDownDetails details) {
    if (plPlayerController.isLive || plPlayerController.controlsLock) {
      return;
    }
    final double tapPosition = details.localPosition.dx;
    final double sectionWidth = maxWidth / 4;
    DoubleTapType type;
    if (tapPosition < sectionWidth) {
      type = DoubleTapType.left;
    } else if (tapPosition < sectionWidth * 3) {
      type = DoubleTapType.center;
    } else {
      type = DoubleTapType.right;
    }
    plPlayerController.doubleTapFuc(type);
  }

  void _onTapUp(TapUpDetails details) {
    switch (details.kind) {
      case ui.PointerDeviceKind.mouse when PlatformUtils.isDesktop:
        plPlayerController.onDoubleTapCenter();
      default:
        if (widget.dmTapInteraction?.handleTapUp(details) == true) return;
        plPlayerController.controls = !plPlayerController.showControls;
    }
  }

  void _onTapDown(TapDownDetails details) {
    widget.dmTapInteraction?.handleTapDown(details);
  }

  void _onDoubleTapDown(TapDownDetails details) {
    switch (details.kind) {
      case ui.PointerDeviceKind.mouse when PlatformUtils.isDesktop:
        plPlayerController.triggerFullScreen(status: !isFullScreen);
      default:
        onDoubleTapDownMobile(details);
    }
  }

  LongPressGestureRecognizer? _longPressRecognizer;
  LongPressGestureRecognizer get longPressRecognizer => _longPressRecognizer ??=
      LongPressGestureRecognizer(
          duration: widget.dmTapInteraction?.enabled == true
              ? const Duration(milliseconds: 300)
              : null,
        )
        ..onLongPressStart = ((_) =>
            plPlayerController.setLongPressStatus(true))
        ..onLongPressEnd = ((_) => plPlayerController.setLongPressStatus(false))
        ..onLongPressCancel = (() =>
            plPlayerController.setLongPressStatus(false));
  late final ImmediateTapGestureRecognizer _tapGestureRecognizer;
  late final DoubleTapGestureRecognizer _doubleTapGestureRecognizer;
  late final PlayerScaleGestureRecognizer _scaleGestureRecognizer;

  StreamSubscription<bool>? _danmakuListener;

  static const _kOffsetThreshold = 25.0;
  bool _isPositionAllowed(Offset offset) {
    if (offset.dx < _kOffsetThreshold ||
        offset.dy < _kOffsetThreshold ||
        offset.dx > maxWidth - _kOffsetThreshold ||
        offset.dy > maxHeight - _kOffsetThreshold) {
      return false;
    }
    return true;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (PlatformUtils.isDesktop) {
      final buttons = event.buttons;
      final isSecondaryBtn = buttons == kSecondaryMouseButton;
      if (isSecondaryBtn || buttons == kMiddleMouseButton) {
        final isFullScreen = this.isFullScreen;
        if (isFullScreen && plPlayerController.controlsLock) {
          plPlayerController
            ..controlsLock = false
            ..showControls = false;
        }
        plPlayerController.triggerFullScreen(
          status: !isFullScreen,
          inAppFullScreen: isSecondaryBtn,
        );
        return;
      }
    }

    final controlsUnlock = !plPlayerController.controlsLock;
    if (PlatformUtils.isMobile) {
      _tapGestureRecognizer.addPointer(event);
      if (controlsUnlock) {
        if (!plPlayerController.isLive) {
          _doubleTapGestureRecognizer.addPointer(event);
          longPressRecognizer.addPointer(event);
        }
        _scaleGestureRecognizer
          ..isPosAllowed = _isPositionAllowed(event.localPosition)
          ..addPointer(event);
      }
    } else if (controlsUnlock) {
      if (plPlayerController.isLive) {
        _doubleTapGestureRecognizer.addPointer(event);
      } else {
        _tapGestureRecognizer.addPointer(event);
        _doubleTapGestureRecognizer.addPointer(event);
        longPressRecognizer.addPointer(event);
      }
      _scaleGestureRecognizer.addPointer(event);
    }
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (plPlayerController.controlsLock) return;
    if (_gestureType == null) {
      final pan = event.pan;
      if (pan.distanceSquared < 1) return;
      final dx = pan.dx.abs();
      final dy = pan.dy.abs();
      if (dx > 3 * dy) {
        _onHorizontalDragStart();
        _gestureType = .horizontal;
      } else if (dy > 3 * dx) {
        _gestureType = .right;
      }
      return;
    }

    if (_gestureType == .horizontal) {
      if (plPlayerController.isLive) return;

      _onHorizontalDragUpdate(event.localPanDelta.dx);
    } else if (_gestureType == .right) {
      if (!plPlayerController.enableSlideVolumeBrightness) {
        return;
      }

      final double level = maxHeight * 0.5;
      EasyThrottle.throttle(
        'setVolume',
        const Duration(milliseconds: 20),
        () {
          final double volume = clampDouble(
            plPlayerController.volume - event.localPanDelta.dy / level,
            0.0,
            plPlayerController.maxVolume,
          );
          plPlayerController.setVolume(volume);
        },
      );
    }
  }

  void _onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    if (_gestureType == .horizontal) {
      _onHorizontalDragEnd();
    }
    _gestureType = null;
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final offset = -event.scrollDelta.dy / 4000;
      final volume = clampDouble(
        plPlayerController.volume + offset,
        0.0,
        plPlayerController.maxVolume,
      );
      plPlayerController.setVolume(volume);
    }
  }

  @override
  Widget build(BuildContext context) {
    maxWidth = widget.maxWidth;
    maxHeight = widget.maxHeight;
    final isFullScreen = this.isFullScreen;
    final primary = isFullScreen && colorScheme.brightness == Brightness.light
        ? colorScheme.inversePrimary
        : colorScheme.primary;
    late final thumbGlowColor = primary.withAlpha(80);
    late final bufferedBarColor = primary.withValues(alpha: 0.4);
    const TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
    );
    final isLive = plPlayerController.isLive;
    final overlaySource = widget.overlaySource;
    final dmTap = widget.dmTapInteraction;

    final child = Stack(
      fit: StackFit.passthrough,
      key: _playerKey,
      children: <Widget>[
        _videoWidget,

        if (widget.danmuWidget case final danmaku?)
          Positioned.fill(top: 4, child: danmaku),

        if (!isLive)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !plPlayerController.enableDragSubtitle,
              child: ListenableBuilder(
                listenable: plPlayerController,
                builder: (context, _) => SubtitleView(
                  controller: videoController,
                  configuration: plPlayerController.subtitleConfig,
                  enableDragSubtitle: plPlayerController.enableDragSubtitle,
                  onUpdatePadding: plPlayerController.onUpdatePadding,
                ),
              ),
            ),
          ),

        if (dmTap != null && dmTap.enabled)
          dmTap.buildOverlay(context),

        /// 长按倍速 toast
        if (!isLive)
          IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionalTranslation(
                translation: isFullScreen
                    ? const Offset(0.0, 1.2)
                    : const Offset(0.0, 0.8),
                child: ListenableBuilder(
                  listenable: plPlayerController,
                  builder: (context, _) => AnimatedOpacity(
                    curve: Curves.easeInOut,
                    opacity: plPlayerController.longPressStatus
                        ? 1.0
                        : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0x88000000),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: ListenableBuilder(
                        listenable: plPlayerController,
                        builder: (context, _) => Text(
                          '${plPlayerController.enableAutoLongPressSpeed ? (plPlayerController.longPressStatus ? plPlayerController.lastPlaybackSpeed : plPlayerController.playbackSpeed) * 2 : plPlayerController.longPressSpeed}倍速中',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        /// 时间进度 toast
        if (!isLive)
          IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionalTranslation(
                translation: isFullScreen
                    ? const Offset(0.0, 1.2)
                    : const Offset(0.0, 0.8),
                child: ListenableBuilder(
                  listenable: plPlayerController,
                  builder: (context, _) => AnimatedOpacity(
                    curve: Curves.easeInOut,
                    opacity: plPlayerController.isSeeking ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0x88000000),
                        borderRadius: BorderRadius.all(Radius.circular(64)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        spacing: 2,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListenableBuilder(
                            listenable: plPlayerController,
                            builder: (context, _) => Text(
                              DurationUtils.formatDuration(
                                plPlayerController.position,
                              ),
                              style: textStyle,
                            ),
                          ),
                          const Text('/', style: textStyle),
                          ListenableBuilder(
                            listenable: plPlayerController,
                            builder: (context, _) => Text(
                              DurationUtils.formatDuration(
                                plPlayerController.duration,
                              ),
                              style: textStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        /// 音量🔊 控制条展示
        IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: Alignment.center,
            child: ListenableBuilder(
              listenable: plPlayerController,
              builder: (context, _) {
                final volume = plPlayerController.volume;
                return AnimatedOpacity(
                  curve: Curves.easeInOut,
                  opacity: plPlayerController.volumeIndicator ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0x88000000),
                      borderRadius: BorderRadius.all(Radius.circular(64)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          volume == 0.0
                              ? Icons.volume_off
                              : volume < 0.5
                              ? Icons.volume_down
                              : Icons.volume_up,
                          color: Colors.white,
                          size: 20.0,
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          '${(volume * 100.0).round()}%',
                          style: const TextStyle(
                            fontSize: 13.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        /// 亮度🌞 控制条展示
        IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: Alignment.center,
            child: ListenableBuilder(
              listenable: plPlayerController,
              builder: (context, _) => AnimatedOpacity(
                curve: Curves.easeInOut,
                opacity: _brightnessIndicator ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0x88000000),
                    borderRadius: BorderRadius.all(Radius.circular(64)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        _brightnessValue < 1.0 / 3.0
                            ? Icons.brightness_low
                            : _brightnessValue < 2.0 / 3.0
                            ? Icons.brightness_medium
                            : Icons.brightness_high,
                        color: Colors.white,
                        size: 18.0,
                      ),
                      const SizedBox(width: 2.0),
                      Text(
                        '${(_brightnessValue * 100.0).round()}%',
                        style: const TextStyle(
                          fontSize: 13.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 头部、底部控制条
        Positioned.fill(
          top: -1,
          bottom: -1,
          child: ClipRect(
            child: RepaintBoundary(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBarAni(
                    isTop: true,
                    controller: _animationController,
                    isFullScreen: isFullScreen,
                    removeSafeArea: plPlayerController.removeSafeArea,
                    child: plPlayerController.isDesktopPip
                        ? GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanStart: (_) => windowManager.startDragging(),
                            child: widget.headerControl,
                          )
                        : widget.headerControl,
                  ),
                  AppBarAni(
                    isTop: false,
                    controller: _animationController,
                    isFullScreen: isFullScreen,
                    removeSafeArea: plPlayerController.removeSafeArea,
                    child:
                        widget.bottomControl ??
                        BottomControl(
                          maxWidth: maxWidth,
                          isFullScreen: isFullScreen,
                          controller: plPlayerController,
                          overlaySource: overlaySource ?? const _EmptyOverlaySource(),
                          buildBottomControl:
                              widget.buildBottomBar ?? _buildDefaultBottomBar,
                          dmChartBuilder: widget.dmChartBuilder,
                          seekPreview: widget.seekPreview,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),

        ListenableBuilder(
          listenable: plPlayerController,
          builder: (context, _) =>
              showRestoreScaleBtn && plPlayerController.showControls
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 95),
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: colorScheme.secondaryContainer
                            .withValues(alpha: 0.8),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(15),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        showRestoreScaleBtn = false;
                        final animController = AnimationController(
                          vsync: this,
                          duration: const Duration(milliseconds: 255),
                        );
                        final anim = animController.drive(
                          Matrix4Tween(
                            begin: _transformationController.value,
                            end: Matrix4.identity(),
                          ).chain(CurveTween(curve: Curves.easeOut)),
                        );
                        void listener() {
                          _transformationController.value = anim.value;
                        }

                        animController.addListener(listener);
                        await animController.forward(from: 0);
                        animController
                          ..removeListener(listener)
                          ..dispose();
                      },
                      child: const Text('还原屏幕'),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        /// 进度条 live模式下禁用
        if (!isLive)
          Positioned(
            bottom: -2.2,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: plPlayerController,
              builder: (context, _) {
                final showControls = plPlayerController.showControls;
                late final bool offstage;
                switch (widget.progressType ?? BtmProgressBehavior.alwaysShow) {
                  case BtmProgressBehavior.alwaysShow:
                    offstage = showControls;
                  case BtmProgressBehavior.alwaysHide:
                    if (!plPlayerController.isSeeking) {
                      return const SizedBox.shrink();
                    }
                    offstage = showControls;
                  case BtmProgressBehavior.onlyShowFullScreen:
                    offstage =
                        showControls ||
                        (!isFullScreen && !plPlayerController.isSeeking);
                  case BtmProgressBehavior.onlyHideFullScreen:
                    offstage =
                        showControls ||
                        (isFullScreen && !plPlayerController.isSeeking);
                }
                final viewPointsVisible = overlaySource
                            ?.viewPointList
                            .isNotEmpty ==
                        true &&
                    overlaySource?.showVP == true;
                return Offstage(
                  offstage: offstage,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      ListenableBuilder(
                        listenable: plPlayerController,
                        builder: (context, _) => ProgressBar(
                          progress: plPlayerController.position,
                          buffered: plPlayerController.buffered,
                          total: plPlayerController.duration,
                          progressBarColor: primary,
                          baseBarColor: const Color(0x33FFFFFF),
                          bufferedBarColor: bufferedBarColor,
                          thumbColor: primary,
                          thumbGlowColor: thumbGlowColor,
                          barHeight: 3.5,
                          thumbRadius: 2.5,
                        ),
                      ),
                      if (overlaySource?.enableBlock == true &&
                          overlaySource?.segmentProgressList.isNotEmpty == true)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0.75,
                          child: SegmentProgressBar(
                            segments: overlaySource!.segmentProgressList,
                          ),
                        ),
                      if (plPlayerController.showViewPoints &&
                          overlaySource?.viewPointList.isNotEmpty == true &&
                          overlaySource?.showVP == true)
                        Padding(
                          padding: const .only(bottom: 4.25),
                          child: ViewPointSegmentProgressBar(
                            segments: overlaySource!.viewPointList,
                            onSeek: PlatformUtils.isMobile
                                ? (position) {
                                    if (!plPlayerController.controlsLock) {
                                      plPlayerController.seekTo(
                                        position,
                                        isSeek: false,
                                      );
                                    }
                                  }
                                : null,
                          ),
                        ),
                      if (plPlayerController.showDmChart &&
                          overlaySource?.showDmTrendChart == true)
                        if (overlaySource?.dmTrend case final list?)
                          if (widget.dmChartBuilder case final builder?)
                            builder(
                              primary,
                              list,
                              viewPointsVisible: viewPointsVisible,
                            ),
                    ],
                  ),
                );
              },
            ),
          ),

        if (!isLive && widget.seekPreview?.enabled == true)
          widget.seekPreview!.build(
            context,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            isMounted: () => mounted,
          ),

        if (isFullScreen || plPlayerController.isDesktopPip) ...[
          // 锁
          if (plPlayerController.showFsLockBtn)
            ViewSafeArea(
              right: false,
              left: !plPlayerController.removeSafeArea,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionalTranslation(
                  translation: const Offset(1, -0.4),
                  child: ListenableBuilder(
                    listenable: plPlayerController,
                    builder: (context, _) => Offstage(
                      offstage: !plPlayerController.showControls,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0x45000000),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: ListenableBuilder(
                          listenable: plPlayerController,
                          builder: (context, _) {
                          final controlsLock =
                              plPlayerController.controlsLock;
                          return ComBtn(
                            tooltip: controlsLock ? '解锁' : '锁定',
                            icon: controlsLock
                                ? const Icon(
                                    FontAwesomeIcons.lock,
                                    size: 15,
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    FontAwesomeIcons.lockOpen,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                            onTap: () =>
                                plPlayerController.onLockControl(!controlsLock),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 截图
          if (plPlayerController.showFsScreenshotBtn)
            ViewSafeArea(
              left: false,
              right: !plPlayerController.removeSafeArea,
              child: ListenableBuilder(
                listenable: plPlayerController,
                builder: (context, _) => Align(
                  alignment: Alignment.centerRight,
                  child: FractionalTranslation(
                    translation: const Offset(-1, -0.4),
                    child: Offstage(
                      offstage: !plPlayerController.showControls,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0x45000000),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: ComBtn(
                          tooltip: '截图',
                          icon: const Icon(
                            Icons.photo_camera,
                            size: 20,
                            color: Colors.white,
                          ),
                          onLongPress: widget.onScreenshotLongPress == null
                              ? null
                              : (Platform.isAndroid || kDebugMode) && !isLive
                              ? widget.onScreenshotLongPress
                              : null,
                          onTap: widget.onScreenshotTap,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],

        ListenableBuilder(
          listenable: plPlayerController,
          builder: (context, _) {
          if (plPlayerController.dataStatus == DataStatus.loading ||
              (plPlayerController.isBuffering &&
                  plPlayerController.playerStatus.isPlaying)) {
            return Center(
              child: GestureDetector(
                onTap: plPlayerController.refreshPlayer,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.black26, Colors.transparent],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        Assets.buffering,
                        height: 25,
                        cacheHeight: 25.cacheSize(context),
                        semanticLabel: "加载中",
                        color: Colors.white,
                      ),
                      if (plPlayerController.isBuffering)
                        ListenableBuilder(
                          listenable: plPlayerController,
                          builder: (context, _) {
                          final buffered = plPlayerController.buffered;
                          if (buffered == 0) {
                            return const Text(
                              '加载中...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            );
                          }
                          return Text(
                            DurationUtils.formatDuration(buffered),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),

        /// 点击 快进/快退
        if (!isLive)
          ListenableBuilder(
            listenable: plPlayerController,
            builder: (context, _) {
            final mountSeekBackwardButton =
                plPlayerController.mountSeekBackwardButton;
            final mountSeekForwardButton =
                plPlayerController.mountSeekForwardButton;
            return mountSeekBackwardButton || mountSeekForwardButton
                ? Positioned.fill(
                    child: Row(
                      children: [
                        if (mountSeekBackwardButton)
                          Expanded(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: child,
                              ),
                              child: BackwardSeekIndicator(
                                duration:
                                    plPlayerController.fastForBackwardDuration,
                                onSubmitted: (Duration value) {
                                  plPlayerController
                                    ..mountSeekBackwardButton = false
                                    ..onBackward(value);
                                },
                              ),
                            ),
                          ),
                        const Spacer(flex: 2),
                        if (mountSeekForwardButton)
                          Expanded(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: child,
                              ),
                              child: ForwardSeekIndicator(
                                duration:
                                    plPlayerController.fastForBackwardDuration,
                                onSubmitted: (Duration value) {
                                  plPlayerController
                                    ..mountSeekForwardButton = false
                                    ..onForward(value);
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
          }),
      ],
    );
    if (PlatformUtils.isDesktop) {
      return ListenableBuilder(
        listenable: plPlayerController,
        builder: (context, _) => MouseRegion(
          cursor: !plPlayerController.showControls && isFullScreen
              ? SystemMouseCursors.none
              : MouseCursor.defer,
          onEnter: (_) => plPlayerController.controls = true,
          onHover: (_) => plPlayerController.controls = true,
          onExit: (_) => plPlayerController.controls =
              widget.onPointerExitControls?.call() ?? false,
          child: child,
        ),
      );
    }
    return child;
  }

  Widget get _videoWidget {
    return Container(
      clipBehavior: .none,
      width: maxWidth,
      height: maxHeight,
      color: widget.fill,
      child: ListenableBuilder(
        listenable: plPlayerController,
        builder: (context, _) => MouseInteractiveViewer(
          scaleEnabled: !plPlayerController.controlsLock,
          pointerSignalFallback: _onPointerSignal,
          onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
          onPointerPanZoomEnd: _onPointerPanZoomEnd,
          onPointerDown: _onPointerDown,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onScaleUpdate: _onScaleUpdate,
          scaleGestureRecognizer: _scaleGestureRecognizer,
          panEnabled: false,
          minScale: plPlayerController.enableShrinkVideoSize ? 0.75 : 1,
          maxScale: 2.0,
          boundaryMargin: plPlayerController.enableShrinkVideoSize
              ? const .all(double.infinity)
              : .zero,
          panAxis: .aligned,
          transformationController: _transformationController,
          childKey: _videoKey,
          child: RepaintBoundary(
            key: _videoKey,
            child: ListenableBuilder(
              listenable: plPlayerController,
              builder: (context, _) {
                final videoFit = plPlayerController.videoFit;
                return Transform.flip(
                  flipX: plPlayerController.flipX,
                  flipY: plPlayerController.flipY,
                  child: FittedBox(
                    fit: videoFit.boxFit,
                    alignment: widget.alignment,
                    child: SimpleVideo(
                      controller: plPlayerController.videoController!,
                      fill: widget.fill,
                      aspectRatio: videoFit.aspectRatio,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 通用默认底部按钮条：播放/暂停、时间、画面比例、倍速、全屏。
  Widget _buildDefaultBottomBar() {
    final isFullScreen = this.isFullScreen;
    final double widgetWidth = maxWidth > maxHeight && isFullScreen ? 42 : 35;

    return PlayerBar(
      children: [
        Row(
          mainAxisSize: .min,
          children: [
            ComBtn(
              width: widgetWidth,
              height: 30,
              tooltip: '播放/暂停',
              icon: ListenableBuilder(
                listenable: plPlayerController,
                builder: (context, _) => Icon(
                  plPlayerController.playerStatus.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              onTap: plPlayerController.onDoubleTapCenter,
            ),
            ListenableBuilder(
              listenable: plPlayerController,
              builder: (context, _) => VideoTime(
                position: DurationUtils.formatDuration(
                  plPlayerController.position,
                ),
                duration: DurationUtils.formatDuration(
                  plPlayerController.duration,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: .min,
          children: [
            /// 画面比例
            ListenableBuilder(
              listenable: plPlayerController,
              builder: (context, _) {
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
                            onTap: () =>
                                plPlayerController.toggleVideoFit(boxFit),
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

            /// 倍速
            ListenableBuilder(
              listenable: plPlayerController,
              builder: (context, _) => PopupMenuButton<double>(
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
                          onTap: () =>
                              plPlayerController.setPlaybackSpeed(speed),
                          child: Text(
                            "${speed}X",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
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

            /// 全屏
            ComBtn(
              width: widgetWidth,
              height: 30,
              tooltip: isFullScreen ? '退出全屏' : '全屏',
              icon: isFullScreen
                  ? const Icon(
                      Icons.fullscreen_exit,
                      size: 24,
                      color: Colors.white,
                    )
                  : const Icon(Icons.fullscreen, size: 24, color: Colors.white),
              onTap: () =>
                  plPlayerController.triggerFullScreen(status: !isFullScreen),
              onSecondaryTap: () => plPlayerController.triggerFullScreen(
                status: !isFullScreen,
                inAppFullScreen: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 无覆盖层数据时的空实现（通用消费方未注入 [PlayerOverlaySource] 时使用）。
class _EmptyOverlaySource implements PlayerOverlaySource {
  const _EmptyOverlaySource();

  @override
  bool get enableBlock => false;

  @override
  List<Segment> get segmentProgressList => const [];

  @override
  List<ViewPointSegment> get viewPointList => const [];

  @override
  bool get showVP => false;

  @override
  bool get showDmTrendChart => false;

  @override
  List<double>? get dmTrend => null;
}
