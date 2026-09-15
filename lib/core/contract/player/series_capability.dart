// 系列/剧集能力:番剧、Season/合集详情等"成系列"内容的简介与选集。
//
// 页面以 `host.series` 取用;null = 不支持,系列入口与面板隐藏。

import 'package:flutter/widgets.dart' show Key, Widget;

/// 系列/剧集能力宿主。
abstract class SeriesCapability {
  /// 本适配器是否支持系列内容。
  bool get supported;

  /// 系列简介页(内部接线选集/详情)。
  Widget buildSeriesIntroPage({
    required Key key,
    required String heroTag,
    required int cid,
    required double maxWidth,
    required bool isLandscape,
  });

  /// 播放列表 tab 面板(PagesPanel/SeasonPanel/EpisodePanel 装配)。
  Widget buildSeasonPanel({required String heroTag});

  /// 番剧片头片尾跳过开关。
  bool get enablePgcSkip;

  /// 是否显示播放列表 tab(多 P/合集)。
  bool shouldShowSeasonPanel(String heroTag, {required bool isPortrait});

  /// 应用片头/片尾跳过数据(clipInfoList → 片段跳过引擎)。
  void applyClipInfo(String heroTag, List<Map<String, dynamic>>? clipInfoList);
}
