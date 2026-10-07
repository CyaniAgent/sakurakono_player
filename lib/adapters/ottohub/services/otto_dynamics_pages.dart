// OttoHub 动态页与动态详情(博客形态)。
//
// 三分类装配:最新 = 站内最新博客(blogFeed),关注 = 关注时间线
// (followDynamic;UP 面板选中时切 userDynFeed),推荐 = 随机博客
// (randomBlogFeed)。动态详情页(/blogDetail)为 DynamicPanel(isDetail:
// true) + 「N条回复」固定头(本地排序:最热/最新)+ 评论列表
// (OttoReplyItem,VideoReplySkeleton 骨架)+ 回复 FAB。

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:skf/common/skeleton/dynamic_card.dart';
import 'package:skf/common/skeleton/skeleton.dart';
import 'package:skf/common/skeleton/video_reply.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/common/widgets/sliver/sliver_pinned_header.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart'
    show refreshIndicator;
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/adapters/ottohub/repository/otto_dynamics_repository.dart';
import 'package:skf/adapters/ottohub/services/otto_reply_item.dart';
import 'package:skf/adapters/ottohub/services/otto_reply_pub_page.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/dynamics/controller.dart';
import 'package:skf/pages/dynamics/widgets/author_panel.dart';
import 'package:skf/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/grid.dart';
import 'package:skf/utils/num_utils.dart';

/// 主动态页单个 tab 的内容(由 OttoDynamicsHost.buildTabPage 装配)。
class OttoDynamicsTabPage extends StatelessWidget {
  const OttoDynamicsTabPage({super.key, required this.type});

  final CoreDynamicsTabType type;

