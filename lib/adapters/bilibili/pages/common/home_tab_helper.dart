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
import 'package:skf/adapters/bilibili/pages/rcmd/view.dart';
import 'package:skf/adapters/bilibili/common/setting_providers.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:flutter/widgets.dart';

ScrollOrRefreshMixin homeTabCtrFor(HomeTabType type) => switch (type) {
  HomeTabType.live => appRead(liveControllerProvider),
  HomeTabType.rcmd => appRead(rcmdControllerProvider),
  HomeTabType.hot => appRead(hotControllerProvider),
  HomeTabType.rank => RankScrollBridge(),
  HomeTabType.bangumi ||
  HomeTabType.cinema => appRead(pgcControllerProvider(type.name)),
};

Widget homeTabPageFor(HomeTabType type) => switch (type) {
  HomeTabType.live => const LivePage(),
  HomeTabType.rcmd => const RcmdPage(),
  HomeTabType.hot => const HotPage(),
  HomeTabType.rank => const RankPage(),
  HomeTabType.bangumi => const PgcPage(tabType: HomeTabType.bangumi),
  HomeTabType.cinema => const PgcPage(tabType: HomeTabType.cinema),
};
