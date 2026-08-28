import 'package:skf/common/widgets/appbar/appbar.dart';
import 'package:skf/common/widgets/flutter/page/tabs.dart';
import 'package:skf/common/widgets/flutter/pop_scope.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/gesture/horizontal_drag_gesture_recognizer.dart';
import 'package:skf/common/widgets/keep_alive_wrapper.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/pages/history/base_controller.dart';
import 'package:skf/pages/history/controller.dart';
import 'package:skf/pages/history/history_actions.dart';
import 'package:skf/pages/history/widgets/item.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart' hide TabBarView;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key, this.type, this.actions});

  final String? type;

  /// 通用页面的视频/PGC 导航契约，由适配器注入（见 bilibili bridge）。
  final HistoryActions? actions;

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  late final HistoryController _historyController;

  @override
  void initState() {
    super.initState();
    _historyController = HistoryController(widget.type);
    historyControllerRegistry[widget.type ?? 'all'] = _historyController;
  }

  HistoryController currCtr([int? index]) {
    try {
      index ??= _historyController.tabController!.index;
      if (index != 0) {
        return appRead(
          historyControllerProvider(_historyController.tabs[index - 1].type!),
        );
      }
    } catch (_) {}
    return _historyController;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final padding = MediaQuery.viewPaddingOf(context);
    final baseState = ref.watch(historyBaseProvider);
    final enableMultiSelect = baseState.enableMultiSelect;
    Widget child = refreshIndicator(
      onRefresh: _historyController.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _historyController.scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: padding.bottom + 100,
            ),
            sliver: ListenableBuilder(
              listenable: _historyController,
              builder: (_, _) => _buildBody(_historyController.loadingState),
            ),
          ),
        ],
      ),
    );
    if (widget.type != null) {
      return child;
    }
    return popScope(
      canPop: !enableMultiSelect,
      onPopInvokedWithResult: (didPop, result) {
        if (enableMultiSelect) {
          currCtr().handleSelect();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MultiSelectAppBarWidget(
          visible: enableMultiSelect,
          ctr: currCtr(),
          child: _buildAppBar,
        ),
        body: Padding(
          padding: EdgeInsets.only(
            left: padding.left,
            right: padding.right,
          ),
          child: ListenableBuilder(
            listenable: _historyController,
            builder: (_, _) {
              final tabs = _historyController.tabs;
            if (tabs.isEmpty) {
              return child;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  controller: _historyController.tabController,
                  onTap: (index) {
                    if (!_historyController
                        .tabController!
                        .indexIsChanging) {
                      currCtr().scrollController.animToTop();
                    } else {
                      if (enableMultiSelect) {
                        currCtr(
                          _historyController.tabController!.previousIndex,
                        ).handleSelect();
                      }
                    }
                  },
                  tabs: [
                    const Tab(text: '全部'),
                    ...tabs.map((item) => Tab(text: item.name)),
                  ],
                ),
                Expanded(
                  child: TabBarView<CustomHorizontalDragGestureRecognizer>(
                    physics: enableMultiSelect
                        ? const NeverScrollableScrollPhysics()
                        : clampingScrollPhysics,
                    controller: _historyController.tabController,
                    horizontalDragGestureRecognizer:
                        CustomHorizontalDragGestureRecognizer.new,
                    children: [
                      KeepAliveWrapper(child: child),
                      ...tabs.map((item) => HistoryPage(
                        type: item.type,
                        actions: widget.actions,
                      )),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  AppBar get _buildAppBar {
    final pauseStatus = ref.watch(historyBaseProvider).pauseStatus;
    return AppBar(
      title: const Text('观看记录'),
      bottom: _buildPauseTip,
      actions: [
        IconButton(
          tooltip: '搜索',
          onPressed: () => AppNavigator.toNamed('/historySearch'),
          icon: const Icon(Icons.search_outlined),
        ),
        PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
              onTap: () =>
                  ref.read(historyBaseProvider.notifier).onPauseHistory(context),
              child: Text(
                !pauseStatus ? '暂停观看记录' : '恢复观看记录',
              ),
            ),
            PopupMenuItem(
              onTap: () => ref.read(historyBaseProvider.notifier).onClearHistory(
                context,
                () {
                  _historyController.loadingState = const Success(null);
                  if (_historyController.tabController != null) {
                    for (final item in _historyController.tabs) {
                      try {
                        appRead(
                          historyControllerProvider(item.type!),
                        ).loadingState = const Success(
                          null,
                        );
                      } catch (_) {}
                    }
                  }
                },
              ),
              child: const Text('清空观看记录'),
            ),
            PopupMenuItem(
              onTap: currCtr().onDelViewedHistory,
              child: const Text('删除已看记录'),
            ),
          ],
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildBody(LoadingState<List<CoreHistoryItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _historyController.onLoadMore();
                  }
                  final item = response[index];
                  return HistoryItem(
                    item: item,
                    actions: widget.actions,
                    ctr: _historyController,
                    onDelete: (kid, business) =>
                        _historyController.delHistory(item),
                  );
                },
                itemCount: response.length,
              )
            : HttpError(onReload: _historyController.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _historyController.onReload,
      ),
    };
  }

  PreferredSizeWidget? get _buildPauseTip {
    if (ref.watch(historyBaseProvider).pauseStatus) {
      final theme = Theme.of(context).colorScheme;
      return PreferredSize(
        preferredSize: const Size.fromHeight(38),
        child: Container(
          height: 38,
          color: theme.secondaryContainer.withValues(alpha: 0.8),
          padding: const EdgeInsets.only(left: 16, right: 6),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  strutStyle: const StrutStyle(height: 1, leading: 0),
                  style: TextStyle(
                    height: 1,
                    color: theme.onSecondaryContainer,
                  ),
                  TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.info_outline,
                          size: 18,
                          color: theme.onSecondaryContainer,
                        ),
                      ),
                      const TextSpan(text: ' 历史记录功能已关闭'),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    ref.read(historyBaseProvider.notifier).onPauseHistory(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  child: Text(
                    '点击开启',
                    strutStyle: const StrutStyle(height: 1, leading: 0),
                    style: TextStyle(height: 1, color: theme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return null;
  }

  @override
  bool get wantKeepAlive => widget.type != null;
}