  @override
  Widget build(BuildContext context) {
    final repo = appRead(dynamicsRepositoryProvider) as OttoDynamicsRepository;
    return switch (type) {
      // 最新:站内最新博客流(可翻页)。
      CoreDynamicsTabType.latest => OttoDynListTab(
        tabType: type,
        fetch: (offset) => repo.blogFeed(offset: offset),
      ),
      // 关注:关注时间线(视频+博客);UP 面板选中某人时切到该用户的流。
      CoreDynamicsTabType.follow => const OttoFollowDynTab(),
      // 推荐:随机博客推荐(单批,刷新换一批)。
      CoreDynamicsTabType.recommend => OttoDynListTab(
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

/// 二级回复弹层(点开「共 N 条回复」;对齐上游视频页的底部滑入交互:
/// 根评论置顶 + 子回复列表 + 回复入口,拖拽/点外部关闭)。
class OttoReplyDetailPage extends StatefulWidget {
  const OttoReplyDetailPage({
    super.key,
    required this.reply,
    this.replyType = 1,
  });

  final CoreReplyItem reply;

  /// 评论主体类型(1=博客,2=视频),决定 detailList 与发送接口。
  final int replyType;

  /// 底部滑入弹层入口(替代整页 push,对齐上游视频评论区交互)。
  static void to(
    BuildContext context,
    CoreReplyItem reply, {
    int replyType = 1,
  }) => AppNavigator.to(OttoReplyDetailPage(reply: reply, replyType: replyType));

  @override
  State<OttoReplyDetailPage> createState() => _OttoReplyDetailPageState();
}

class _OttoReplyDetailPageState extends State<OttoReplyDetailPage> {
  List<CoreReplyItem> _items = <CoreReplyItem>[];

  /// 服务端已返回的条目数(本地插入不计入,保证翻页 offset 正确)。
  int _serverCount = 0;
  bool _isLoading = false;
  bool _hasMore = false;
  bool _firstLoaded = false;
  String? _errMsg;

  @override
  void initState() {
    super.initState();
    _query();
  }

  Future<void> _query() async {
    if (_isLoading) return;
    _isLoading = true;
    final res = await appRead(replyRepositoryProvider).detailList(
      type: widget.replyType,
      oid: widget.reply.oid,
      root: widget.reply.rpid,
      rpid: widget.reply.rpid,
      mode: CoreMode.defaultMode,
      offset: _serverCount == 0 ? null : '$_serverCount',
    );
    if (!mounted) return;
    _isLoading = false;
    switch (res) {
      case Success(:final response):
        final page = (response.replies ?? const <Object?>[])
            .whereType<Map<String, dynamic>>()
            .map(CoreReplyItem.fromMap)
            .toList();
        setState(() {
          if (_serverCount == 0) {
            _items = page;
          } else {
            _items.addAll(page);
          }
          _serverCount += page.length;
          _hasMore = page.length >= 20;
          _firstLoaded = true;
          _errMsg = null;
        });
      case final Error err:
        setState(() {
          _firstLoaded = true;
          _errMsg = err.errMsg ?? '加载失败';
        });
      case Loading():
        break;
    }
  }

  /// 回复根评论:输入弹层 → 本地追加(不计入服务端计数)。
  Future<void> _reply() async {
    final parent = widget.reply;
    final message = await showOttoReplySheet(
      oid: parent.oid,
      parent: parent.rpid,
      hint: ' 回复 @${parent.member?.uname} : ',
      replyType: widget.replyType,
    );
    if (message == null || message.isEmpty || !mounted) return;
    final account = appRead(accountProvider);
    final mid = account.userId ?? 0;
    final item = CoreReplyItem(
      oid: parent.oid,
      mid: mid,
      root: parent.rpid,
      parent: parent.rpid,
      content: message,
      ctime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      member: CoreReplyMember(
        mid: mid,
        uname: account.displayName ?? '',
        avatar: account.face,
      ),
    );
    setState(() => _items = [..._items, item]);
  }

  @override
  @override
  Widget build(BuildContext context) {
    // 底部滑入弹层形态(对齐上游视频评论区交互)。
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ViewSafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 640,
            maxHeight: MediaQuery.heightOf(context) * 0.75,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: !_firstLoaded
                    ? (_errMsg == null
                          ? ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: Grid.lineSkeletonCount(
                                MediaQuery.heightOf(context),
                              ),
                              itemBuilder: (_, _) => const VideoReplySkeleton(),
                            )
                          : HttpError(
                              isSliver: false,
                              errMsg: _errMsg,
                              onReload: _query,
                            ))
                    : CustomScrollView(
                        slivers: [
                          // 根评论置顶(上游 firstFloor 语义)。
                          SliverToBoxAdapter(
                            child: OttoReplyItem(
                              item: widget.reply,
                              upMid: null,
                              onReply: _reply,
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.only(left: 34),
                            sliver: switch (_repliesState()) {
                              _ReplyListState.empty => const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: Text('还没有回复')),
                                ),
                              ),
                              _ReplyListState.error => SliverToBoxAdapter(
                                child: HttpError(
                                  isSliver: false,
                                  errMsg: _errMsg,
                                  onReload: _query,
                                ),
                              ),
                              _ReplyListState.list => SliverList.builder(
                                itemBuilder: (context, index) {
                                  if (index == _items.length) {
                                    if (_hasMore) _query();
                                    return Container(
                                      alignment: .center,
                                      height: 100,
                                      child: Text(
                                        _hasMore ? '加载中...' : '没有更多了',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  }
                                  return OttoReplyItem(
                                    item: _items[index],
                                    upMid: null,
                                    onReply: _reply,
                                  );
                                },
                                itemCount: _items.length + 1,
                              ),
                            },
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.viewPaddingOf(context).bottom + 40,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 列表三态:空/错误/正常(修复首载失败后错误不可见)。
  _ReplyListState _repliesState() {
    if (_items.isEmpty) {
      return _errMsg != null ? _ReplyListState.error : _ReplyListState.empty;
    }
    return _ReplyListState.list;
  }
}

enum _ReplyListState { empty, error, list }

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

  /// 评论总数(动态 moduleStat.comment.count;服务端未回传时回退条目数)。
  int? _count;

  /// 排序:true = 按热度,false = 按时间(本地排序;服务端无排序参数)。
  bool _sortByHot = true;
  bool _hasMore = false;

  /// 加载更多进行中守卫(防 itemBuilder 同帧多次触发)。
  bool _isLoadingMore = false;

  /// 服务端已返回的评论数(本地插入不计,保证翻页 offset 正确)。
  int _serverReplyCount = 0;

  /// AppBar 作者信息渐显:滚动超过 55px 后显示(对齐上游)。
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_onScroll);
  bool _showTitle = false;

  void _onScroll() {
    final show = _scrollController.hasClients &&
        _scrollController.positions.first.pixels > 55;
    if (show != _showTitle) setState(() => _showTitle = show);
  }

  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _query();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          final page = (response.replies ?? const <Object?>[])
              .whereType<Map<String, dynamic>>()
              .map(CoreReplyItem.fromMap)
              .toList();
          _replies = Success(page);
          _serverReplyCount = page.length;
          _hasMore = page.length >= _pageSize;
        });
      case final Error err:
        setState(() => _replies = Error(err.errMsg, code: err.code));
      case Loading():
        break;
    }
  }

  /// 加载更多(offset 按服务端返回条数计,本地插入不计;近似 hasMore)。
  Future<void> _onLoadMore() async {
    if (_isLoadingMore || _replies is! Success<List<CoreReplyItem>>) return;
    _isLoadingMore = true;
    final current = (_replies as Success<List<CoreReplyItem>>).response;
    final res = await appRead(replyRepositoryProvider).mainList(
      type: 1,
      oid: widget.bid,
      mode: CoreMode.defaultMode,
      offset: '$_serverReplyCount',
      cursorNext: null,
    );
    if (!mounted) return;
    _isLoadingMore = false;
    switch (res) {
      case Success(:final response):
        final page = (response.replies ?? const <Object?>[])
            .whereType<Map<String, dynamic>>()
            .map(CoreReplyItem.fromMap)
            .toList();
        setState(() {
          current.addAll(page);
          _serverReplyCount += page.length;
          _hasMore = page.length >= _pageSize;
          _replies = Success(current);
        });
      case Error():
        setState(() => _hasMore = false);
      case Loading():
        break;
    }
  }

  /// 本地排序(服务端无排序参数):热度 = like 降序,时间 = ctime 降序。
  List<CoreReplyItem> _sorted(List<CoreReplyItem> items) {
    final list = [...items]
      ..sort(
        (a, b) =>
            _sortByHot ? b.like.compareTo(a.like) : b.ctime.compareTo(a.ctime),
      );
    return list;
  }

  /// 发表根评论:输入弹层 → 本地插入(发送成功即时上屏)。
  Future<void> _reply() async {
    final message = await showOttoReplySheet(
      oid: widget.bid,
      hint: '输入评论内容',
      replyType: 1,
    );
    if (message == null || message.isEmpty || !mounted) return;
    final account = appRead(accountProvider);
    final mid = account.userId ?? 0;
    final item = CoreReplyItem(
      oid: widget.bid,
      mid: mid,
      content: message,
      ctime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      member: CoreReplyMember(
        mid: mid,
        uname: account.displayName ?? '',
        avatar: account.face,
      ),
    );
    setState(() {
      switch (_replies) {
        case Success(:final response):
          _replies = Success([item, ...response]);
        case _:
          _replies = Success([item]);
      }
      _count = (_count ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AnimatedOpacity(
            opacity: _showTitle ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_showTitle,
              child: _state is Success<CoreDynamicItemModel>
                  ? AuthorPanel(
                      item: (_state as Success<CoreDynamicItemModel>).response,
                      isDetail: true,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: _reply,
        child: const Icon(Icons.reply),
      ),
      body: refreshIndicator(
        onRefresh: () async {
          await _query();
          await _queryReplies();
        },
        // 宽屏:内容列按「小卡宽 × 2」居中,不全宽铺开(与动态 tab 一致)。
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Grid.smallCardWidth * 2),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: switch (_state) {
                    Loading() => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: BlogContentSkeleton(),
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
                // 「N条回复 + 排序」固定头(上游 buildReplyHeader 版式);
                // 计数取动态 moduleStat.comment.count,未回传回退条目数。
                Builder(
                  builder: (context) {
                    final count = _state is Success<CoreDynamicItemModel>
                        ? (_state as Success<CoreDynamicItemModel>)
                              .response
                              .modules
                              ?.moduleStat
                              ?.comment
                              ?.count
                        : null;
                    final replies = switch (_replies) {
                      Success(:final response) => response,
                      _ => const <CoreReplyItem>[],
                    };
                    return SliverPinnedHeader(
                      backgroundColor: theme.colorScheme.surface,
                      child: Padding(
                        padding: const .fromLTRB(12, 2.5, 6, 2.5),
                        child: Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              '共${NumUtils.numFormat(count ?? replies.length)}条回复',
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  setState(() => _sortByHot = !_sortByHot),
                              icon: const Icon(Icons.sort, size: 16),
                              label: Text(_sortByHot ? '最热' : '最新'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Builder(
                  builder: (context) => switch (_replies) {
                    Loading() => SliverList.builder(
                      itemBuilder: (_, _) => const VideoReplySkeleton(),
                      itemCount: Grid.lineSkeletonCount(
                        MediaQuery.heightOf(context),
                      ),
                    ),
                    Success(:final response) =>
                      response.isNotEmpty
                          ? Builder(
                              builder: (context) {
                                final items = _sorted(response);
                                return SliverList.builder(
                                  // 排序切换即时生效;末尾占位触发加载更多。
                                  itemBuilder: (context, index) {
                                    if (index == items.length) {
                                      if (_hasMore) _onLoadMore();
                                      return Container(
                                        alignment: .center,
                                        height: 125,
                                        child: Text(
                                          _hasMore ? '加载中...' : '没有更多了',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    }
                                    return OttoReplyItem(
                                      item: items[index],
                                      upMid: null,
                                      onReply: _reply,
                                      onOpenDetail: items[index].rcount > 0
                                          ? () => OttoReplyDetailPage.to(
                                              context,
                                              items[index],
                                            )
                                          : null,
                                    );
                                  },
                                  itemCount: items.length + 1,
                                );
                              },
                            )
                          : const SliverToBoxAdapter(
                              child: HttpError(
                                isNotFound: true,
                                isSliver: false,
                                errMsg: '还没有评论',
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
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),
        ),
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

class _OttoDynListTabState extends State<OttoDynListTab>
    with AutomaticKeepAliveClientMixin {
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_firstLoaded) {
      if (_errMsg == null) {
        // 桌面宽视口:内容列按「小卡宽 × 2」居中,不全宽铺开。
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Grid.smallCardWidth * 2,
            ),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: Grid.lineSkeletonCount(
                MediaQuery.heightOf(context),
              ),
              itemBuilder: (_, _) => const DynamicCardSkeleton(),
            ),
          ),
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
          slivers: const [
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
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 非全宽适配(复原原 DynMixin.buildPage):视口宽超过
          // 「小卡宽 × 2」时内容列居中,两侧留白。
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final extra =
                  (constraints.crossAxisExtent - Grid.smallCardWidth * 2) / 2;
              return SliverPadding(
                padding: EdgeInsets.only(
                  left: math.max(extra, 0),
                  right: math.max(extra, 0),
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
              );
            },
          ),
        ],
      ),
    );
  }
}


/// 动态详情(博客正文)的加载骨架:正文内容形(头像行 + 正文行 + 图文
/// 占位),与 DynamicPanel isDetail 版式对应;不用列表卡片骨架
/// (头像+操作行形状与正文页不符)。
class BlogContentSkeleton extends StatelessWidget {
  const BlogContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final color = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.55,
    );
    Widget bar(double width, {double height = 13, double bottom = 8}) =>
        Container(
          width: width,
          height: height,
          margin: EdgeInsets.only(bottom: bottom),
          color: color,
        );
    return Skeleton(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(100, height: 13, bottom: 5),
                    bar(50, height: 11, bottom: 0),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            bar(double.infinity),
            bar(double.infinity),
            bar(double.infinity),
            bar(280),
            Container(
              width: double.infinity,
              height: 140,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
            ),
            bar(180, bottom: 0),
          ],
        ),
      ),
    );
  }
}
