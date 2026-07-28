import 'package:skf/common/widgets/flutter/vertical_tabs.dart';
import 'package:skf/adapters/bilibili/models/common/bar_hide_type.dart';
import 'package:skf/adapters/bilibili/models/common/rank_type.dart';
import 'package:skf/adapters/bilibili/pages/main/controller.dart';
import 'package:skf/adapters/bilibili/pages/rank/controller.dart';
import 'package:skf/adapters/bilibili/pages/rank/zone/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage>
    with AutomaticKeepAliveClientMixin {
  final RankController _rankController = Get.put(RankController());
  final MainController _mainCtr = Get.find<MainController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        _buildTab(theme),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _rankController.tabController,
            children: RankType.values
                .map(
                  (item) => ZonePage(
                    rid: item.rid,
                    seasonType: item.seasonType,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(ThemeData theme) {
    return VerticalTabBar(
      dividerWidth: 0,
      isScrollable: true,
      indicatorWeight: 3,
      indicatorSize: .tab,
      controller: _rankController.tabController,
      padding: .only(bottom: MediaQuery.paddingOf(context).bottom + 105),
      tabs: RankType.values.map((e) => VerticalTab(text: e.label)).toList(),
      onTap: (index) {
        if (!_rankController.tabController.indexIsChanging) {
          _rankController.animateToTop();
        } else {
          _rankController
            ..tabIndex.value = index
            ..tabController.animateTo(index);
        }
      },
      scrollOffsetAdjustment: _mainCtr.useBottomNav &&
              switch (_mainCtr.barHideType) {
                BarHideType.instant => _mainCtr.showBottomBar?.value ?? true,
                BarHideType.sync => (_mainCtr.barOffset?.value ?? 0) == 0,
              _ => true,
              }
          ? 80.0
          : 0.0,
    );
  }
}
