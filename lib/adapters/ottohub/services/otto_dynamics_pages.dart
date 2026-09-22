// OttoHub 动态页与动态详情(博客形态)。
//
// 版式复原自原 B站 适配器:主动态页 tab(全部 = 关注时间线,经 Core
// DynamicsRepository.followDynamic)与动态详情页(dynamicDetail →
// DynamicPanel(isDetail: true) + 博客评论),列表骨架用框架
// DynamicCardSkeleton。OttoHub 无对应内容形态的 tab(投稿/番剧/UP)
// 显示占位。

import 'package:flutter/material.dart';

import 'package:skf/common/skeleton/dynamic_card.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart'
    show refreshIndicator;
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/adapters/ottohub/repository/otto_dynamics_repository.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/dynamics/controller.dart';
import 'package:skf/pages/dynamics/widgets/dynamic_panel.dart';

/// 主动态页单个 tab 的内容(由 OttoDynamicsHost.buildTabPage 装配)。
class OttoDynamicsTabPage extends StatelessWidget {
  const OttoDynamicsTabPage({super.key, required this.type});

  final CoreDynamicsTabType type;

  @override
  Widget build(BuildContext context) {
    final repo = appRead(dynamicsRepositoryProvider) as OttoDynamicsRepository;
    switch (type) {
      case CoreDynamicsTabType.all:
        return const OttoFollowDynTab();
      case CoreDynamicsTabType.video:
        return OttoDynListTab(
          fetch: (offset) =>
              repo.followDynamic(offset: offset, type: CoreDynamicsTabType.video),
        );
      case CoreDynamicsTabType.article:
        return OttoDynListTab(fetch: (offset) => repo.blogFeed(offset: offset));
      case CoreDynamicsTabType.up:
        return const OttoUpDynTab();
      case CoreDynamicsTabType.pgc:
        return const Center(child: Text('暂不支持该动态类型'));
    }
  }
}

/// 关注时间线 tab(复原原主页面「全部」tab:DynamicPanel 列表 +
/// 末尾触发分页加载)。
class OttoFollowDynTab extends StatefulWidget {
  const OttoFollowDynTab({super.key});

  @override
  State<OttoFollowDynTab> createState() => _OttoFollowDynTabState();
}

class _OttoFollowDynTabState extends State<OttoFollowDynTab> {
  List<CoreDynamicItemModel> _items = <CoreDynamicItemModel>[];
  String? _nextOffset;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _firstLoaded = false;
  String? _errMsg;

  @override
  void initState() {
    super.initState();
    _query(more: false);
  }

  Future<void> _query({required bool more}) async {
    if (_isLoading || (more && !_hasMore)) return;
    _isLoading = true;
    final res = await appRead(dynamicsRepositoryProvider).followDynamic(
      offset: more ? _nextOffset : null,
    );
    if (!mounted) return;
    _isLoading = false;
    switch (res) {
      case Success(:final response):
        setState(() {
          final page = response.items ?? <CoreDynamicItemModel>[];
          if (more) {
            _items.addAll(page);
          } else {
            _items = page;
            _firstLoaded = true;
            _errMsg = null;
          }
          _nextOffset = response.offset;
          _hasMore = response.hasMore == true && page.isNotEmpty;
        });
      case final Error err:
        if (more) {
          setState(() => _hasMore = false);
        } else {
          setState(() => _errMsg = err.errMsg ?? '加载失败');
        }
      case Loading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstLoaded) {
      if (_errMsg == null) {
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (_, _) => const DynamicCardSkeleton(),
        );
      }
      return HttpError(
        isSliver: false,
        errMsg: _errMsg == '需要登录' ? '登录后查看关注动态' : _errMsg,
        onReload: () => _query(more: false),
      );
    }
    if (_items.isEmpty) {
      return refreshIndicator(
        onRefresh: () => _query(more: false),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: const [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('没有新的动态')),
            ),
          ],
        ),
      );
    }
    return refreshIndicator(
      onRefresh: () => _query(more: false),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom + 100),
            sliver: SliverList.builder(
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  if (_hasMore) _query(more: true);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        _hasMore ? '加载中...' : '没有更多了',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }
                return DynamicPanel(item: _items[index]);
              },
              itemCount: _items.length + 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// 动态详情页(/blogDetail?bid=,博客即动态)。
///
/// 复原原 dynamics_detail 结构:DynamicPanel(isDetail: true) +
/// 博客评论列表(ReplyRepository.mainList type=1 → /comment/blogs/{bid})。
class OttoDynDetailPage extends StatefulWidget {
  const OttoDynDetailPage({super.key, required this.bid});

  final int bid;

  @override
  State<OttoDynDetailPage> createState() => _OttoDynDetailPageState();

  static OttoDynDetailPage fromQuery(String? bid) => OttoDynDetailPage(
        bid: int.tryParse(bid ?? '') ?? 0,
      );
}

class _OttoDynDetailPageState extends State<OttoDynDetailPage> {
  LoadingState<CoreDynamicItemModel> _state =
      LoadingState<CoreDynamicItemModel>.loading();
  LoadingState<List<CoreReplyItem>> _replies =
      LoadingState<List<CoreReplyItem>>.loading();

