import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/mine/mine_actions.dart';
import 'package:flutter/material.dart';

class FavFolderItem extends StatelessWidget {
  const FavFolderItem({
    super.key,
    required this.item,
    required this.onPop,
    required this.heroTag,
  });

  final CoreFavFolderInfo item;
  final VoidCallback onPop;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => MineActions.of().openFavDetail(item, heroTag, onPop),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.onInverseSurface.withValues(
                    alpha: 0.4,
                  ),
                  offset: const Offset(6, -8),
                  blurRadius: 0.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: Hero(
              tag: heroTag,
              child: NetworkImgLayer(
                src: item.cover,
                width: 180,
                height: 110,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ' ${item.title}',
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
          Text(
            ' 共${item.mediaCount}条视频 · ${isPublicFavText(item.attr)}',
            style: theme.textTheme.labelSmall!.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// 收藏夹公开性文案（迁移自 adapter utils/bili_utils.dart，纯逻辑副本）。
String isPublicFavText(int? attr) {
  if (attr == null) {
    return '';
  }
  return (attr & 1) == 0 ? '公开' : '私密';
}
