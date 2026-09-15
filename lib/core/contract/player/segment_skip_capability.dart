// 片段跳过能力(SponsorBlock 类服务):识别并自动跳过赞助/片头片尾片段。
//
// 页面以 `host.segmentSkip` 取用;null = 当前适配器不支持,相关 UI 隐藏。

import 'package:flutter/animation.dart' show Animation;
import 'package:flutter/widgets.dart'
    show AnimatedListState, BuildContext, GlobalKey, VoidCallback, Widget;

import 'package:skf/common/widgets/progress_bar/segment_progress_bar.dart'
    show Segment;
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/pages/video/video_models.dart';

/// 片段跳过引擎(页面级状态,由适配器实现)。
abstract class SegmentSkipEngine {
  /// 片段进度条列表。
  List<Segment> get segmentProgressList;

  /// 跳过提示列表 key。
  GlobalKey<AnimatedListState> get listKey;

  /// 跳过提示列表数据(SegmentModel 或分P索引)。
  List<Object> get listData;

  /// 是否启用片段跳过逻辑。
  bool get isBlock;

  /// 片段跳过总开关(赞助 + 片头片尾)。
  bool get enableBlock;

  /// 初始化位置监听(播放到片段自动跳过)。
  void initSkip();

  /// 重置片段状态。
  void resetBlock();

  /// 处理片段数据。
  void handleSBData(List<CoreSegmentItemModel> list);

  /// 查询赞助片段。
  Future<void> querySponsorBlock({required String bvid, required int cid});

  /// 添加跳过提示项。
  void onAddItem(Object item);

  /// 移除跳过提示项。
  void onRemoveItem(int index, Object item);

  /// 执行跳过。
  Future<void>? onSkip(Object item, {bool isSeek = true});

  /// 首个待跳片段起点。
  Duration? getFirstSegment([int pos = 0]);

  /// 构建跳过提示项。
  Widget buildItem(Object item, Animation<double> animation);

  /// 取消片段位置监听。
  void cancelBlockListener();

  /// 赞助片段详情弹层。
  void showSBDetail();

  /// 释放监听与定时器。
  void dispose();
}

/// 片段跳过能力宿主。
abstract class SegmentSkipCapability {
  /// 本适配器是否支持片段跳过。
  bool get supported;

  /// 片段跳过总开关(赞助 + 片头片尾)。
  bool get enableBlock;

  /// 赞助片段开关。
  bool get enableSponsorBlock;

  /// 创建页面级片段跳过引擎。
  SegmentSkipEngine createEngine(dynamic videoDetailController);

  /// 片段标记弹层。
  void onBlock(BuildContext context, String heroTag);

  /// 赞助片段详情。
  void showSBDetail(String heroTag);
}

/// 兼容别名:历史代码将引擎类型称为 [VideoBlock]。
typedef VideoBlock = SegmentSkipEngine;
