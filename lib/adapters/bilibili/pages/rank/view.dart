import 'package:skf/common/widgets/flutter/vertical_tabs.dart';
import 'package:skf/pages/common/bar_hide_type.dart';
import 'package:skf/adapters/bilibili/models/common/rank_type.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/adapters/bilibili/pages/rank/controller.dart';
import 'package:skf/adapters/bilibili/pages/rank/zone/controller.dart';
import 'package:skf/adapters/bilibili/pages/rank/zone/view.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class RankPage extends ConsumerStatefulWidget {
  const RankPage({super.key});

  @override
  ConsumerState<RankPage> createState() => _RankPageState();
}

class _RankPageState extends ConsumerState<RankPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final MainControllerNotifier _mainCtr = Get.find<MainControllerNotifier>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: RankType.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            controller: _tabController,
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
      controller: _tabController,
      padding: .only(bottom: MediaQuery.paddingOf(context).bottom + 105),
      tabs: RankType.values.map((e) => VerticalTab(text: e.label)).toList(),
      onTap: (index) {
        if (!_tabController.indexIsChanging) {
          // Animate scroll to top of current zone
          final item = RankType.values[_tabController.index];
          final tag = '${item.rid}${item.seasonType}';
          try {
            final zoneCtr = Get.find<ZoneController>(tag: tag);
            zoneCtr.scrollController.animToTop();
          } catch (_) {}
        } else {
          ref.read(rankProvider.notifier).setTabIndex(index);
          _tabController.animateTo(index);
        }
      },
      scrollOffsetAdjustment: _mainCtr.useBottomNav &&
              switch (_mainCtr.barHideType) {
                BarHideType.instant => _mainCtr.showBottomBar?.value ?? true,
                BarHideType.sync => (_mainCtr.barOffset?.value ?? 0) == 0,
              }
          ? 80.0
          : 0.0,
    );
  }
}