  @override
  void initState() {
    super.initState();
    _query();
    _queryReplies();
  }

  Future<void> _query() async {
    setState(() {
      _state = LoadingState<CoreDynamicItemModel>.loading();
    });
    final res = await appRead(dynamicsRepositoryProvider).dynamicDetail(
      id: '${widget.bid}',
    );
    if (!mounted) return;
    switch (res) {
      case Success(:final response):
        setState(() => _state = Success(response));
      case final Error err:
        setState(() => _state = Error(err.errMsg, code: err.code));
      case Loading():
        break;
    }
  }

  Future<void> _queryReplies() async {
    if (widget.bid <= 0) return;
    final res = await appRead(replyRepositoryProvider).mainList(
      type: 1,
      oid: widget.bid,
      mode: CoreMode.defaultMode,
      offset: null,
      cursorNext: null,
    );
    if (!mounted) return;
    switch (res) {
      case Success(:final response):
        setState(() {
          _replies = Success(
            (response.replies ?? const <Object?>[])
                .whereType<Map<String, dynamic>>()
                .map(CoreReplyItem.fromMap)
                .toList(),
          );
        });
      case final Error err:
        setState(
          () => _replies = Error(err.errMsg, code: err.code),
        );
      case Loading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('动态详情')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: switch (_state) {
              Loading() => const Padding(
                padding: EdgeInsets.all(48),
                child: DynamicCardSkeleton(),
              ),
              Error() => HttpError(
                isSliver: false,
                errMsg: _state is Error ? (_state as Error).errMsg : null,
                onReload: _query,
              ),
              Success(:final response) => DynamicPanel(
                item: response,
                isDetail: true,
              ),
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                '评论',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          switch (_replies) {
            Loading() => SliverList.builder(
              itemBuilder: (_, _) => const DynamicCardSkeleton(),
              itemCount: 3,
            ),
            Success(:final response) => response.isNotEmpty
                ? SliverList.builder(
                    itemBuilder: (context, index) => ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      title: Text(
                        response[index].member?.uname ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      subtitle: Text(
                        response[index].content,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    itemCount: response.length,
                  )
                : const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('还没有评论')),
                    ),
                  ),
            Error(:final errMsg) => SliverToBoxAdapter(
              child: HttpError(errMsg: errMsg, onReload: _queryReplies),
            ),
          },
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

/// 通用分页动态列表(投稿/专栏 tab 共用)。
class OttoDynListTab extends StatefulWidget {
  const OttoDynListTab({super.key, required this.fetch});

  final Future<LoadingState<CoreDynamicsDataModel>> Function(String? offset)
      fetch;

  @override
  State<OttoDynListTab> createState() => _OttoDynListTabState();
}

class _OttoDynListTabState extends State<OttoDynListTab> {
  List<CoreDynamicItemModel> _items = <CoreDynamicItemModel>[];
  String? _nextOffset;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _firstLoaded = false;
  String? _errMsg;

  @override
  void initState() {
    super.initState();
    _query(more: false);
  }

  Future<void> _query({required bool more}) async {
    if (_isLoading || (more && !_hasMore)) return;
    _isLoading = true;
    final res = await widget.fetch(more ? _nextOffset : null);
    if (!mounted) return;
    _isLoading = false;
    switch (res) {
      case Success(:final response):
        setState(() {
          final page = response.items ?? <CoreDynamicItemModel>[];
          if (more) {
            _items.addAll(page);
          } else {
            _items = page;
            _firstLoaded = true;
            _errMsg = null;
          }
          _nextOffset = response.offset;
          _hasMore = response.hasMore == true && page.isNotEmpty;
        });
      case final Error err:
        if (more) {
          setState(() => _hasMore = false);
        } else {
          setState(
            () => _errMsg = err.errMsg == '需要登录' ? '登录后查看' : err.errMsg,
          );
        }
      case Loading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstLoaded) {
      if (_errMsg == null) {
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (_, _) => const DynamicCardSkeleton(),
        );
      }
      return HttpError(
        isSliver: false,
        errMsg: _errMsg,
        onReload: () => _query(more: false),
      );
    }
    if (_items.isEmpty) {
      return refreshIndicator(
        onRefresh: () => _query(more: false),
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('暂无内容')),
            ),
          ],
        ),
      );
    }
    return refreshIndicator(
      onRefresh: () => _query(more: false),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: SliverList.builder(
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  if (_hasMore) _query(more: true);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        _hasMore ? '加载中...' : '没有更多了',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }
                return DynamicPanel(item: _items[index]);
              },
              itemCount: _items.length + 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// UP tab:展示选中 UP 的动态;未选择时回落到当前用户自己的动态。
class OttoUpDynTab extends StatelessWidget {
  const OttoUpDynTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = appRead(dynamicsControllerProvider);
    final mid = controller.currentMid != -1
        ? controller.currentMid
        : (appRead(accountProvider).userId ?? -1);
    if (mid <= 0) {
      return const Center(child: Text('登录后查看'));
    }
    final repo = appRead(dynamicsRepositoryProvider) as OttoDynamicsRepository;
    return OttoDynListTab(
      key: ValueKey(mid),
      fetch: (offset) => repo.userDynFeed(uid: mid, offset: offset),
    );
  }
}
