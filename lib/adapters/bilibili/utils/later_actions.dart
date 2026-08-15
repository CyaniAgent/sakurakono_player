import 'package:skf/adapters/bilibili/models/common/video/source_type.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/adapters/bilibili/utils/request_utils.dart';
import 'package:skf/core/models/user_types.dart' show CoreLaterItemModel;
import 'package:skf/pages/later/later_actions.dart';

/// B站 适配器为通用稍后再看页面注入的导航契约（见 lib/pages/later/）。
///
/// 视频/PGC/PUGV 打开依赖适配器侧的路由参数（videoType、sourceType、
/// pgcInfo 解析），因此由 bridge 通过 LaterPage(actions:) 注入。
final LaterActions biliLaterActions = LaterActions(
  onViewVideo: (request) => PageUtils.toVideoPage(
    aid: request.aid,
    bvid: request.bvid,
    cid: request.cid!,
    cover: request.cover,
    title: request.title,
    dimension: ModelConverters.dimensionUser(request.dimension),
    extraArguments: request.isWatchLaterPlaylist
        ? {
            'sourceType': SourceType.watchLater,
            ...?request.watchLaterExtra,
          }
        : null,
  ),
  onViewPugv: (seasonId) => PageUtils.viewPugv(seasonId: seasonId),
  onViewPgc: (epId) => PageUtils.viewPgc(epId: epId),
  onViewPgcFromUri: PageUtils.viewPgcFromUri,
  onCopyOrMove: (context, ctr, isCopy, mid) =>
      RequestUtils.onCopyOrMove<CoreLaterItemModel>(
        context: context,
        isCopy: isCopy,
        ctr: ctr,
        mediaId: null,
        mid: mid,
      ),
);
