// OttoHub 发送弹幕面板。
//
// 复原原 SendDanmakuPanel(bb7d917 快照)版式:经 [PublishRoute] 底部滑入,
// 输入行(100 字限制/清空/发送)+ 弹幕样式面板(字号 小/标准、样式
// 滚动/顶部/底部、14 色色板 + 自定义取色器),键盘经 chat_bottom_container
// 附着于面板容器。OttoHub 无 VIP 彩色弹幕,不提供透明色。
// 发送成功后经 [OttoDanmakuBus] 即时上屏。

import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:skf/adapters/ottohub/services/otto_danmaku_bus.dart';
import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/publish/common_text_pub_page.dart';
import 'package:skf/pages/common/publish/publish_panel_type.dart';
import 'package:skf/pages/common/publish/publish_route.dart';
import 'package:skf/pages/setting/slide_color_picker.dart';
import 'package:skf/router/app_navigator.dart';

/// 弹出发送弹幕面板(底部滑入)。
Future<void> showOttoSendDanmakuSheet({
  required int vid,
  required int progress,
  String? initialValue,
  void Function(String?)? onSave,
  ({int? mode, int? fontSize, Color? color})? dmConfig,
  ValueChanged<({int mode, int fontSize, Color color})>? onSaveDmConfig,
}) async {
  await AppNavigator.push(
    PublishRoute(
      pageBuilder: (buildContext, animation, secondaryAnimation) =>
          OttoSendDanmakuPanel(
        vid: vid,
        progress: progress,
        initialValue: initialValue,
        onSave: onSave,
        dmConfig: dmConfig,
        onSaveDmConfig: onSaveDmConfig,
      ),
    ),
  );
}

class OttoSendDanmakuPanel extends CommonTextPubPage {
  /// OttoHub 视频 ID(弹幕按视频维度)。
  final int vid;
  final int progress;

  final ({int? mode, int? fontSize, Color? color})? dmConfig;
  final ValueChanged<({int mode, int fontSize, Color color})>? onSaveDmConfig;

  const OttoSendDanmakuPanel({
    super.key,
    super.initialValue,
    super.onSave,
    required this.vid,
    required this.progress,
    this.dmConfig,
    this.onSaveDmConfig,
  });

  @override
  State<OttoSendDanmakuPanel> createState() => _OttoSendDanmakuPanelState();
}

class _OttoSendDanmakuPanelState
    extends CommonTextPubPageState<OttoSendDanmakuPanel> {
  late final int _mode;
  late final int _fontSize;
  late Color _color;

  late ThemeData themeData;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeData = Theme.of(context);
  }

  @override
  void dispose() {
    widget.onSaveDmConfig?.call((
      mode: _mode,
      fontSize: _fontSize,
      color: _color,
    ));
    super.dispose();
  }

  @override
  void onSave() {
    widget.onSave?.call(editController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return ViewSafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            color: themeData.colorScheme.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputView(),
              buildPanelContainer(themeData, Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget? get customPanel => Container(
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
            _buildFontSizeItem(18, '小'),
            const SizedBox(width: 5),
            _buildFontSizeItem(25, '标准'),
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
            _buildPositionItem(1, '滚动'),
            const SizedBox(width: 5),
            _buildPositionItem(5, '顶部'),
            const SizedBox(width: 5),
            _buildPositionItem(4, '底部'),
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
            _buildColorPanel,
          ],
        ),
      ],
    ),
  );

  Widget get _buildColorPanel => Expanded(
    child: ListenableBuilder(
      listenable: this,
      builder: (context, _) => GridView.builder(
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
              onTap: _showColorPicker,
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
          return _buildColorItem(_colorList[index]);
        },
      ),
    ),
  );

  Widget _buildColorItem(Color color) {
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

  Widget _buildPositionItem(int mode, String title) {
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

  Widget _buildFontSizeItem(int fontSize, String title) {
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

  Widget _buildInputView() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, right: 8),
      child: Row(
        children: [
          iconButton(
            tooltip: '弹幕样式',
            onPressed: () {
              updatePanelType(
                panelType == PanelType.emoji
                    ? PanelType.keyboard
                    : PanelType.emoji,
              );
            },
            iconSize: 24,
            icon: const Icon(Icons.text_format),
            iconColor: panelType == PanelType.emoji
                ? themeData.colorScheme.primary
                : themeData.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Listener(
              onPointerUp: (event) {
                if (readOnly) {
                  updatePanelType(PanelType.keyboard);
                }
              },
              child: ListenableBuilder(
                listenable: this,
                builder: (context, _) => TextField(
                  controller: editController,
                  autofocus: false,
                  readOnly: readOnly,
                  inputFormatters: [LengthLimitingTextInputFormatter(100)],
                  onChanged: onChanged,
                  textInputAction: TextInputAction.send,
                  onSubmitted: onSubmitted,
                  focusNode: focusNode,
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
            ),
          ),
          ListenableBuilder(
            listenable: this,
            builder: (context, _) => enablePublish
                ? iconButton(
                    iconSize: 22,
                    iconColor: themeData.colorScheme.onSurfaceVariant,
                    onPressed: () {
                      editController.clear();
                      enablePublish = false;
                    },
                    icon: const Icon(Icons.clear),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 12),
          ListenableBuilder(
            listenable: this,
            builder: (context, _) => iconButton(
              tooltip: '发送',
              iconSize: 22,
              iconColor: enablePublish
                  ? themeData.colorScheme.primary
                  : themeData.colorScheme.outline,
              onPressed: enablePublish ? onPublishThrottle : null,
              icon: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
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

  @override
  Future<void> onCustomPublish({List? pictures}) async {
    SmartDialog.showLoading(msg: '发送中...');
    final res = await appRead(danmakuRepositoryProvider).shootDanmaku(
      oid: widget.vid,
      bvid: '${widget.vid}',
      progress: widget.progress,
      msg: editController.text.trim(),
      mode: _mode,
      fontSize: _fontSize,
      color: _color.toARGB32() & 0xFFFFFF,
    );
    SmartDialog.dismiss();
    if (res case Success()) {
      hasPub = true;
      AppNavigator.back();
      SmartDialog.showToast('发送成功');
      OttoDanmakuBus.send(
        DanmakuContentItem<int>(
          editController.text.trim(),
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
    }
  }
}
