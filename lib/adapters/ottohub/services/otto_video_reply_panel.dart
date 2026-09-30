// OttoHub 视频评论列表面板。
//
// 版式复原自原 B站 适配器 VideoReplyPanel(bb7d917 快照):悬浮排序头 +
// 骨架屏 + 分页列表 + 滚动隐现的「发表评论」FAB。数据来自
// ReplyRepository.mainList(OttoHub 约定:type=2 视频评论,oid = vid,
// 按 offset 翻页,页大小 20)。二级回复预览/排序等 OttoHub SDK 未提供
// 的能力按降级处理(隐藏或 toast)。
// 回复条目版式见 [_OttoReplyTile](复原 ReplyItemGrpc 的头区/正文/操作行)。

import 'package:easy_debounce/easy_throttle.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';

import 'package:skf/adapters/ottohub/services/otto_reply_item.dart';
import 'package:skf/adapters/ottohub/services/otto_reply_pub_page.dart';
import 'package:skf/adapters/ottohub/services/otto_dynamics_pages.dart'
    show OttoReplyDetailPage;
import 'package:skf/adapters/ottohub/services/otto_video_page_hub.dart';
import 'package:skf/common/skeleton/video_reply.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/sliver/sliver_floating_header.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/fab_mixin.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/grid.dart';

class OttoVideoReplyPanel extends StatefulWidget {
  const OttoVideoReplyPanel({
    super.key,
    required this.hub,
    required this.heroTag,
    required this.vid,
    this.isNested = false,
  });

  final OttoVideoPageHub hub;
  final String heroTag;

  /// OttoHub 视频 ID(评论 oid)。
  final int vid;
  final bool isNested;

  @override
  State<OttoVideoReplyPanel> createState() => _OttoVideoReplyPanelState();
}

