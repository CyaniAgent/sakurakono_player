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
import 'package:skf/pages/zone/controller.dart';
import 'package:skf/pages/zone/zone_host.dart';
import 'package:skf/utils/grid.dart';
import 'package:skf/utils/storage_pref.dart';

/// 分区页(框架级,首页「分区」子 tab):分类清单来自适配器 [ZoneHost],
/// 各分区视频走 core `VideoRepository.categoryVideoList`(单批,无加载更多)。
class ZonePage extends StatefulWidget {
  const ZonePage({super.key});

  @override
  State<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late final List<ZoneCategory> _categories = ZoneHost.of().categories;

  TabController? _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (_categories.isNotEmpty) {
      _tabController = TabController(length: _categories.length, vsync: this)
        ..addListener(_onTabChanged);
      _bindActiveSubController();
    }
  }

  void _onTabChanged() {
    if (!(_tabController?.indexIsChanging ?? true)) {
      _bindActiveSubController();
    }
  }

  /// 外壳双击回顶/刷新作用于当前选中分区。
  void _bindActiveSubController() {
    final index = _tabController?.index ?? 0;
    ZoneCoordinator.active =
        appRead(zoneControllerProvider(_categories[index].id));
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    ZoneCoordinator.active = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_categories.isEmpty) {
      return const Center(child: Text('暂无分区'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SizedBox(
            height: 40,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              tabs: _categories.map((e) => Tab(text: e.label)).toList(),
              isScrollable: true,
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              splashBorderRadius: Style.mdRadius,
              tabAlignment: TabAlignment.center,
            ),
          ),
        ),
        Expanded(
          child: CustomTabBarView(
            controller: _tabController,
            children: _categories
                .map(
                  (e) => _ZoneCategoryPage(
                    key: ValueKey(e.id),
                    category: e,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ZoneCategoryPage extends StatefulWidget {
  const _ZoneCategoryPage({super.key, required this.category});

  final ZoneCategory category;

  @override
  State<_ZoneCategoryPage> createState() => _ZoneCategoryPageState();
}

class _ZoneCategoryPageState extends State<_ZoneCategoryPage>
    with AutomaticKeepAliveClientMixin {
  late final ZoneController controller =
      appRead(zoneControllerProvider(widget.category.id));

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
      Loading() => const SliverToBoxAdapter(child: VideoCardVSkeleton()),
      Error(:final errMsg) =>
        HttpError(errMsg: errMsg, onReload: controller.onReload),
      Success(:final response) when response != null && response.isNotEmpty =>
        SliverGrid.builder(
          gridDelegate: gridDelegate,
          itemCount: response.length,
          itemBuilder: (context, index) => HotVideoCard(item: response[index]),
        ),
      // 单批数据:空列表即该分区暂无内容,不是骨架屏。
      Success() => HttpError(errMsg: '该分区暂无内容'),
    };
  }
}
