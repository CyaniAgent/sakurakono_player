// 评论条目(复原原 ReplyItemGrpc 版式:34px 挂件头像 + 用户名/UP徽章 +
// 时间行 + 正文 + 回复/点赞操作行 + 二级回复数;分隔线 indent 55)。
// OttoHub 数据不含等级/挂件/IP归属,相应元素按缺省隐藏。
// 视频评论面板与动态详情页共用。

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:skf/common/widgets/badge.dart';
import 'package:skf/core/models/ui/badge_type.dart';
import 'package:skf/common/widgets/pendant_avatar.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/date_utils.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/num_utils.dart';

class OttoReplyItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: item.rcount > 0
            ? onOpenDetail ??
                  () => SmartDialog.showToast('暂不支持查看回复详情')
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
        if (item.rcount > 0)
          Text(
            '共 ${item.rcount} 条回复',
            style: textStyle.copyWith(color: colorScheme.secondary),
          ),
        const Spacer(),
        // 回复按钮靠右,与点赞同侧更易单手触达。
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
        if (item.like > 0) ...[
          const SizedBox(width: 12),
          Icon(
            Icons.thumb_up_alt_outlined,
            size: 16,
            color: colorScheme.outline.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 3),
          Text(NumUtils.numFormat(item.like), style: textStyle),
          const SizedBox(width: 5),
        ],
      ],
    );
  }
}
