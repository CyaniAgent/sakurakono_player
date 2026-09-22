// OttoHub 播放器弹幕层。
//
// 复原自原 B站 适配器 PlDanmaku(bb7d917 快照):监听播放进度,按 0.1s
// 分桶投递到 canvas_danmaku 的 DanmakuScreen。与原版的差异:OttoHub
// 的 /danmaku/{vid} 一次返回全部弹幕(无 6 分钟分段),无特殊弹幕、
// 无重量过滤、无自我弹幕识别(发送成功后经 OttoDanmakuBus 直接上屏)。
// 开关经 [OttoDanmakuToggle] 全局通知(播放器 tab 栏与设置面板共用)。

import 'dart:async';

import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import 'package:skf/adapters/ottohub/services/otto_danmaku_bus.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/danmaku_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/player/models/play_status.dart';
import 'package:skf/player/player_controller.dart';
import 'package:skf/player/utils/danmaku_options.dart';
import 'package:skf/utils/danmaku_utils.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';

/// 弹幕显示开关(全局)。
class OttoDanmakuToggle extends ChangeNotifier {
  OttoDanmakuToggle._();
  static final OttoDanmakuToggle instance = OttoDanmakuToggle._();

  static final ValueNotifier<bool> _enabled = ValueNotifier(
    Pref.enableShowDanmaku,
  );

  ValueListenable<bool> get listenable => _enabled;
  static ValueListenable<bool> get enabledListenable => _enabled;
  bool get enabled => _enabled.value;

  void toggle() {
    _enabled.value = !_enabled.value;
    GStorage.setting.put(SettingBoxKey.enableShowDanmaku, _enabled.value);
    notifyListeners();
  }
}

/// 传入播放器控制器,监听播放进度,投递对应时间点的弹幕。
class OttoPlDanmaku extends StatefulWidget {
  const OttoPlDanmaku({
    super.key,
    required this.vid,
    required this.playerController,
    required this.isFullScreen,
    required this.size,
  });

  /// OttoHub 视频 ID。
  final int vid;
  final PlayerController playerController;
  final bool isFullScreen;
  final Size size;

  @override
  State<OttoPlDanmaku> createState() => _OttoPlDanmakuState();

  bool get notFullscreen => !isFullScreen;
}

class _OttoPlDanmakuState extends State<OttoPlDanmaku> {
  PlayerController get playerController => widget.playerController;

  DanmakuController<int>? _controller;
  final Map<int, List<CoreDanmakuElement>> _dmSegMap = {};
  bool _loaded = false;
  int latestAddedPosition = -1;
  StreamSubscription<DanmakuContentItem<int>>? _busSub;

  @override
  void initState() {
    super.initState();
    _queryDanmaku();
    playerController
      ..addStatusLister(playerListener)
      ..addPositionListener(videoPositionListen);
    _busSub = OttoDanmakuBus.stream.listen(_onSelfSent);
  }

  Future<void> _queryDanmaku() async {
    final res = await appRead(
      danmakuRepositoryProvider,
    ).dmSegMobile(cid: widget.vid, segmentIndex: 1);
    if (!mounted) return;
    if (res case Success(:final response)) {
      _handleDanmaku(response.elems);
      _loaded = true;
    }
  }

  void _handleDanmaku(List<CoreDanmakuElement> elems) {
    for (final element in elems) {
      final progress = element.progress ?? 0;
      final int pos = progress ~/ 100; //每0.1秒存储一次
      (_dmSegMap[pos] ??= []).add(element);
    }
  }

  // 播放器状态监听
  void playerListener(PlayerStatus status) {
    if (_controller case final controller?) {
      if (status.isPlaying) {
        controller.resume();
      } else {
        controller.pause();
      }
    }
  }

  void videoPositionListen(Duration position) {
    if (_controller == null || !OttoDanmakuToggle.instance.enabled) {
      return;
    }
    if (!playerController.playerStatus.isPlaying) {
      return;
    }

    int currentPosition = position.inMilliseconds;
    currentPosition -= currentPosition % 100; //取整百的毫秒数
    if (currentPosition == latestAddedPosition) {
      return;
    }
    latestAddedPosition = currentPosition;

    if (!_loaded) {
      return;
    }
    final currentDanmakuList = _dmSegMap[currentPosition ~/ 100];
    if (currentDanmakuList != null) {
      final blockColorful = DanmakuOptions.blockColorful;
      for (final e in currentDanmakuList) {
        _controller!.addDanmaku(
          DanmakuContentItem<int>(
            e.content ?? '',
            color: blockColorful
                ? Colors.white
                : DmUtils.decimalToColor(e.color ?? 0xFFFFFF),
            type: DmUtils.getPosition(e.mode ?? 1),
            extra: e.id ?? 0,
          ),
        );
      }
    }
  }

  void _onSelfSent(DanmakuContentItem<int> item) {
    _controller?.addDanmaku(item);
  }

  @override
  void didUpdateWidget(OttoPlDanmaku oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notFullscreen != widget.notFullscreen &&
        !DanmakuOptions.sameFontScale) {
      _controller?.updateOption(
        DanmakuOptions.get(notFullscreen: widget.notFullscreen),
      );
    }
  }

  @override
  void dispose() {
    playerController
      ..removePositionListener(videoPositionListen)
      ..removeStatusLister(playerListener);
    _busSub?.cancel();
    _dmSegMap.clear();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final option = DanmakuOptions.get(
      notFullscreen: widget.notFullscreen,
      speed: playerController.playbackSpeed,
    );
    return ValueListenableBuilder<bool>(
      valueListenable: OttoDanmakuToggle.enabledListenable,
      builder: (context, enabled, _) => ExcludeSemantics(
        // 弹幕幕布产生数百个语义节点且零无障碍价值,排除以避免
        // semantics 树在面板开合/路由退出时的断言与崩溃(object.dart
        // 'node.built'/'parentDataDirty')。
        excluding: true,
        child: AnimatedOpacity(
          opacity: enabled ? Pref.danmakuOpacity : 0,
          duration: const Duration(milliseconds: 100),
            child: DanmakuScreen<int>(
              createdController: (e) => _controller = e,
              option: option,
              size: widget.size,
            ),
        ),
      ),
    );
  }
}

