// 弹幕设置面板(播放器头部弹幕设置按钮弹出;移植自原 header_mixin 弹幕段)。
//
// 参数:字号缩放/描边/透明度/显示区域/滚动速度/类型屏蔽。改动即写
// DanmakuOptions 静态字段 → save() 持久化 → OttoDanmakuToggle
// .notifyStyleChanged() 通知弹幕层 updateOption 即时生效。

import 'package:flutter/material.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/adapters/ottohub/services/otto_danmaku_layer.dart';
import 'package:skf/player/utils/danmaku_options.dart';
import 'package:skf/utils/extension/num_ext.dart';
import 'package:skf/utils/storage_pref.dart';

/// 屏蔽类型位定义(与 DanmakuOptions.blockTypes 对应)。
enum DanmakuBlockType {
  scroll(2, '滚动'),
  bottom(4, '底部'),
  top(5, '顶部'),
  colorful(6, '彩色'),
  special(7, '高级');

  const DanmakuBlockType(this.bit, this.label);
  final int bit;
  final String label;
}

class DanmakuSettingsSheet extends StatefulWidget {
  const DanmakuSettingsSheet({super.key, required this.notFullscreen});

  final bool notFullscreen;

  @override
  State<DanmakuSettingsSheet> createState() => _DanmakuSettingsSheetState();
}

class _DanmakuSettingsSheetState extends State<DanmakuSettingsSheet> {
  late double _fontScale = widget.notFullscreen
      ? DanmakuOptions.danmakuFontScale
      : DanmakuOptions.danmakuFontScaleFS;
  late double _opacity = Pref.danmakuOpacity;
  late double _showArea = DanmakuOptions.danmakuShowArea;
  late double _strokeWidth = DanmakuOptions.danmakuStrokeWidth;
  late double _duration = DanmakuOptions.danmakuDuration;

  /// 应用并持久化(透明度直接写 Pref;其余走 DanmakuOptions.save)。
  void _apply() {
    if (widget.notFullscreen) {
      DanmakuOptions.danmakuFontScale = _fontScale;
    } else {
      DanmakuOptions.danmakuFontScaleFS = _fontScale;
    }
    DanmakuOptions.danmakuShowArea = _showArea;
    DanmakuOptions.danmakuStrokeWidth = _strokeWidth;
    DanmakuOptions.danmakuDuration = _duration;
    Pref.danmakuOpacity = _opacity;
    DanmakuOptions.save(_opacity);
    // 通知弹幕层 updateOption + 重建透明度。
    OttoDanmakuToggle.instance.notifyStyleChanged();
  }

  @override
  Widget build(BuildContext context) {
    return ViewSafeArea(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _slider(
                    label: '字号',
                    value: _fontScale,
                    min: 0.5,
                    max: 3.0,
                    display: '${_fontScale.toStringAsFixed(1)}x',
                    onChanged: (v) => setState(() {
                      _fontScale = v.toPrecision(1);
                      _apply();
                    }),
                  ),
                  _slider(
                    label: '不透明度',
                    value: _opacity,
                    min: 0.1,
                    max: 1.0,
                    display: '${(_opacity * 100).round()}%',
                    onChanged: (v) => setState(() {
                      _opacity = v.toPrecision(1);
                      _apply();
                    }),
                  ),
                  _slider(
                    label: '显示区域',
                    value: _showArea,
                    min: 0.1,
                    max: 1.0,
                    display: '${(_showArea * 100).round()}%',
                    onChanged: (v) => setState(() {
                      _showArea = v.toPrecision(1);
                      _apply();
                    }),
                  ),
                  _slider(
                    label: '描边',
                    value: _strokeWidth,
                    min: 0.0,
                    max: 4.0,
                    display: _strokeWidth.toStringAsFixed(1),
                    onChanged: (v) => setState(() {
                      _strokeWidth = v.toPrecision(1);
                      _apply();
                    }),
                  ),
                  _slider(
                    label: '滚动速度',
                    value: _duration,
                    min: 4.0,
                    max: 20.0,
                    display: '${_duration.toStringAsFixed(1)}s',
                    onChanged: (v) => setState(() {
                      _duration = v.toPrecision(1);
                      _apply();
                    }),
                  ),
                  const SizedBox(height: 8),
                  // 类型屏蔽。
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: DanmakuBlockType.values.map((t) {
                      final blocked = DanmakuOptions.blockTypes.contains(
                        t.bit,
                      );
                      return FilterChip(
                        label: Text(t.label),
                        selected: blocked,
                        showCheckmark: false,
                        onSelected: (selected) => setState(() {
                          selected
                              ? DanmakuOptions.blockTypes.add(t.bit)
                              : DanmakuOptions.blockTypes.remove(t.bit);
                          DanmakuOptions.blockColorful = DanmakuOptions
                              .blockTypes
                              .contains(DanmakuBlockType.colorful.bit);
                          _apply();
                        }),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String display,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 76, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            label: display,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}


