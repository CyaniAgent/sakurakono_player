import 'package:skf/common/widgets/selection_text.dart';
import 'package:flutter/material.dart';

class HttpError extends StatelessWidget {
  const HttpError({
    super.key,
    this.isSliver = true,
    this.errMsg,
    this.onReload,
    this.btnText,
    this.safeArea = true,
    this.isNotFound = false,
  });

  final bool isSliver;
  final String? errMsg;
  final VoidCallback? onReload;
  final String? btnText;
  final bool safeArea;

  /// 空态(内容不存在,如「还没有评论」):弱化呈现——小图标 + 单行
  /// 文案,无「加载失败了」标题与重试按钮,区别于真正的加载失败。
  final bool isNotFound;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    if (isNotFound) {
      final empty = Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        children: [
          const SizedBox(height: 28),
          Icon(
            Icons.manage_search_rounded,
            size: 56,
            color: onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            (errMsg == null || errMsg!.isEmpty) ? '暂无内容' : errMsg!,
            textAlign: .center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
        ],
      );
      return isSliver
          ? SliverToBoxAdapter(child: empty)
          : SizedBox(width: double.infinity, child: empty);
    }
    final child = Column(
      mainAxisSize: .min,
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [
        const SizedBox(height: 48),
        // 现代风格:大圆底 + 云朵离线图标,替代旧 SVG 插画。
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: .circle,
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.6,
            ),
          ),
          alignment: .center,
          child: Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '加载失败了',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const .symmetric(horizontal: 24, vertical: 4),
          child: SelectionText(
            (errMsg == null || errMsg!.isEmpty)
                ? '内容走丢了,检查网络后重试'
                : errMsg!,
            textAlign: .center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (onReload != null)
          FilledButton.tonalIcon(
            onPressed: onReload,
            style: FilledButton.styleFrom(
              tapTargetSize: .padded,
              backgroundColor: theme.colorScheme.primary.withAlpha(20),
              shadowColor: Colors.transparent,
            ),
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(
              btnText ?? '重新加载',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        const SizedBox(height: 12),
        if (safeArea)
          SizedBox(height: 40 + MediaQuery.viewPaddingOf(context).bottom),
      ],
    );

    return isSliver
        ? SliverToBoxAdapter(child: child)
        : SizedBox(width: double.infinity, child: child);
  }
}
