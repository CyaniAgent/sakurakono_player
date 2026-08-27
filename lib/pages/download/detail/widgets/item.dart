import 'dart:async';
import 'dart:io';

import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/badge.dart';
import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/common/widgets/dialog/simple_dialog_option.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/progress_bar/video_progress_indicator.dart';
import 'package:skf/common/widgets/select_mask.dart';
import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/models/ui/badge_type.dart';
import 'package:skf/pages/common/multi_select/base.dart';
import 'package:skf/pages/download/download_actions.dart';
import 'package:skf/pages/download/downloading/view.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/cache_manager.dart';
import 'package:skf/utils/duration_utils.dart';
import 'package:skf/utils/extension/num_ext.dart';
import 'package:skf/utils/path_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

/// Bridges a GetX [RxInterface] stream to Flutter [Listenable] so
/// [ListenableBuilder] can react to rx changes (Rx is not a [Listenable]
/// in this fork).
class _RxListenable<T> extends ChangeNotifier {
  _RxListenable(Stream<T> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Memoizes one bridge per rx instance (rx instances are long-lived on the
/// actions singleton; the bridge lives as long as the rx it wraps).
final _progressBridges = <Object, _RxListenable>{};

_RxListenable _progressBridge(Rxn<CoreDownloadEntryInfo> rx) =>
    _progressBridges.putIfAbsent(rx, () => _RxListenable(rx.stream));

/// 条目右上角更多按钮（详情页/详情列表通用；导航动作由 [actions] 注入）。
Widget entryMoreBtn({
  required CoreDownloadEntryInfo entry,
  required ColorScheme colorScheme,
  required DownloadActions actions,
}) => SizedBox(
  width: 29,
  height: 29,
  child: PopupMenuButton(
    padding: EdgeInsets.zero,
    position: PopupMenuPosition.under,
    icon: Icon(
      Icons.more_vert_outlined,
      color: colorScheme.outline,
      size: 18,
    ),
    itemBuilder: (_) => [
      PopupMenuItem(
        height: 38,
        child: const Text('查看详情页', style: TextStyle(fontSize: 13)),
        onTap: () => actions.viewDetail(entry),
      ),
      if (PlatformUtils.isDesktop)
        PopupMenuItem(
          height: 38,
          child: const Text('打开本地文件夹', style: TextStyle(fontSize: 13)),
          onTap: () async {
            try {
              final String executable;
              if (Platform.isWindows) {
                executable = 'explorer';
              } else if (Platform.isMacOS) {
                executable = 'open';
              } else if (Platform.isLinux) {
                executable = 'xdg-open';
              } else {
                throw UnimplementedError();
              }
              await Process.run(executable, [entry.entryDirPath]);
            } catch (e) {
              SmartDialog.showToast(e.toString());
            }
          },
        ),
      if (entry.ownerId case final mid?)
        PopupMenuItem(
          height: 38,
          child: Text(
            '访问${entry.ownerName != null ? '：${entry.ownerName}' : '用户主页'}',
            style: const TextStyle(fontSize: 13),
          ),
          onTap: () => AppNavigator.toNamed('/member?mid=$mid'),
        ),
    ],
  ),
);

class DetailItem extends StatelessWidget {
  const DetailItem({
    super.key,
    required this.entry,
    this.progress,
    required this.actions,
    this.onDelete,
    required this.showTitle,
    this.isCurr = false,
    //
    required this.controller,
    this.checked,
    this.onSelect,
  });

  final CoreDownloadEntryInfo entry;
  final ChangeNotifier? progress;
  final DownloadActions actions;
  final VoidCallback? onDelete;
  final bool showTitle;
  final bool isCurr;
  //
  final MultiSelectBase controller;
  final bool? checked;
  final ValueChanged<CoreDownloadEntryInfo>? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;
    final cid = entry.source?.cid ?? entry.pageData?.cid;
    final canDel = onDelete != null;
    final enableMultiSelect = controller.enableMultiSelect;
    void onLongPress() => canDel && !enableMultiSelect
        ? showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              clipBehavior: Clip.hardEdge,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                DialogOption(
                  onPressed: () {
                    AppNavigator.back();
                    showConfirmDialog(
                      context: context,
                      title: const Text('确定删除该视频？'),
                      onConfirm: onDelete,
                    );
                  },
                  child: const Text('删除', style: TextStyle(fontSize: 14)),
                ),
                DialogOption(
                  onPressed: () async {
                    AppNavigator.back();
                    final res = await actions.downloadDanmaku(
                      entry: entry,
                      isUpdate: true,
                    );
                    if (res) {
                      SmartDialog.showToast('更新成功');
                    } else {
                      SmartDialog.showToast('更新失败');
                    }
                  },
                  child: const Text('更新弹幕', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          )
        : null;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () async {
          if (!canDel) {
            AppNavigator.to(const DownloadingPage());
            return;
          }
          if (enableMultiSelect) {
            (onSelect ?? controller.onSelect).call(entry);
            return;
          }
          if (entry.isCompleted) {
            await actions.playLocal(entry);
            if (context.mounted) {
              Future.delayed(const Duration(milliseconds: 400), () {
                if (context.mounted) {
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  progress?.notifyListeners();
                }
              });
            }
          } else {
            final curDownload = actions.curDownload.value;
            if (curDownload != null &&
                curDownload.cid == cid &&
                curDownload.status.isDownloading) {
              actions.cancelDownload(
                isDelete: false,
                downloadNext: false,
              );
            } else {
              actions.startDownload(entry);
            }
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
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AspectRatio(
                    aspectRatio: Style.aspectRatio,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cover = File(
                          path.join(entry.entryDirPath, PathUtils.coverName),
                        );
                        final maxWidth = constraints.maxWidth;
                        final maxHeight = constraints.maxHeight;
                        int? cacheWidth, cacheHeight;
                        if (entry.pageData?.cacheWidth ?? false) {
                          cacheWidth = maxWidth.cacheSize(context);
                        } else {
                          cacheHeight = maxHeight.cacheSize(context);
                        }
                        return cover.existsSync()
                            ? ClipRRect(
                                borderRadius: Style.mdRadius,
                                child: Image.file(
                                  cover,
                                  width: maxWidth,
                                  height: maxHeight,
                                  fit: BoxFit.cover,
                                  cacheWidth: cacheWidth,
                                  cacheHeight: cacheHeight,
                                  colorBlendMode: NetworkImgLayer.reduce
                                      ? BlendMode.modulate
                                      : null,
                                  color: NetworkImgLayer.reduce
                                      ? NetworkImgLayer.reduceLuxColor
                                      : null,
                                ),
                              )
                            : NetworkImgLayer(
                                src: entry.cover,
                                width: maxWidth,
                                height: maxHeight,
                                cacheWidth: entry.pageData?.cacheWidth,
                              );
                      },
                    ),
                  ),
                  if (actions.qualityShortDesc(entry.videoQuality)
                      case final qualityDesc?)
                    PBadge(
                      text: qualityDesc,
                      right: 6.0,
                      top: 6.0,
                      type: CorePBadgeType.gray,
                    ),
                  if (progress != null)
                    ListenableBuilder(
                      listenable: progress!,
                      builder: (_, _) {
                        final progress = GStorage.watchProgress.get(
                          cid.toString(),
                        );
                        if (progress != null) {
                          return Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                VideoProgressIndicator(
                                  color: theme.colorScheme.primary,
                                  backgroundColor:
                                      theme.colorScheme.secondaryContainer,
                                  progress: progress / entry.totalTimeMilli,
                                ),
                                PBadge(
                                  text: progress >= entry.totalTimeMilli - 400
                                      ? '已看完'
                                      : '${DurationUtils.formatDuration(
                                              progress ~/ 1000,
                                            )}/'
                                            '${DurationUtils.formatDuration(
                                              entry.totalTimeMilli ~/ 1000,
                                            )}',
                                  right: 6,
                                  bottom: 7,
                                  type: CorePBadgeType.gray,
                                ),
                              ],
                            ),
                          );
                        }
                        return PBadge(
                          text: DurationUtils.formatDuration(
                            entry.totalTimeMilli ~/ 1000,
                          ),
                          right: 6.0,
                          bottom: 7.0,
                          type: CorePBadgeType.gray,
                        );
                      },
                    )
                  else if (entry.totalTimeMilli != 0)
                    PBadge(
                      text: DurationUtils.formatDuration(
                        entry.totalTimeMilli ~/ 1000,
                      ),
                      right: 6,
                      bottom: 7,
                      type: CorePBadgeType.gray,
                    ),
                  Positioned.fill(
                    child: selectMask(
                      theme.colorScheme,
                      checked ?? entry.checked,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showTitle ? entry.title : entry.showTitle,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: theme.textTheme.bodyMedium!.fontSize,
                            height: 1.42,
                            letterSpacing: 0.3,
                          ),
                          maxLines: showTitle
                              ? entry.ep != null
                                    ? 1
                                    : 2
                              : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showTitle) ...[
                          if (entry.pageData?.part case final part?)
                            if (part != entry.title)
                              Text(
                                part,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          if (entry.ep?.showTitle case final showTitle?)
                            Text(
                              showTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ],
                    ),
                    if (entry.isCompleted) ...[
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Text(
                          '${CacheManager.formatSize(entry.totalBytes)}${entry.ownerName != null ? '  ${entry.ownerName}' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: outline,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: entryMoreBtn(
                          entry: entry,
                          colorScheme: theme.colorScheme,
                          actions: actions,
                        ),
                      ),
                    ] else
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: isCurr
                            ? RepaintBoundary(
                                child: ListenableBuilder(
                                  listenable: _progressBridge(
                                    actions.curDownload,
                                  ),
                                  builder: (_, _) {
                                    final curDownload =
                                        actions.curDownload.value;
                                    if (curDownload != null) {
                                      final status = curDownload.status;
                                      final color =
                                          status != CoreDownloadStatus.pause
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outline;
                                      return progressWidget(
                                        statusMsg: status.message,
                                        progressStr:
                                            status ==
                                                    CoreDownloadStatus
                                                        .downloading ||
                                                status == CoreDownloadStatus.pause
                                            ? '${CacheManager.formatSize(curDownload.downloadedBytes)}/${CacheManager.formatSize(curDownload.totalBytes)}'
                                            : '',
                                        progress: curDownload.totalBytes == 0
                                            ? 0
                                            : curDownload.downloadedBytes /
                                                  curDownload.totalBytes,
                                        color: color,
                                        highlightColor: theme.highlightColor,
                                      );
                                    }
                                    return entryProgress(theme);
                                  },
                                ),
                              )
                            : entryProgress(theme),
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

  Widget entryProgress(ThemeData theme) => progressWidget(
    statusMsg: entry.status.message,
    progressStr: entry.totalBytes == 0
        ? ''
        : '${CacheManager.formatSize(entry.downloadedBytes)}/${CacheManager.formatSize(entry.totalBytes)}',
    progress: entry.totalBytes == 0
        ? 0
        : entry.downloadedBytes / entry.totalBytes,
    color: theme.colorScheme.outline,
    highlightColor: theme.highlightColor,
  );

  Widget progressWidget({
    required String statusMsg,
    required String progressStr,
    required double progress,
    required Color color,
    required Color highlightColor,
  }) {
    return Column(
      spacing: 6,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              statusMsg,
              style: TextStyle(
                fontSize: 12,
                height: 1,
                color: color,
              ),
            ),
            Text(
              progressStr,
              style: TextStyle(
                fontSize: 12,
                height: 1,
                color: color,
              ),
            ),
          ],
        ),
        LinearProgressIndicator(
          // ignore: deprecated_member_use
          year2023: true,
          minHeight: 2.5,
          borderRadius: Style.mdRadius,
          color: color,
          backgroundColor: highlightColor,
          value: progress,
        ),
      ],
    );
  }
}
