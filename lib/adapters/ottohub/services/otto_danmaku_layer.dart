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
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/danmaku_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/setting/slide_color_picker.dart';
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

/// 自发弹幕上屏事件(发送成功后由发送面板投递)。
class OttoDanmakuBus {
  OttoDanmakuBus._();
  static final _controller = StreamController<DanmakuContentItem<int>>.broadcast();
  static Stream<DanmakuContentItem<int>> get stream => _controller.stream;
  static void send(DanmakuContentItem<int> item) => _controller.add(item);
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
      builder: (context, enabled, _) => AnimatedOpacity(
        opacity: enabled ? Pref.danmakuOpacity : 0,
        duration: const Duration(milliseconds: 100),
        child: DanmakuScreen<int>(
          createdController: (e) => _controller = e,
          option: option,
          size: widget.size,
        ),
      ),
    );
  }
}

/// 发送弹幕面板(复原原 SendDanmakuPanel 版式:输入行 + 字号/样式/颜色面板)。
Future<void> showOttoSendDanmakuSheet({
  required int vid,
  required int progress,
  String? initialValue,
  void Function(String?)? onSave,
  ({int? mode, int? fontSize, Color? color})? dmConfig,
  ValueChanged<({int mode, int fontSize, Color color})>? onSaveDmConfig,
}) {
  return SmartDialog.show(
    builder: (context) => _OttoSendDanmakuPanel(
      vid: vid,
      progress: progress,
      initialValue: initialValue,
      onSave: onSave,
      dmConfig: dmConfig,
      onSaveDmConfig: onSaveDmConfig,
    ),
  );
}

class _OttoSendDanmakuPanel extends StatefulWidget {
  const _OttoSendDanmakuPanel({
    required this.vid,
    required this.progress,
    this.initialValue,
    this.onSave,
    this.dmConfig,
    this.onSaveDmConfig,
  });

  final int vid;
  final int progress;
  final String? initialValue;
  final void Function(String?)? onSave;
  final ({int? mode, int? fontSize, Color? color})? dmConfig;
  final ValueChanged<({int mode, int fontSize, Color color})>? onSaveDmConfig;

  @override
  State<_OttoSendDanmakuPanel> createState() => _OttoSendDanmakuPanelState();
}

class _OttoSendDanmakuPanelState extends State<_OttoSendDanmakuPanel> {
  late final int _mode;
  late final int _fontSize;
  late Color _color;
  late bool _panelExpanded = false;
  bool _sending = false;

  final _editController = TextEditingController();
  bool get _enablePublish =>
      !_sending && _editController.text.trim().isNotEmpty;

  final List<Color> _colorList = [
    Colors.white,
    const Color(0xFFFE0302),
    const Color(0xFFFF7204),
    const Color(0xFFFFAA02),
    const Color(0xFFFFD302),
    const Color(0xFFFFFF00),
    const Color(0xFFA0EE00),
    const Color(0xFF00CD00),
    const Color(0xFF019899),
    const Color(0xFF4266BE),
    const Color(0xFF89D5FF),
    const Color(0xFFCC0273),
    const Color(0xFF222222),
    const Color(0xFF9B9B9B),
  ];

