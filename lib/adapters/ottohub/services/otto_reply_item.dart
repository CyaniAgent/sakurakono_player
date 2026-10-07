// 评论条目(piliotto 版式:34px 头像 + 用户名/头衔徽章/UP徽章 + 时间行 +
// Markdown 正文(>6 行折叠/展开)+ 操作行;底部分隔线 onInverseSurface 50%)。
// OttoHub 数据不含等级/挂件/IP归属/点赞,相应元素按缺省隐藏。
// 视频评论面板与动态详情页共用。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:skf/common/widgets/badge.dart';
import 'package:skf/common/widgets/markdown_text.dart';
import 'package:skf/core/models/ui/badge_type.dart';
import 'package:skf/common/widgets/pendant_avatar.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/date_utils.dart';
import 'package:skf/utils/feed_back.dart';

class OttoReplyItem extends StatefulWidget {
  const OttoReplyItem({
    super.key,
    required this.item,
    required this.upMid,
    required this.onReply,
    this.onOpenDetail,
  });

  final CoreReplyItem item;
  final int? upMid;
  final VoidCallback onReply;

  /// 点击条目进入二级回复页;null 时降级 toast(如视频面板暂无通路)。
  final VoidCallback? onOpenDetail;

  @override
  State<OttoReplyItem> createState() => _OttoReplyItemState();
}

class _OttoReplyItemState extends State<OttoReplyItem> {
  bool _isExpanded = false;

  /// 纯文本评论超过约 6 行时提供折叠/展开(piliotto 同款启发式)。
  bool get _needsExpandButton {
    final message = widget.item.content;
    final lineCount = '\n'.allMatches(message).length + 1;
    final estimatedLines = (message.length / 30).ceil();
    return lineCount > 6 || estimatedLines > 6;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.item.rcount > 0
            ? widget.onOpenDetail ??
                  () => SmartDialog.showToast('暂不支持查看回复详情')
            : null,
        child: Container(
          padding: const .fromLTRB(12, 14, 8, 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: colorScheme.onInverseSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              _buildHeader(context, colorScheme),
              // title
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: _content(context, collapsed: true),
                secondChild: _content(context, collapsed: false),
              ),
              if (_needsExpandButton) _buildExpandButton(context),
              buttonAction(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, {required bool collapsed}) {
    final colorScheme = ColorScheme.of(context);
    return Container(
      margin: const .only(top: 10, left: 45, right: 6, bottom: 4),
      child: collapsed
          ? Stack(
              children: [
                ClipRect(
                  child: SizedBox(
                    height: 147,
                    child: OverflowBox(
                      alignment: .topLeft,
                      maxHeight: double.infinity,
                      child: MarkdownText(
                        widget.item.content,
                        baseStyle: const TextStyle(height: 1.75, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: .topCenter,
                        end: .bottomCenter,
                        colors: [
                          colorScheme.surface.withValues(alpha: 0),
                          colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : MarkdownText(
              widget.item.content,
              baseStyle: const TextStyle(height: 1.75, fontSize: 14),
            ),
    );
  }

  Widget _buildExpandButton(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Padding(
      padding: const .only(left: 45, top: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const .symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: .min,
              children: [
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isExpanded ? '折叠' : '展开',
                  style: TextStyle(color: colorScheme.primary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final member = widget.item.member;
    final honourTitles = (member?.honour ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return GestureDetector(
      onTap: () {
        feedBack();
        AppNavigator.toNamed('/member?mid=${widget.item.mid}');
      },
      child: Row(
        crossAxisAlignment: .center,
        spacing: 12,
        mainAxisSize: .min,
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
                    ...honourTitles.map(
                      (title) => Container(
                        padding: const .symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                    if (widget.item.mid == widget.upMid)
                      const PBadge(
                        text: 'UP',
                        size: CorePBadgeSize.small,
                        isStack: false,
                        fontSize: 9,
                      ),
                  ],
                ),
                Text(
                  DateFormatUtils.dateFormat(widget.item.ctime),
                  style: TextStyle(fontSize: 11, color: colorScheme.outline),
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
        const SizedBox(width: 32),
        if (widget.item.rcount > 0)
          Text(
            '共 ${widget.item.rcount} 条回复',
            style: textStyle.copyWith(color: colorScheme.secondary),
          ),
        const Spacer(),
        // 复制全文(piliotto 同款 more 菜单的常用项)。
        SizedBox(
          height: 32,
          child: IconButton(
            style: buttonStyle,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: widget.item.content));
              SmartDialog.showToast('已复制');
            },
            icon: Icon(
              Icons.more_horiz,
              size: 18,
              color: colorScheme.outline.withValues(alpha: 0.8),
            ),
          ),
        ),
        // 回复按钮靠右,与点赞同侧更易单手触达。
        SizedBox(
          height: 32,
          child: TextButton(
            style: buttonStyle,
            onPressed: widget.onReply,
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
        if (widget.item.like > 0) ...[
          const SizedBox(width: 12),
          Icon(
            Icons.thumb_up_alt_outlined,
            size: 16,
            color: colorScheme.outline.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 3),
          Text('${widget.item.like}', style: textStyle),
          const SizedBox(width: 5),
        ],
      ],
    );
  }
}
