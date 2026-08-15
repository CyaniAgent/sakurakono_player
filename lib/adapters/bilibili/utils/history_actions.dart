import 'package:skf/pages/history/history_actions.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';

/// B站 适配器为通用历史页面注入的导航契约（见 lib/pages/history/）。
///
/// 视频/PGC 打开依赖适配器侧的路由参数（videoType、pgcInfo 解析），因此
/// 由 bridge 通过 HistoryPage(actions:) 注入。
final HistoryActions biliHistoryActions = HistoryActions(
  onViewVideo: ({
    aid,
    bvid,
    required cid,
    cover,
    title,
    dimension,
  }) =>
      PageUtils.toVideoPage(
        aid: aid,
        bvid: bvid,
        cid: cid,
        cover: cover,
        title: title,
        dimension: ModelConverters.dimension(dimension),
      ),
  onViewPgc: (epId) => PageUtils.viewPgc(epId: epId),
  onViewPgcFromUri: PageUtils.viewPgcFromUri,
);
