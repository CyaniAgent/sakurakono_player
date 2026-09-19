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
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:skf/adapters/ottohub/services/otto_video_page_hub.dart';
import 'package:skf/common/skeleton/video_reply.dart';
import 'package:skf/common/widgets/badge.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/pendant_avatar.dart';
import 'package:skf/common/widgets/sliver/sliver_floating_header.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/models/ui/badge_type.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/fab_mixin.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/date_utils.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/num_utils.dart';

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
          offset: '${_items.length}',
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

  Future<void> _showReplyInput([CoreReplyItem? parent]) async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(parent == null ? '发表评论' : '回复 ${parent.member?.uname}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '输入评论内容'),
        ),
        actions: [
          TextButton(
            onPressed: AppNavigator.back,
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () =>
                AppNavigator.back(result: controller.text.trim()),
            child: const Text('发送'),
          ),
        ],
      ),
    );
    if (message == null || message.isEmpty || !mounted) return;
    final res = await appRead(replyRepositoryProvider).replyAdd(
      type: 2,
      oid: _vid!,
      message: message,
      parent: parent?.rpid,
    );
    if (!mounted) return;
    if (res.isSuccess) {
      SmartDialog.showToast('评论成功');
      _query();
    } else {
      res.toast();
    }
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
          itemCount: 5,
        );
      }
      return HttpError(errMsg: _errMsg, onReload: _query);
    }
    if (_items.isEmpty) {
      return HttpError(errMsg: '还没有评论', onReload: _query);
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
        return _OttoReplyTile(
          item: _items[index],
          upMid: _upMid,
          onReply: () => _showReplyInput(_items[index]),
        );
      },
      itemCount: _items.length + 1,
    );
  }
}

/// 评论条目(复原原 ReplyItemGrpc 版式:34px 挂件头像 + 用户名/UP徽章 +
/// 时间行 + 正文 + 回复/点赞操作行 + 二级回复数;分隔线 indent 55)。
/// OttoHub 数据不含等级/挂件/IP归属,相应元素按缺省隐藏。
class _OttoReplyTile extends StatelessWidget {
  const _OttoReplyTile({
    required this.item,
    required this.upMid,
    required this.onReply,
  });

  final CoreReplyItem item;
  final int? upMid;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: item.rcount > 0
            ? () => SmartDialog.showToast('暂不支持查看回复详情')
            : null,
        child: Column(
          mainAxisSize: .min,
          children: [
            Padding(
              padding: const .fromLTRB(12, 14, 8, 5),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  _buildHeader(context, colorScheme),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: Text(
                      item.content,
                      style: const TextStyle(height: 1.75, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  buttonAction(context, colorScheme),
                ],
              ),
            ),
            Divider(
              indent: 55,
              endIndent: 15,
              height: 0.3,
              color: colorScheme.outline.withValues(alpha: 0.08),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final member = item.member;
    return GestureDetector(
      onTap: () {
        feedBack();
        AppNavigator.toNamed('/member?mid=${item.mid}');
      },
      child: Row(
        crossAxisAlignment: .center,
        spacing: 12,
        children: [
          PendantAvatar(member?.avatar, size: 34),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: 6,
                  children: [
                    Flexible(
                      child: Text(
                        member?.uname ?? '',
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: TextStyle(
                          color: colorScheme.outline,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (item.mid == upMid)
                      const PBadge(
                        text: 'UP',
                        size: CorePBadgeSize.small,
                        isStack: false,
                        fontSize: 9,
                      ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormatUtils.dateFormat(item.ctime),
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonAction(BuildContext context, ColorScheme colorScheme) {
    final textStyle = TextStyle(
      height: 1,
      fontSize: 12,
      fontWeight: .normal,
      color: colorScheme.outline,
    );
    const buttonStyle = ButtonStyle(
      visualDensity: .compact,
      tapTargetSize: .shrinkWrap,
      padding: WidgetStatePropertyAll(.zero),
    );
    return Row(
      children: [
        const SizedBox(width: 36),
        SizedBox(
          height: 32,
          child: TextButton(
            style: buttonStyle,
            onPressed: onReply,
            child: Row(
              spacing: 3,
              mainAxisSize: .min,
              children: [
                Icon(
                  Icons.reply,
                  size: 18,
                  color: colorScheme.outline.withValues(alpha: 0.8),
                ),
                Text('回复', style: textStyle),
              ],
            ),
          ),
        ),
        if (item.rcount > 0) ...[
          const SizedBox(width: 12),
          Text(
            '共 ${item.rcount} 条回复',
            style: textStyle.copyWith(color: colorScheme.secondary),
          ),
        ],
        const Spacer(),
        Icon(
          Icons.thumb_up_alt_outlined,
          size: 16,
          color: colorScheme.outline.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 3),
        Text(NumUtils.numFormat(item.like), style: textStyle),
        const SizedBox(width: 5),
      ],
    );
  }
}
