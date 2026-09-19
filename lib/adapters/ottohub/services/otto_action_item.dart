// OttoHub 操作行按钮。
//
// 复原自原 B站 适配器 ActionItem(bb7d917 快照):28px 图标 + 数值文本
// 的纵向按钮,InkWell 圆角 6,选中态取 primary 色。三连动画参数保留
// 但 OttoHub 未接入三连,传 null 即可。

import 'package:skf/common/widgets/custom_arc.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:flutter/material.dart';

class OttoActionItem extends StatelessWidget {
  const OttoActionItem({
    super.key,
    required this.icon,
    this.selectIcon,
    this.onTap,
    this.onLongPress,
    this.text,
    this.selectStatus = false,
    required this.semanticsLabel,
    this.expand = true,
    this.animation,
    this.onStartTriple,
    this.onCancelTriple,
  }) : assert(!selectStatus || selectIcon != null),
       _isThumbsUp = onStartTriple != null;

  final Icon icon;
  final Icon? selectIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? text;
  final bool selectStatus;
  final String semanticsLabel;
  final bool expand;
  final Animation<double>? animation;
  final VoidCallback? onStartTriple;
  final void Function([bool])? onCancelTriple;
  final bool _isThumbsUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    late final primary = !expand && theme.brightness == .light
        ? colorScheme.inversePrimary
        : colorScheme.primary;
    Widget child = Icon(
      selectStatus ? selectIcon!.icon! : icon.icon,
      size: 18,
      color: selectStatus ? primary : icon.color ?? colorScheme.outline,
      semanticLabel: semanticsLabel,
    );

    if (animation != null) {
      child = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: animation!,
            builder: (context, child) =>
                Arc(size: 28, color: primary, progress: -animation!.value),
          ),
          child,
        ],
      );
    } else {
      child = SizedBox.square(dimension: 28, child: child);
    }

    child = Material(
      type: .transparency,
      child: InkWell(
        borderRadius: const .all(.circular(6)),
        onTap: _isThumbsUp ? null : onTap,
        onLongPress: _isThumbsUp ? null : onLongPress,
        onSecondaryTap: PlatformUtils.isMobile || _isThumbsUp
            ? null
            : onLongPress,
        onTapDown: _isThumbsUp ? (_) => onStartTriple!() : null,
        onTapUp: _isThumbsUp ? (_) => onCancelTriple!(true) : null,
        onTapCancel: _isThumbsUp ? onCancelTriple : null,
        child: expand
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [child, _buildText(theme)],
              )
            : child,
      ),
    );
    return expand ? Expanded(child: child) : child;
  }

  Widget _buildText(ThemeData theme) {
    final hasText = text != null;
    final child = Text(
      hasText ? text! : '-',
      key: hasText ? ValueKey(text!) : null,
      style: TextStyle(
        color: selectStatus
            ? theme.colorScheme.primary
            : theme.colorScheme.outline,
        fontSize: theme.textTheme.labelSmall!.fontSize,
      ),
    );
    if (hasText) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: child,
      );
    }
    return child;
  }
}
