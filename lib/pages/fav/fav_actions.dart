import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/fav/video/controller.dart';

/// 收藏域导航/动作契约。
///
/// 收藏域页面自身零 bilibili 依赖;需要适配器能力(播放 PGC/PUGV、
/// 应用内打开网页、保存封面图、打开收藏夹排序页)的动作由适配器注入。
/// 成员为 null 表示该能力缺失,页面隐藏对应入口(能力降级)。
class FavActions {
  const FavActions({
    this.onViewPgc,
    this.onViewPugv,
    this.onHandleWebview,
    this.onSaveImage,
    this.onOpenFolderSort,
    this.onCreateFolder,
    this.onFavSearch,
  });

  /// 打开 PGC(追番/追剧)。
  final void Function(int? seasonId)? onViewPgc;

  /// 打开课堂 PUGV。
  final void Function(int? seasonId)? onViewPugv;

  /// 应用内打开网页。
  final void Function(String url)? onHandleWebview;

  /// 保存封面图(长按视频/课堂条目)。
  final void Function(String? title, String? cover)? onSaveImage;

  /// 打开收藏夹排序页。
  final void Function(FavController ctr)? onOpenFolderSort;

  /// 新建收藏夹,返回新建的收藏夹信息(插入列表头部)。
  final Future<CoreFavFolderInfo?>? Function()? onCreateFolder;

  /// 搜索收藏内容。
  final void Function(CoreFavFolderInfo folder)? onFavSearch;
}
