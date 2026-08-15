import 'package:skf/pages/fav/article/view.dart';
import 'package:skf/pages/fav/cheese/view.dart';
import 'package:skf/pages/fav/fav_actions.dart';
import 'package:skf/pages/fav/note/view.dart';
import 'package:skf/pages/fav/pgc/view.dart';
import 'package:skf/pages/fav/topic/view.dart';
import 'package:skf/pages/fav/video/view.dart';
import 'package:flutter/widgets.dart';
/// 收藏页 Tab 枚举（迁移自 adapter models/common/fav_type.dart）。
enum FavTabType {
  video('视频'),
  bangumi('追番'),
  cinema('追剧'),
  article('专栏'),
  note('笔记'),
  topic('话题'),
  cheese('课堂'),
  ;

  final String title;

  const FavTabType(this.title);
}

/// Tab → 页面构造（迁移自 adapter pages/common/fav_helper.dart）。
Widget favPageFor(FavTabType type, {FavActions? actions}) => switch (type) {
  FavTabType.video => FavVideoPage(actions: actions),
  FavTabType.bangumi => FavPgcPage(type: 1, actions: actions),
  FavTabType.cinema => FavPgcPage(type: 2, actions: actions),
  FavTabType.article => const FavArticlePage(),
  FavTabType.note => FavNotePage(actions: actions),
  FavTabType.topic => const FavTopicPage(),
  FavTabType.cheese => FavCheesePage(actions: actions),
};
