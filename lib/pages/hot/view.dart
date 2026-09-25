import 'package:flutter/material.dart';
import 'package:skf/common/skeleton/video_card_v.dart';
import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/flutter/tabs.dart' show CustomTabBarView;
import 'package:skf/common/widgets/hot_video_card.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/hot/controller.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/grid.dart';
import 'package:skf/utils/storage_pref.dart';

/// 热门页(框架级):三个时间窗口子榜(本周/本月/本季),
/// 数据来自 core `VideoRepository.hotVideoList(timeLimitDays:)`。
class HotPage extends StatefulWidget {
  const HotPage({super.key});

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  static const _periods = <({String label, int days})>[
    (label: '本周热门', days: 7),
    (label: '本月热门', days: 30),
    (label: '本季热门', days: 90),
  ];

  late final _tabController = TabController(
    length: _periods.length,
    vsync: this,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _bindActiveSubController();
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _bindActiveSubController();
    }
  }

  /// 外壳双击回顶/刷新作用于当前子榜。
  void _bindActiveSubController() {
    HotCoordinator.active =
        appRead(hotControllerProvider(_periods[_tabController.index].days));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    if (HotCoordinator.active != null) {
      HotCoordinator.active = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SizedBox(
            height: 40,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              tabs: _periods.map((e) => Tab(text: e.label)).toList(),
              isScrollable: true,
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              splashBorderRadius: Style.mdRadius,
              tabAlignment: TabAlignment.center,
              labelStyle: TabBarTheme.of(context).labelStyle?.copyWith(
                    fontSize: 14,
                  ) ??
                  const TextStyle(fontSize: 14),
              unselectedLabelColor: theme.colorScheme.onSurface,
              onTap: (_) {
                feedBack();
                if (!_tabController.indexIsChanging) {
                  HotCoordinator.active?.animateToTop();
                }
              },
            ),
          ),
        ),
        Expanded(
          child: CustomTabBarView(
            controller: _tabController,
            children: _periods
                .map(
                  (e) => _HotRankPage(
                    key: ValueKey(e.days),
                    timeLimitDays: e.days,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _HotRankPage extends StatefulWidget {
  const _HotRankPage({super.key, required this.timeLimitDays});

  final int timeLimitDays;

  @override
  State<_HotRankPage> createState() => _HotRankPageState();
}

class _HotRankPageState extends State<_HotRankPage>
    with AutomaticKeepAliveClientMixin {
  late final HotController controller =
      appRead(hotControllerProvider(widget.timeLimitDays));

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      clipBehavior: .hardEdge,
      margin: const .symmetric(horizontal: Style.safeSpace),
      decoration: const BoxDecoration(borderRadius: Style.mdRadius),
      child: refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const .only(top: Style.cardSpace, bottom: 100),
              sliver: ListenableBuilder(
                listenable: controller,
                builder: (_, _) => _buildBody(controller.loadingState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: Style.cardSpace,
    crossAxisSpacing: Style.cardSpace,
    maxCrossAxisExtent: Pref.recommendCardWidth,
    childAspectRatio: Style.aspectRatio,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
  );

  Widget _buildBody(LoadingState<List<CoreHotVideoItemModel>?> loadingState) {
    return switch (loadingState) {
      // 骨架与真实列表同 delegate 网格铺满,加载完成零跳动。
      Loading() => SliverGrid.builder(
          gridDelegate: gridDelegate,
          itemCount: 10,
          itemBuilder: (_, _) => const VideoCardVSkeleton(),
        ),
      Error(:final errMsg) =>
        HttpError(errMsg: errMsg, onReload: controller.onReload),
      Success(:final response) when response != null && response.isNotEmpty =>
        SliverGrid.builder(
          gridDelegate: gridDelegate,
          itemCount: response.length,
          itemBuilder: (context, index) {
            if (index == response.length - 1) {
              controller.onLoadMore();
            }
            return HotVideoCard(item: response[index]);
          },
        ),
      // 空列表即暂无内容,不是骨架屏。
      Success() => HttpError(errMsg: '暂无热门内容', onReload: controller.onReload),
    };
  }
}
