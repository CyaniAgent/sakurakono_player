import 'package:skf/common/widgets/progress_bar/segment_progress_bar.dart';
import 'package:get/get.dart';

/// 播放器进度条覆盖层数据源。
///
/// 分段（SponsorBlock）、分段信息（ViewPoint）、高能进度条（弹幕趋势）等
/// 播放器专属数据通过该接口注入通用外壳，避免 lib/player/ 依赖适配器。
/// B站 侧由 [VideoDetailController] 适配实现。
abstract class PlayerOverlaySource {
  /// 是否启用分段显示（B站: `plPlayerController.enableBlock`）。
  bool get enableBlock;

  /// 分段列表（B站: sponsor block segments）。
  List<Segment> get segmentProgressList;

  /// 分段信息（分P 段落）列表。
  List<ViewPointSegment> get viewPointList;

  /// 分段信息显示开关（B站: `showVP`）。
  RxBool get showVP;

  /// 高能进度条显示开关（B站: `showDmTrendChart`）。
  bool get showDmTrendChart;

  /// 高能进度条数据（B站: `dmTrend`，已解包为数据或 null）。
  List<double>? get dmTrend;
}
