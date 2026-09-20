// OttoHub 用户页扩展 tab(投稿 / 动态)。
//
// 版式沿用相关视频面板的 OttoVideoCardH(复原原 VideoCardH)与博客卡片。
// 数据:投稿走 Core MemberRepository.spaceArchive(OttoHub 实现 →
// /video/user/{uid});动态走 ottoBlogRepositoryProvider(适配器内部博客
// 仓库 → /blog/users/{uid}/blogs)。

import 'package:flutter/material.dart';

import 'package:skf/adapters/ottohub/services/otto_video_related_panel.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart'
    show refreshIndicator;
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/skeleton/dynamic_card.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/dynamics_types.dart' show CoreDynamicItemModel;
import 'package:skf/core/models/member_types.dart' hide CoreDynamicItemModel;
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/utils/grid.dart';

/// 用户投稿网格 tab。
class OttoMemberArchiveTab extends StatefulWidget {
  const OttoMemberArchiveTab({super.key, required this.mid});

  final int mid;

  @override
  State<OttoMemberArchiveTab> createState() => _OttoMemberArchiveTabState();
}

class _OttoMemberArchiveTabState extends State<OttoMemberArchiveTab>
    with GridMixin {
  List<CoreSpaceArchiveItem> _items = <CoreSpaceArchiveItem>[];
  int _pn = 1;
  bool _hasMore = false;
  bool _isLoading = false;
  bool _firstLoaded = false;
  String? _errMsg;

  @override
  void initState() {
    super.initState();
    _query(more: false);
  }

  Future<void> _query({bool more = false}) async {
    if (_isLoading || (more && !_hasMore)) return;
    _isLoading = true;
    final page = more ? _pn + 1 : 1;
    final res = await appRead(memberRepositoryProvider).spaceArchive(
      type: CoreContributeType.video,
      mid: widget.mid,
      pn: page,
    );
    if (!mounted) return;
    _isLoading = false;
    switch (res) {
      case Success(:final response):
        final pageItems = response.item ?? <CoreSpaceArchiveItem>[];
        setState(() {
          if (more) {
            _items.addAll(pageItems);
            _pn = page;
          } else {
            _items = pageItems;
            _pn = 1;
            _firstLoaded = true;
            _errMsg = null;
          }
          _hasMore = response.hasNext == true && pageItems.isNotEmpty;
        });
      case final Error err:
        if (more) return;
        setState(() {
          _firstLoaded = true;
          _errMsg = err.errMsg ?? '加载失败';
        });
      case Loading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstLoaded) {
      if (_errMsg == null) return gridSkeleton;
      return HttpError(errMsg: _errMsg, onReload: () => _query(more: false));
    }
    if (_items.isEmpty) {
      return refreshIndicator(
        onRefresh: () => _query(more: false),
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('TA还没有投稿')),
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
          SliverGrid.builder(
            gridDelegate: gridDelegate,
            itemBuilder: (context, index) {
              // 原版 MemberVideo:滚动到末尾自动加载下一页。
              if (index == _items.length - 1) _query(more: true);
              return OttoVideoCardH(videoItem: _toCardItem(_items[index]));
            },
            itemCount: _items.length,
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
          ),
        ],
      ),
    );
  }

  /// "yyyy-MM-dd HH:mm:ss" → Unix 秒(卡片日期行)。
  static int? _parseDate(String? text) {
    final t = DateTime.tryParse(text ?? '');
    if (t == null) return null;
    return t.millisecondsSinceEpoch ~/ 1000;
  }

  static CoreHotVideoItemModel _toCardItem(CoreSpaceArchiveItem item) =>
      CoreHotVideoItemModel(
        aid: int.tryParse(item.param ?? '') ?? item.cid,
        bvid: item.bvid ?? item.param,
        cid: item.cid ?? int.tryParse(item.param ?? ''),
        cover: item.cover,
        title: item.title,
        duration: item.duration,
        pubdate: _parseDate(item.publishTimeText),
        stat: <String, dynamic>{'view': item.play, 'danmu': item.danmaku},
      );
}

/// 用户动态 tab(复原原 MemberDynamicsPage:刷新 + DynamicPanel 列表 +
/// 末尾触发的加载更多;数据经 Core MemberRepository.memberDynamic)。
class OttoMemberBlogTab extends StatefulWidget {
  const OttoMemberBlogTab({super.key, required this.mid});

  final int mid;

  @override
  State<OttoMemberBlogTab> createState() => _OttoMemberBlogTabState();
}

class _OttoMemberBlogTabState extends State<OttoMemberBlogTab> {
  List<CoreDynamicItemModel> _items = <CoreDynamicItemModel>[];
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
    final res = await appRead(memberRepositoryProvider).memberDynamic(
      mid: widget.mid,
      offset: more ? '${_items.length}' : null,
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
    final padding = MediaQuery.viewPaddingOf(context);
    if (!_firstLoaded) {
      if (_errMsg == null) {
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (_, _) => const DynamicCardSkeleton(),
        );
      }
      return HttpError(errMsg: _errMsg, onReload: () => _query(more: false));
    }
    if (_items.isEmpty) {
      return refreshIndicator(
        onRefresh: () => _query(more: false),
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('TA还没有动态')),
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
            padding: EdgeInsets.only(bottom: padding.bottom + 100),
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

/// 用户动态独立页(/memberDynamics 路由目标;复用用户动态 tab)。
class OttoMemberDynamicsPage extends StatelessWidget {
  const OttoMemberDynamicsPage({super.key, required this.mid});

  final int mid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动态')),
      body: OttoMemberBlogTab(mid: mid),
    );
  }
}
