import 'package:skf/common/skeleton/skeleton.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter/material.dart';

class DynamicCardSkeleton extends StatelessWidget {
  const DynamicCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // surfaceContainerHighest 在明暗两套主题下都与背景保持可见对比
    // (onInverseSurface 在深色主题下是深色块贴深底,几乎不可见)。
    final color = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.55,
    );
    final buttonStyle = TextButton.styleFrom(
      tapTargetSize: .padded,
      padding: const .symmetric(horizontal: 15),
      foregroundColor: theme.colorScheme.outline.withValues(
        alpha: 0.2,
      ),
    );
    return Skeleton(
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 8,
              color: theme.dividerColor.withValues(alpha: 0.05),
            ),
          ),
        ),
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
                    Container(
                      color: color,
                      width: 100,
                      height: 13,
                      margin: const EdgeInsets.only(bottom: 5),
                    ),
                    Container(
                      color: color,
                      width: 50,
                      height: 11,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              color: color,
              width: double.infinity,
              height: 13,
              margin: const EdgeInsets.only(bottom: 7),
            ),
            Container(
              color: color,
              width: double.infinity,
              height: 13,
              margin: const EdgeInsets.only(bottom: 7),
            ),
            Container(
              color: color,
              width: 300,
              height: 13,
              margin: const EdgeInsets.only(bottom: 7),
            ),
            Container(
              color: color,
              width: 250,
              height: 13,
              margin: const EdgeInsets.only(bottom: 7),
            ),
            Container(
              color: color,
              width: 100,
              height: 13,
              margin: const EdgeInsets.only(bottom: 7),
            ),
            if (Pref.dynamicsWaterfallFlow) const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const ['转发', '评论', '点赞']
                  .map(
                    (e) => TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.radio_button_unchecked_outlined,
                        size: 20,
                      ),
                      style: buttonStyle,
                      label: Text(e),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
