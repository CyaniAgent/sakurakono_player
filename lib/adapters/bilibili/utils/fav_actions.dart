import 'package:skf/adapters/bilibili/common/widgets/image/image_save.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/adapters/bilibili/pages/fav_folder_sort/view.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/pages/fav/fav_actions.dart';

/// 收藏域导航契约的 B站 实现（bridge `/fav` 路由注入）。
final FavActions biliFavActions = FavActions(
  onViewPgc: (seasonId) => PageUtils.viewPgc(seasonId: seasonId),
  onViewPugv: (seasonId) => PageUtils.viewPugv(seasonId: seasonId),
  onHandleWebview: (url) => PageUtils.handleWebview(url, inApp: true),
  onSaveImage: (title, cover) => imageSaveDialog(title: title, cover: cover),
  onOpenFolderSort: (ctr) => AppNavigator.to(FavFolderSortPage(favController: ctr)),
);
