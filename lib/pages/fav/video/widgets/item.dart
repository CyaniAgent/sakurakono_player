import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/common/cover_ratio.dart';
import 'package:flutter/material.dart';

class FavVideoItem extends StatelessWidget {
  final String heroTag;
  final CoreFavFolderInfo item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSaveImage;

  const FavVideoItem({
    super.key,
    this.onTap,
    this.onLongPress,
    this.onSaveImage,
    required this.heroTag,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        onLongPress:
            onLongPress ?? (onTap == null ? null : onSaveImage),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                // 收藏夹数据无 dimension 字段（核心模型与 SDK 均无宽高），保持 16:10。
                aspectRatio: coverAspectRatio(null, null),
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    return Hero(
                      tag: heroTag,
                      child: NetworkImgLayer(
                        src: item.cover,
                        width: boxConstraints.maxWidth,
                        height: boxConstraints.maxHeight,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              content(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget content(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = theme.textTheme.labelMedium!.fontSize;
    final color = theme.colorScheme.outline;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            textAlign: TextAlign.start,
            style: const TextStyle(
              letterSpacing: 0.3,
            ),
          ),
          if (item.intro?.isNotEmpty == true)
            Text(
              item.intro!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                color: color,
              ),
            ),
          Text(
            '${item.mediaCount}个内容',
            style: TextStyle(
              fontSize: fontSize,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            isPublicFavText(item.attr),
            style: TextStyle(
              fontSize: fontSize,
              color: color,
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
