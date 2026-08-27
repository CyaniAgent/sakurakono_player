import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/select_mask.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/fav/note/controller.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:flutter/material.dart';

class FavNoteItem extends StatelessWidget {
  const FavNoteItem({
    super.key,
    required this.item,
    required this.ctr,
    required this.onSelect,
    this.onOpen,
  });

  final CoreFavNoteItemModel item;
  final FavNoteController ctr;
  final VoidCallback onSelect;

  /// 打开笔记网页（适配器注入，见 FavActions.onHandleWebview）。
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
      child: InkWell(
        onTap: () {
          if (ctr.enableMultiSelect) {
            onSelect();
            return;
          }
          if (item.webUrl?.isNotEmpty == true) {
            onOpen?.call();
          }
        },
        onLongPress: onLongPress,
        onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Style.safeSpace,
            vertical: 5,
          ),
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.pic?.isNotEmpty == true)
                AspectRatio(
                  aspectRatio: Style.aspectRatio,
                  child: LayoutBuilder(
                    builder: (context, boxConstraints) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          NetworkImgLayer(
                            src: item.pic,
                            width: boxConstraints.maxWidth,
                            height: boxConstraints.maxHeight,
                          ),
                          Positioned.fill(
                            child: selectMask(
                              colorScheme,
                              item.checked,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.summary ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1,
                        color: colorScheme.outline,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.message ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
