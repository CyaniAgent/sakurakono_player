import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/badge.dart';
import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/select_mask.dart';
import 'package:skf/core/models/ui/badge_type.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/fav/pgc/controller.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:flutter/material.dart';
class FavPgcItem extends StatelessWidget {
  const FavPgcItem({
    super.key,
    required this.item,
    required this.ctr,
    required this.onSelect,
    required this.onUpdateStatus,
    this.onOpen,
  });

  final CoreFavPgcItemModel item;
  final FavPgcController ctr;
  final VoidCallback onSelect;
  final VoidCallback onUpdateStatus;

  /// 打开 PGC（适配器注入，见 FavActions.onViewPgc）。
  final VoidCallback? onOpen;
  void onLongPress() {
    if (!ctr.enableMultiSelect) {
      ctr.enableMultiSelect = true;
      onSelect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () {
              if (ctr.enableMultiSelect) {
                onSelect();
                return;
              }
              onOpen?.call();
            },
            onLongPress: onLongPress,
            onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.safeSpace,
                vertical: 5,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            NetworkImgLayer(
                              src: item.cover,
                              width: boxConstraints.maxWidth,
                              height: boxConstraints.maxHeight,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            PBadge(
                              right: 4,
                              top: 4,
                              text: item.badge,
                              size: CorePBadgeSize.small,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 1,
                              ),
                            ),
                            Positioned.fill(
                              child: selectMask(
                                colorScheme,
                                item.checked,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title!),
                        if (item.newEp?.indexShow != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${item.newEp!.indexShow}${item.isFinish == 0 && item.renewalTime?.isNotEmpty == true ? '，${item.renewalTime}' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (item.progress != null) ...[
                          SizedBox(
                            height: item.newEp?.indexShow != null ? 2 : 6,
                          ),
                          Text(
                            item.progress!,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 0,
            child: iconButton(
              iconSize: 18,
              onPressed: onUpdateStatus,
              icon: const Icon(Icons.more_vert),
              iconColor: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
