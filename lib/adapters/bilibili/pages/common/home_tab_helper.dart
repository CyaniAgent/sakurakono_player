import 'package:skf/adapters/bilibili/models/common/home_tab_type.dart';
import 'package:skf/pages/common/common_controller.dart';
import 'package:skf/adapters/bilibili/pages/hot/controller.dart';
import 'package:skf/adapters/bilibili/pages/hot/view.dart';
import 'package:skf/adapters/bilibili/pages/live/controller.dart';
import 'package:skf/adapters/bilibili/pages/live/view.dart';
import 'package:skf/adapters/bilibili/pages/pgc/controller.dart';
import 'package:skf/adapters/bilibili/pages/pgc/view.dart';
import 'package:skf/adapters/bilibili/pages/rank/controller.dart' show RankScrollBridge;
import 'package:skf/adapters/bilibili/pages/rank/view.dart';
import 'package:skf/adapters/bilibili/pages/rcmd/controller.dart';
import 'package:skf/adapters/bilibili/pages/rcmd/view.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

ScrollOrRefreshMixin homeTabCtrFor(HomeTabType type) => switch (type) {
  HomeTabType.live => Get.find<LiveController>(),
  HomeTabType.rcmd => Get.find<RcmdController>(),
  HomeTabType.hot => Get.find<HotController>(),
  HomeTabType.rank => RankScrollBridge(),
  HomeTabType.bangumi ||
  HomeTabType.cinema => Get.find<PgcController>(tag: type.name),
};

Widget homeTabPageFor(HomeTabType type) => switch (type) {
  HomeTabType.live => const LivePage(),
  HomeTabType.rcmd => const RcmdPage(),
  HomeTabType.hot => const HotPage(),
  HomeTabType.rank => const RankPage(),
  HomeTabType.bangumi => const PgcPage(tabType: HomeTabType.bangumi),
  HomeTabType.cinema => const PgcPage(tabType: HomeTabType.cinema),
};
