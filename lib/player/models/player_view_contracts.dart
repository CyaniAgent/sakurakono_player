import 'package:flutter/widgets.dart';

/// 高能进度条（弹幕趋势图）构建器，由适配器注入（B站: fl_chart 折线图）。
typedef PlayerDmChartBuilder = Widget Function(
  Color primary,
  List<double> dmTrend, {
  double offset,
  bool viewPointsVisible,
});

/// 弹幕点按交互注入（B站: 点按弹幕 → 点赞/复制/删除/举报 动作浮层）。
///
/// 通用外壳只负责手势分发与浮层挂载，弹幕命中检测与动作内容由宿主实现。
abstract class PlayerDmTapInteraction {
  /// 是否启用（B站: `enableTapDm`）。
  bool get enabled;

  /// 弹幕当前是否可见（B站: `enableShowDanmaku.value`）。
  bool get visible;

  /// 弹幕可见性变化流（B站: `enableShowDanmaku.stream`）。
  Stream<bool> get visibilityChanges;

  /// 点按命中检测；返回是否命中弹幕并挂起（展示动作浮层）。
  void handleTapDown(TapDownDetails details);

  /// 点按抬起：处理挂起弹幕的偏移更新。返回 true 表示事件被消费
  /// （不触发控制栏切换）。
  bool handleTapUp(TapUpDetails details);

  /// 取消挂起弹幕并隐藏动作浮层。
  void cancel();

  /// 构建动作浮层（作为播放器 Stack 子级，宿主自行包裹 Obx）。
  Widget buildOverlay(BuildContext context);
}

/// 拖动预览注入（B站: video shot 截图精灵图）。
abstract class PlayerSeekPreview {
  /// 是否启用（B站: `showSeekPreview`）。
  bool get enabled;

  /// 拖动进度时更新预览索引。
  void updateIndex(int seconds);

  /// 隐藏预览（取消进退提示时调用）。
  void hide();

  /// 构建预览浮层（播放器 Stack 子级）。
  Widget build(
    BuildContext context, {
    required double maxWidth,
    required double maxHeight,
    required ValueGetter<bool> isMounted,
  });
}
