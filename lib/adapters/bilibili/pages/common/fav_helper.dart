import 'package:skf/adapters/bilibili/models/common/fav_type.dart';
import 'package:skf/adapters/bilibili/pages/fav/article/view.dart';
import 'package:skf/adapters/bilibili/pages/fav/cheese/view.dart';
import 'package:skf/adapters/bilibili/pages/fav/note/view.dart';
import 'package:skf/adapters/bilibili/pages/fav/pgc/view.dart';
import 'package:skf/adapters/bilibili/pages/fav/topic/view.dart';
import 'package:skf/adapters/bilibili/pages/fav/video/view.dart';
import 'package:flutter/material.dart';

Widget favPageFor(FavTabType type) => switch (type) {
  FavTabType.video => const FavVideoPage(),
  FavTabType.bangumi => const FavPgcPage(type: 1),
  FavTabType.cinema => const FavPgcPage(type: 2),
  FavTabType.article => const FavArticlePage(),
  FavTabType.note => const FavNotePage(),
  FavTabType.topic => const FavTopicPage(),
  FavTabType.cheese => const FavCheesePage(),
};