class _OttoVideoReplyPanelState extends State<OttoVideoReplyPanel>
    with
        AutomaticKeepAliveClientMixin,
        SingleTickerProviderStateMixin,
        BaseFabMixin,
        FabMixin {
  static const _pageSize = 20;

  late ColorScheme colorScheme;
  late double bottom;

  final _scrollCtr = ScrollController();
  List<CoreReplyItem> _items = <CoreReplyItem>[];

  /// 服务端已返回的评论数(本地插入不计,保证翻页 offset 正确)。
  int _serverReplyCount = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _firstLoaded = false;
  String? _errMsg;
  int? _upMid;

  String get heroTag => widget.heroTag;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.hub.replyScrollCtrs[widget.heroTag] = _scrollCtr;
    _query();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorScheme = ColorScheme.of(context);
    bottom = MediaQuery.viewPaddingOf(context).bottom;
  }

  @override
  void dispose() {
    if (identical(widget.hub.replyScrollCtrs[widget.heroTag], _scrollCtr)) {
      widget.hub.replyScrollCtrs.remove(widget.heroTag);
    }
    _scrollCtr.dispose();
    super.dispose();
  }

  int? get _vid => widget.vid > 0 ? widget.vid : null;

  Future<void> _query() async {
    if (_isLoading || _vid == null) return;
    _isLoading = true;
    final res = await appRead(replyRepositoryProvider).mainList(
      type: 2,
      oid: _vid!,
      mode: CoreMode.defaultMode,
      offset: null,
      cursorNext: null,
    );
    if (!mounted) return;
    _isLoading = false;
    switch (res) {
      case Success(:final response):
        setState(() {
          _items = (response.replies ?? const <Object?>[])
              .whereType<Map<String, dynamic>>()
              .map(CoreReplyItem.fromMap)
              .toList();
          _serverReplyCount = _items.length;
          _hasMore = _items.length >= _pageSize;
          _firstLoaded = true;
          _errMsg = null;
          _upMid = widget.hub.state(heroTag).upMid;
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

  void _onLoadMore() {
    if (_isLoading || !_hasMore || !_firstLoaded) return;
    EasyThrottle.throttle(
      'otto-reply-load-more-$heroTag',
      const Duration(milliseconds: 500),
      () async {
        _isLoading = true;
        final res = await appRead(replyRepositoryProvider).mainList(
          type: 2,
          oid: _vid!,
          mode: CoreMode.defaultMode,
          // 本地插入的评论不计入 offset,避免翻页错位。
          offset: '$_serverReplyCount',
          cursorNext: null,
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
              _items.addAll(page);
              _serverReplyCount += page.length;
              _hasMore = page.length >= _pageSize;
            });
          case Error():
            setState(() => _hasMore = false);
          case Loading():
            break;
        }
      },
    );
  }

  /// 评论草稿(打开面板未发送时由 onSave 持久化,再次打开回填)。
  String? _replyDraft;

  Future<void> _showReplyInput([CoreReplyItem? parent]) async {
    final vid = _vid;
    if (vid == null) return;
    final message = await showOttoReplySheet(
      oid: vid,
      parent: parent?.rpid,
      hint: parent == null ? '输入评论内容' : ' 回复 @${parent.member?.uname} : ',
      initialValue: _replyDraft,
      onSave: (text) => _replyDraft = text.isEmpty ? null : text,
    );
    if (message == null || message.isEmpty || !mounted) return;
    // 本地插入(发送成功即时上屏,免整页刷新)。
    final account = appRead(accountProvider);
    final mid = account.userId ?? 0;
    final member = CoreReplyMember(
      mid: mid,
      uname: account.displayName ?? '',
      avatar: account.face,
    );
    final item = CoreReplyItem(
      oid: vid,
      mid: mid,
      parent: parent?.rpid ?? 0,
      content: message,
      ctime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      member: member,
    );
    setState(() {
      if (parent == null) {
        _items.insert(0, item);
        widget.hub.state(heroTag).commentCount += 1;
      } else {
        // 二级回复列表不在本面板展开,仅本地累加父评论计数。
        final index = _items.indexWhere((e) => e.rpid == parent.rpid);
        if (index != -1) {
          final old = _items[index];
          _items[index] = CoreReplyItem(
            rpid: old.rpid,
            oid: old.oid,
            type: old.type,
            mid: old.mid,
            root: old.root,
            parent: old.parent,
            like: old.like,
            rcount: old.rcount + 1,
            content: old.content,
            ctime: old.ctime,
            member: old.member,
            likeState: old.likeState,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final child = NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        switch (notification.direction) {
          case .forward:
            showFab();
          case .reverse:
            hideFab();
          case _:
        }
        return false;
      },
      child: refreshIndicator(
        onRefresh: _query,
        isClampingScrollPhysics: widget.isNested,
        child: Stack(
          clipBehavior: .none,
          children: [
            CustomScrollView(
              controller: _scrollCtr,
              physics: const AlwaysScrollableScrollPhysics(),
              key: const PageStorageKey(_OttoVideoReplyPanelState),
              slivers: [
                SliverFloatingHeaderWidget(
                  backgroundColor: colorScheme.surface,
                  child: Padding(
                    padding: const .fromLTRB(12, 2.5, 6, 2.5),
                    child: ListenableBuilder(
                      listenable: widget.hub.state(heroTag),
                      builder: (context, _) {
                        final count = widget.hub.state(heroTag).commentCount;
                        return Row(
                          children: [
                            Text(
                              count > 0 ? '全部评论 ($count)' : '全部评论',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                _buildBody(),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: fabAnimation,
                child: Padding(
                  padding: .only(
                    right: kFloatingActionButtonMargin,
                    bottom: kFloatingActionButtonMargin + bottom,
                  ),
                  child: FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      feedBack();
                      _showReplyInput();
                    },
                    tooltip: '发表评论',
                    child: const Icon(Icons.reply),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (widget.isNested) {
      return ExtendedVisibilityDetector(
        uniqueKey: const ValueKey(OttoVideoReplyPanel),
        child: child,
      );
    }
    return child;
  }

  Widget _buildBody() {
    if (!_firstLoaded) {
      if (_errMsg == null) {
        return SliverList.builder(
          itemBuilder: (context, index) => const VideoReplySkeleton(),
          itemCount: Grid.lineSkeletonCount(MediaQuery.heightOf(context)),
        );
      }
      return HttpError(errMsg: _errMsg, onReload: _query);
    }
    if (_items.isEmpty) {
      return const HttpError(isNotFound: true, errMsg: '还没有评论');
    }
    return SliverList.builder(
      itemBuilder: (context, index) {
        if (index == _items.length) {
          _onLoadMore();
          return Container(
            height: 125,
            alignment: .center,
            margin: .only(bottom: bottom),
            child: Text(
              _hasMore ? '加载中...' : '没有更多了',
              textAlign: .center,
              style: TextStyle(fontSize: 12, color: colorScheme.outline),
            ),
          );
        }
        return OttoReplyItem(
          item: _items[index],
          upMid: _upMid,
          onReply: () => _showReplyInput(_items[index]),
          onOpenDetail: _items[index].rcount > 0
              ? () => OttoReplyDetailPage.to(
                  context,
                  _items[index],
                  replyType: 2,
                )
              : null,
        );
      },
      itemCount: _items.length + 1,
    );
  }
}