  @override
  void initState() {
    super.initState();
    _mode = widget.dmConfig?.mode ?? 1;
    _fontSize = widget.dmConfig?.fontSize ?? 25;
    _color = widget.dmConfig?.color ?? Colors.white;
    _editController.text = widget.initialValue ?? '';
    _editController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    widget.onSave?.call(
      _editController.text.trim().isEmpty ? null : _editController.text.trim(),
    );
    widget.onSaveDmConfig?.call((
      mode: _mode,
      fontSize: _fontSize,
      color: _color,
    ));
    _editController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !_enablePublish) return;
    _sending = true;
    if (mounted) setState(() {});
    final res = await appRead(danmakuRepositoryProvider).shootDanmaku(
      oid: widget.vid,
      bvid: '${widget.vid}',
      progress: widget.progress,
      msg: _editController.text.trim(),
      mode: _mode,
      fontSize: _fontSize,
      color: _color.toARGB32() & 0xFFFFFF,
    );
    _sending = false;
    if (!mounted) return;
    if (res.isSuccess) {
      SmartDialog.dismiss();
      SmartDialog.showToast('发送成功');
      OttoDanmakuBus.send(
        DanmakuContentItem<int>(
          _editController.text.trim(),
          color: _color,
          type: switch (_mode) {
            5 => DanmakuItemType.top,
            4 => DanmakuItemType.bottom,
            _ => DanmakuItemType.scroll,
          },
          selfSend: true,
        ),
      );
    } else {
      res.toast();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return ViewSafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            color: themeData.colorScheme.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputView(themeData),
              if (_panelExpanded) _buildPanel(themeData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputView(ThemeData themeData) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, right: 8),
      child: Row(
        children: [
          iconButton(
            tooltip: '弹幕样式',
            onPressed: () => setState(() => _panelExpanded = !_panelExpanded),
            iconSize: 24,
            icon: const Icon(Icons.text_format),
            iconColor: _panelExpanded
                ? themeData.colorScheme.primary
                : themeData.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _editController,
              autofocus: true,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: '输入弹幕内容',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: themeData.colorScheme.outline,
                ),
              ),
              style: themeData.textTheme.bodyLarge,
            ),
          ),
          _enablePublish
              ? iconButton(
                  iconSize: 22,
                  iconColor: themeData.colorScheme.onSurfaceVariant,
                  onPressed: _editController.clear,
                  icon: const Icon(Icons.clear),
                )
              : const SizedBox.shrink(),
          const SizedBox(width: 12),
          iconButton(
            tooltip: '发送',
            iconSize: 22,
            iconColor: _enablePublish
                ? themeData.colorScheme.primary
                : themeData.colorScheme.outline,
            onPressed: _send,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(ThemeData themeData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: themeData.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: ListView(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        padding: .only(
          top: 12,
          bottom: 12 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          Row(
            children: [
              Text(
                '弹幕字号',
                style: TextStyle(
                  fontSize: 15,
                  color: themeData.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              _buildFontSizeItem(themeData, 18, '小'),
              const SizedBox(width: 5),
              _buildFontSizeItem(themeData, 25, '标准'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '弹幕样式',
                style: TextStyle(
                  fontSize: 15,
                  color: themeData.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              _buildPositionItem(themeData, 1, '滚动'),
              const SizedBox(width: 5),
              _buildPositionItem(themeData, 5, '顶部'),
              const SizedBox(width: 5),
              _buildPositionItem(themeData, 4, '底部'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '弹幕颜色',
                style: TextStyle(
                  fontSize: 15,
                  color: themeData.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              _buildColorPanel(themeData),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPanel(ThemeData themeData) {
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 42,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _colorList.length + 1,
        itemBuilder: (context, index) {
          if (index == _colorList.length) {
            return GestureDetector(
              onTap: () => _showColorPicker(themeData),
              child: Container(
                decoration: BoxDecoration(
                  color: themeData.colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                alignment: Alignment.center,
                margin: const EdgeInsets.all(2),
                child: Icon(
                  size: 22,
                  Icons.edit,
                  color: themeData.colorScheme.onSecondaryContainer,
                ),
              ),
            );
          }
          return _buildColorItem(themeData, _colorList[index]);
        },
      ),
    );
  }

  Widget _buildColorItem(ThemeData themeData, Color color) {
    return GestureDetector(
      onTap: () => setState(() => _color = color),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: _color != color
              ? null
              : Border.all(width: 2, color: themeData.colorScheme.primary),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildPositionItem(ThemeData themeData, int mode, String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _mode == mode
                ? themeData.colorScheme.secondaryContainer
                : themeData.colorScheme.onInverseSurface,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            title,
            style: TextStyle(
              color: _mode == mode
                  ? themeData.colorScheme.onSecondaryContainer
                  : themeData.colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeItem(ThemeData themeData, int fontSize, String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _fontSize = fontSize),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _fontSize == fontSize
                ? themeData.colorScheme.secondaryContainer
                : themeData.colorScheme.onInverseSurface,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            title,
            style: TextStyle(
              color: _fontSize == fontSize
                  ? themeData.colorScheme.onSecondaryContainer
                  : themeData.colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(ThemeData themeData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        title: const Text('Color Picker'),
        content: SlideColorPicker(
          color: _color,
          onChanged: (Color? color) {
            if (color != null) {
              _color = color;
            }
          },
        ),
      ),
    );
  }
}
