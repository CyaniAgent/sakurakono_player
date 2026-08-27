import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/badge.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/progress_bar/video_progress_indicator.dart';
import 'package:skf/common/widgets/select_mask.dart';
import 'package:skf/core/models/search_types.dart' show CoreDimension;
import 'package:skf/core/models/ui/badge_type.dart';
import 'package:skf/core/models/user_types.dart' show CoreHistoryItemModel;
import 'package:skf/pages/common/multi_select/base.dart';
import 'package:skf/pages/history/history_actions.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/date_utils.dart';
import 'package:skf/utils/duration_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HistoryItem extends StatelessWidget {
  final CoreHistoryItemModel item;
  final MultiSelectBase ctr;
  final void Function(int kid, String business) onDelete;
  final Ref? ref;

  /// 导航契约（适配器注入），null 时对应导航动作禁用。
  final HistoryActions? actions;

  const HistoryItem({
    super.key,
    required this.item,
    required this.ctr,
    required this.onDelete,
    this.ref,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDuration = item.duration != null && item.duration != 0;
    final int aid = item.history.oid!;
    final String? bvid = item.history.bvid;
    final business = item.history.business;
    final enableMultiSelect = ctr.enableMultiSelect;

    final onLongPress = enableMultiSelect
        ? null
        : () {
            (ctr as dynamic).enableMultiSelect = true;
            ctr.onSelect(item);
          };

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: enableMultiSelect
            ? () => ctr.onSelect(item)
            : () async {
                if (business?.contains('article') == true) {
                  AppNavigator.toNamed(
                    '/articlePage',
                    parameters: {
                      'id': business == 'article-list'
                          ? '${item.history.cid}'
                          : '${item.history.oid}',
                      'type': 'read',
                    },
                    preventDuplicates: false,
                  );
                } else if (business == 'live') {
                  if (item.liveStatus == 1) {
                    final roomId = item.history.oid;
                    if (roomId != null) {
                      AppNavigator.toNamed(
                        '/liveRoom',
                        arguments: roomId,
                        preventDuplicates: false,
                      );
                    }
                  } else {
                    SmartDialog.showToast('直播未开播');
                  }
                } else if (business == 'pgc') {
                  actions?.onViewPgc?.call(item.history.epid);
                } else if (business == 'cheese') {
                  if (item.uri?.isNotEmpty == true) {
                    actions?.onViewPgcFromUri?.call(
                      item.uri!,
                      isPgc: false,
                      aid: item.history.oid,
                    );
                  }
                } else {
                  int? cid = item.history.cid;
                  CoreDimension? dimension;
                  if (cid == null) {
                    if (await (ref?.read(searchRepositoryProvider) ?? appRead(searchRepositoryProvider)).ab2cWithDimension(
                          aid: aid,
                          bvid: bvid,
                          part: item.history.page,
                        )
                        case final res?) {
                      cid = res.cid;
                      dimension = res.dimension;
                    }
                  }
                  if (cid != null) {
                    actions?.onViewVideo?.call(
                      aid: aid,
                      bvid: bvid,
                      cid: cid,
                      cover: item.cover,
                      title: item.title,
                      dimension: dimension,
                    );
                  }
                }
              },
        onLongPress: onLongPress,
        onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.safeSpace,
                vertical: 5,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: Style.aspectRatio,
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        double maxWidth = boxConstraints.maxWidth;
                        double maxHeight = boxConstraints.maxHeight;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            NetworkImgLayer(
                              src: item.cover?.isNotEmpty == true
                                  ? item.cover
                                  : item.covers?.firstOrNull ?? '',
                              width: maxWidth,
                              height: maxHeight,
                            ),
                            if (hasDuration)
                              PBadge(
                                text: item.progress == -1
                                    ? '已看完'
                                    : '${DurationUtils.formatDuration(item.progress)}/${DurationUtils.formatDuration(item.duration)}',
                                right: 6.0,
                                bottom: 8.0,
                                type: CorePBadgeType.gray,
                              ),
                            if (item.isFav == 1)
                              const PBadge(
                                text: '已收藏',
                                top: 6.0,
                                right: 6.0,
                                type: CorePBadgeType.gray,
                              )
                            else if (item.badge?.isNotEmpty == true)
                              PBadge(
                                text: item.badge,
                                top: 6.0,
                                right: 6.0,
                                type: business == 'live' && item.liveStatus != 1
                                    ? CorePBadgeType.gray
                                    : CorePBadgeType.primary,
                              ),
                            if (hasDuration &&
                                item.progress != null &&
                                item.progress != 0)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: VideoProgressIndicator(
                                  color: theme.colorScheme.primary,
                                  backgroundColor:
                                      theme.colorScheme.secondaryContainer,
                                  progress: item.progress == -1
                                      ? 1
                                      : item.progress! / item.duration!,
                                ),
                              ),
                            Positioned.fill(
                              child: selectMask(
                                theme.colorScheme,
                                item.checked,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  content(theme),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 0,
              width: 29,
              height: 29,
              child: PopupMenuButton(
                padding: EdgeInsets.zero,
                tooltip: '功能菜单',
                icon: Icon(
                  Icons.more_vert_outlined,
                  color: theme.colorScheme.outline,
                  size: 18,
                ),
                position: PopupMenuPosition.under,
                itemBuilder: (_) => [
                  if (item.authorMid != null &&
                      item.authorName?.isNotEmpty == true)
                    PopupMenuItem(
                      onTap: () => AppNavigator.toNamed('/member?mid=${item.authorMid}'),
                      height: 38,
                      child: Row(
                        children: [
                          const Icon(
                            MdiIcons.accountCircleOutline,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '访问：${item.authorName}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  if (business != 'pgc' &&
                      item.badge != '番剧' &&
                      item.tagName?.contains('动画') != true &&
                      business != 'live' &&
                      business?.contains('article') != true)
                    PopupMenuItem(
                      onTap: () =>
                          (ref?.read(userRepositoryProvider) ?? appRead(userRepositoryProvider)).toViewLater(bvid: item.history.bvid),
                      height: 38,
                      child: const Row(
                        children: [
                          Icon(Icons.watch_later_outlined, size: 16),
                          SizedBox(width: 6),
                          Text('稍后再看', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    onTap: () => onDelete(item.kid!, business!),
                    height: 38,
                    child: const Row(
                      children: [
                        Icon(Icons.close_outlined, size: 16),
                        SizedBox(width: 6),
                        Text('删除记录', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget content(ThemeData theme) {
    return Expanded(
      child: Column(
        spacing: 2,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title!,
            style: TextStyle(
              fontSize: theme.textTheme.bodyMedium!.fontSize,
              height: 1.42,
              letterSpacing: 0.3,
            ),
            maxLines: item.videos! > 1 ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.history.business == 'pgc' &&
              item.showTitle?.isNotEmpty == true)
            Text(
              item.showTitle!,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.outline,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),
          if (item.authorName?.isNotEmpty == true)
            Text(
              item.authorName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: theme.textTheme.labelMedium!.fontSize,
                color: theme.colorScheme.outline,
              ),
            ),
          Text(
            DateFormatUtils.chatFormat(item.viewAt!, isHistory: true),
            style: TextStyle(
              fontSize: theme.textTheme.labelMedium!.fontSize,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
