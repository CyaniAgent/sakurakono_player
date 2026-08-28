import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/core/models/search_types.dart';
import 'package:skf/pages/search/controller.dart';
import 'package:skf/pages/search_result/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

/// 搜索结果面板构造器。
///
/// 通用搜索结果页不直接依赖具体适配器的面板实现：适配器（B站 等）通过
/// [SearchResultPage.panelBuilder] 注入自己的面板；未注入时渲染占位。
typedef SearchPanelBuilder =
    Widget Function(
      CoreSearchType type, {
      required String tag,
      required String keyword,
    });

class SearchResultPage extends ConsumerStatefulWidget {
  const SearchResultPage({super.key, this.panelBuilder});

  final SearchPanelBuilder? panelBuilder;

  @override
  ConsumerState<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _tag = DateTime.now().millisecondsSinceEpoch.toString();
  final bool _isFromSearch = AppNavigator.arguments?['fromSearch'] ?? false;
  SSearchController? sSearchController;

  @override
  void initState() {
    super.initState();

    // Register GetX bridge so adapter-based SearchPanelController can still
    // resolve via Get.find<SearchResultController>(tag: tag).
    final keyword = AppNavigator.arguments?['keyword'] ?? '';
    final notifier = ref.read(searchResultProvider(_tag).notifier);
    searchResultControllerRegistry[_tag] =
        SearchResultController(keyword, notifier);

    _tabController = TabController(
      vsync: this,
      initialIndex: AppNavigator.arguments?['initIndex'] ?? 0,
      length: CoreSearchType.values.length,
    );

    if (_isFromSearch) {
      try {
        sSearchController = appRead(
          sSearchByTagProvider(AppNavigator.parameters['tag'] as String),
        );
        _tabController.addListener(listener);
      } catch (_) {}
    }
  }

  void listener() {
    sSearchController?.initIndex = _tabController.index;
  }

  Widget _buildPanel(CoreSearchType type, String keyword) {
    final builder = widget.panelBuilder;
    if (builder == null) {
      return _SearchResultPlaceholder(keyword: keyword);
    }
    return builder(
      type,
      tag: _tag,
      keyword: keyword,
    );
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(listener)
      ..dispose();
    searchResultControllerRegistry.remove(_tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultState = ref.watch(searchResultProvider(_tag));
    final keyword = resultState.keyword;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        title: GestureDetector(
          onTap: () {
            if (_isFromSearch) {
              AppNavigator.back();
            } else {
              AppNavigator.replaceNamed(
                '/search',
                parameters: {'text': keyword},
              );
            }
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              keyword,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
            ),
          ),
        ),
      ),
      body: ViewSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              controller: _tabController,
              tabs: CoreSearchType.values
                  .map(
                    (item) {
                      final count = resultState.count[item.index];
                      return Tab(
                        text:
                            '${item.label}${count != -1 ? ' ${count > 99 ? '99+' : count}' : ''}',
                      );
                    },
                  )
                  .toList(),
              isScrollable: true,
              indicatorWeight: 0,
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 8,
              ),
              indicator: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: theme.colorScheme.onSecondaryContainer,
              labelStyle:
                  TabBarTheme.of(
                    context,
                  ).labelStyle?.copyWith(fontSize: 13) ??
                  const TextStyle(fontSize: 13),
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              unselectedLabelColor: theme.colorScheme.outline,
              tabAlignment: TabAlignment.start,
              onTap: (index) {
                if (!_tabController.indexIsChanging) {
                  ref
                      .read(searchResultProvider(_tag).notifier)
                      .setToTopIndex(index);
                }
              },
            ),
            Expanded(
              child: tabBarView(
                controller: _tabController,
                children: CoreSearchType.values
                    .map((type) => _buildPanel(type, keyword))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultPlaceholder extends StatelessWidget {
  const _SearchResultPlaceholder({required this.keyword});

  final String keyword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        keyword,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}
