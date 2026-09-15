// 互动视频能力:分支选项查询与判定。

/// 互动视频能力宿主。
abstract class InteractiveCapability {
  /// 本适配器是否支持互动视频。
  bool get supported;

  /// 互动视频选项查询;返回是否包含选项。
  Future<bool> getSteinEdgeInfo({
    required String heroTag,
    required String bvid,
    required int? graphVersion,
    int? edgeId,
  });

  /// 是否为互动视频。
  bool isSteinGate(String heroTag);
}
