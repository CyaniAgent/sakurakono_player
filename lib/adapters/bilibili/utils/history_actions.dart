import 'package:skf/pages/history/history_actions.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
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
        // 旧历史记录可能无 bvid：回退由 aid 生成（lib/pages/ 禁止 adapter import，故在 actions 层处理）。
        bvid: bvid ?? (aid != null ? IdUtils.av2bv(aid) : null),
        cid: cid,
        cover: cover,
        title: title,
        dimension: ModelConverters.dimension(dimension),
      ),
  onViewPgc: (epId) => PageUtils.viewPgc(epId: epId),
  onViewPgcFromUri: PageUtils.viewPgcFromUri,
);
