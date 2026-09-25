// OttoHub 动态页与动态详情(博客形态)。
//
// 三分类装配:最新 = 站内最新博客(blogFeed),关注 = 关注时间线
// (followDynamic;UP 面板选中时切 userDynFeed),推荐 = 随机博客
// (randomBlogFeed)。动态详情页(/blogDetail)为 DynamicPanel(isDetail:
// true) + 博客评论,列表骨架用框架 DynamicCardSkeleton。

import 'package:flutter/material.dart';

import 'package:skf/common/skeleton/dynamic_card.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart'
    show refreshIndicator;
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/adapters/ottohub/repository/otto_dynamics_repository.dart';
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
    return switch (type) {
      // 最新:站内最新博客流(可翻页)。
      CoreDynamicsTabType.latest =>
        OttoDynListTab(
          tabType: type,
          fetch: (offset) => repo.blogFeed(offset: offset),
        ),
      // 关注:关注时间线(视频+博客);UP 面板选中某人时切到该用户的流。
      CoreDynamicsTabType.follow => const OttoFollowDynTab(),
      // 推荐:随机博客推荐(单批,刷新换一批)。
      CoreDynamicsTabType.recommend =>
        OttoDynListTab(
          tabType: type,
          fetch: (offset) => repo.randomBlogFeed(),
        ),
    };
  }
}

/// 各分类 tab 列表状态注册表:供 host 转发下拉刷新/双击回顶等调用,
/// 对齐原适配器「tab 级控制器转发」的行为(bb7d917)。
/// 假设动态页单实例(单条 /dynamics 路由):同分类后挂载者覆盖前者。
class OttoDynTabRegistry {
  static final _states = <CoreDynamicsTabType, _OttoDynListTabState>{};

  static void _attach(CoreDynamicsTabType type, _OttoDynListTabState state) =>
      _states[type] = state;

  static void _detach(CoreDynamicsTabType type, _OttoDynListTabState state) {
    if (identical(_states[type], state)) {
      _states.remove(type);
    }
  }

  static _OttoDynListTabState? _of(CoreDynamicsTabType type) => _states[type];

  /// 刷新该分类列表(等价下拉刷新)。
  static Future<void> refresh(CoreDynamicsTabType type) async =>
      _of(type)?.refresh();

  /// 回顶。
  static void animateToTop(CoreDynamicsTabType type) =>
      _of(type)?.animateToTop();

  /// 该分类列表的滚动视图是否已挂载。
  static bool hasScrollClients(CoreDynamicsTabType type) =>
      _of(type)?.hasClients ?? false;

  /// 该分类列表当前滚动距离(未挂载为 0)。
  static double scrollPixels(CoreDynamicsTabType type) =>
      _of(type)?.scrollPixels ?? 0;
}

/// 关注分类 tab:未选中 UP 时为关注时间线(followDynamic),
/// UP 面板选中某人时为该用户的动态流(userDynFeed)。
/// 监听 dynamics 控制器(选择变更会 notifyChange)自动重建列表。
class OttoFollowDynTab extends StatelessWidget {
  const OttoFollowDynTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = appRead(dynamicsControllerProvider);
    return ListenableBuilder(
      listenable: controller,
      builder: (_, _) {
        final mid = controller.currentMid;
        return OttoDynListTab(
          key: ValueKey('follow-up-$mid'),
          tabType: CoreDynamicsTabType.follow,
          fetch: (offset) => _fetch(mid, offset),
        );
      },
    );
  }

  Future<LoadingState<CoreDynamicsDataModel>> _fetch(int mid, String? offset) {
    final repo = appRead(dynamicsRepositoryProvider) as OttoDynamicsRepository;
    if (mid != -1 && mid > 0) {
      return repo.userDynFeed(uid: mid, offset: offset);
    }
    return repo.followDynamic(offset: offset);
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
              child: HttpError(
                isSliver: false,
                errMsg: errMsg,
                onReload: _queryReplies,
              ),
            ),
          },
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
/// 通用分页动态列表(最新/推荐/关注分类共用)。
/// [tabType] 非空时注册到 [OttoDynTabRegistry],接受 host 级刷新/回顶转发。
class OttoDynListTab extends StatefulWidget {
  const OttoDynListTab({
    super.key,
    this.tabType,
    required this.fetch,
  });

  final CoreDynamicsTabType? tabType;

  final Future<LoadingState<CoreDynamicsDataModel>> Function(String? offset)
      fetch;

  @override
  State<OttoDynListTab> createState() => _OttoDynListTabState();
}

class _OttoDynListTabState extends State<OttoDynListTab> {
  final _scrollController = ScrollController();

  List<CoreDynamicItemModel> _items = <CoreDynamicItemModel>[];
  String? _nextOffset;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _firstLoaded = false;

  /// 加载更多进行中收到下拉刷新:记下,当前查询结束后补一次。
  bool _pendingRefresh = false;
  String? _errMsg;

  @override
  void initState() {
    super.initState();
    if (widget.tabType != null) {
      OttoDynTabRegistry._attach(widget.tabType!, this);
    }
    _query(more: false);
  }

  @override
  void dispose() {
    if (widget.tabType != null) {
      OttoDynTabRegistry._detach(widget.tabType!, this);
    }
    _scrollController.dispose();
    super.dispose();
  }

  /// 供 host 转发:刷新当前列表(等价下拉刷新)。
  Future<void> refresh() => _query(more: false);

  /// 供 host 转发:滚动回顶。
  void animateToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  bool get hasClients => _scrollController.hasClients;

  double get scrollPixels =>
      _scrollController.hasClients ? _scrollController.position.pixels : 0;

  Future<void> _query({required bool more}) async {
    if (_isLoading) {
      if (!more) _pendingRefresh = true;
      return;
    }
    if (more && !_hasMore) return;
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
    if (_pendingRefresh && mounted) {
      _pendingRefresh = false;
      await _query(more: false);
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
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverFillRemaining(
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
        controller: _scrollController,
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
