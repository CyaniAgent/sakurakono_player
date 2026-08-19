import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/core/models/ui/image_type.dart';
import 'package:skf/core/models/follow_item.dart' show CoreFollowItemModel;
import 'package:skf/router/app_navigator.dart';
import 'package:flutter/material.dart';

class FollowTypeItem extends StatelessWidget {
  const FollowTypeItem({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
  });

  final CoreFollowItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: InkWell(
        onTap: onTap ?? () => AppNavigator.toNamed('/member?mid=${item.mid}'),
        onLongPress: onLongPress,
        onSecondaryTap: onSecondaryTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Row(
            spacing: 10,
            children: [
              NetworkImgLayer(
                width: 45,
                height: 45,
                type: CoreImageType.avatar,
                src: item.face,
              ),
              Expanded(
                child: Column(
                  spacing: 3,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.uname!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (item.sign case final sign?)
                      Text(
                        sign,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorScheme.of(context).outline,
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
