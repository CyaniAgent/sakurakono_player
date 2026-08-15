import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/pages/dynamics/dynamics_host.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/num_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ActionPanel extends StatelessWidget {
  const ActionPanel({
    super.key,
    required this.item,
  });
  final CoreDynamicItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;
    final moduleStat = item.modules!.moduleStat!;
    final forward = moduleStat.forward!;
    final comment = moduleStat.comment!;
    final like = moduleStat.like!;
    final btnStyle = TextButton.styleFrom(
      tapTargetSize: .padded,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      foregroundColor: outline,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Builder(
            builder: (context) {
              return TextButton.icon(
                onPressed: () => DynamicsHost.of().showRepostPanel(
                  context,
                  item,
                  () {
                    int count = forward.count ?? 0;
                    forward.count = count + 1;
                    if (context.mounted) {
                      (context as Element?)?.markNeedsBuild();
                    }
                  },
                ),
                icon: Icon(
                  FontAwesomeIcons.shareFromSquare,
                  size: 16,
                  color: outline,
                  semanticLabel: "转发",
                ),
                style: btnStyle,
                label: Text(
                  forward.count != null
                      ? NumUtils.numFormat(forward.count)
                      : '转发',
                ),
              );
            },
          ),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: () => DynamicsHost.of().pushDynDetail(
              item,
              isPush: true,
              viewComment: true,
            ),
            icon: Icon(
              FontAwesomeIcons.comment,
              size: 16,
              color: outline,
              semanticLabel: "评论",
            ),
            style: btnStyle,
            label: Text(
              comment.count != null ? NumUtils.numFormat(comment.count) : '评论',
            ),
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              final IconData icon;
              final Color color;
              final String label;
              if (like.status ?? false) {
                icon = FontAwesomeIcons.solidThumbsUp;
                color = primary;
                label = '已赞';
              } else {
                icon = FontAwesomeIcons.thumbsUp;
                color = outline;
                label = '点赞';
              }
              final likeIcon = Icon(
                icon,
                size: 16,
                color: color,
                semanticLabel: label,
              );
              return TextButton.icon(
                onPressed: () => _onLike(
                  likeIcon.color == primary,
                  () {
                    if (context.mounted) {
                      (context as Element?)?.markNeedsBuild();
                    }
                  },
                ),
                icon: likeIcon,
                style: btnStyle,
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    like.count != null ? NumUtils.numFormat(like.count) : '点赞',
                    key: ValueKey<int?>(like.count),
                    style: TextStyle(color: like.status! ? primary : outline),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onLike(bool uiStatus, VoidCallback onSuccess) async {
    feedBack();
    final like = item.modules?.moduleStat?.like;
    final status = like?.status ?? false;
    if (status ^ uiStatus) {
      SmartDialog.showToast(status ? '点赞成功' : '取消点赞');
      onSuccess();
      return;
    }
    final res = await Get.find<DynamicsRepository>().thumbDynamic(
      dynamicId: item.idStr!,
      up: status ? 2 : 1,
    );
    if (res.isSuccess) {
      SmartDialog.showToast(status ? '取消点赞' : '点赞成功');
      like
        ?..count = (like.count ?? 0) + (status ? -1 : 1)
        ..status = !status;
      onSuccess();
    } else {
      res.toast();
    }
  }
}
