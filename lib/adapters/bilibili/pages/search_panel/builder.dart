import 'package:skf/core/models/search_types.dart';
import 'package:skf/adapters/bilibili/pages/search_panel/article/view.dart';
import 'package:skf/adapters/bilibili/pages/search_panel/live/view.dart';
import 'package:skf/adapters/bilibili/pages/search_panel/pgc/view.dart';
import 'package:skf/adapters/bilibili/pages/search_panel/user/view.dart';
import 'package:skf/adapters/bilibili/pages/search_panel/video/view.dart';
import 'package:flutter/material.dart';

/// B站 搜索结果面板映射：将通用页面的 [CoreSearchType] 映射到 B站 具体面板。
Widget biliSearchPanelBuilder(
  CoreSearchType type, {
  required String tag,
  required String keyword,
}) {
  return switch (type) {
    CoreSearchType.video => SearchVideoPanel(
      tag: tag,
      searchType: type,
      keyword: keyword,
    ),
    CoreSearchType.media_bangumi || CoreSearchType.media_ft => SearchPgcPanel(
      tag: tag,
      searchType: type,
      keyword: keyword,
    ),
    CoreSearchType.live_room => SearchLivePanel(
      tag: tag,
      searchType: type,
      keyword: keyword,
    ),
    CoreSearchType.bili_user => SearchUserPanel(
      tag: tag,
      searchType: type,
      keyword: keyword,
    ),
    CoreSearchType.article => SearchArticlePanel(
      tag: tag,
      searchType: type,
      keyword: keyword,
    ),
  };
}
