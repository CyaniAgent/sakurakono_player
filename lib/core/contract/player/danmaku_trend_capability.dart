// 高能进度能力:按时间维度的热度曲线数据。

import 'package:skf/core/result/loading_state.dart';

/// 高能进度能力宿主。
abstract class DanmakuTrendCapability {
  /// 本适配器是否支持高能进度。
  bool get supported;

  /// 高能热度数据(与播放时长等长)。
  Future<LoadingState<List<double>>> fetchTrend({
    required String bvid,
    required int cid,
  });
}
