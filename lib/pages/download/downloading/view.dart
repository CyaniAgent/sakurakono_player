import 'package:skf/common/widgets/appbar/appbar.dart';
import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/common/widgets/flutter/pop_scope.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/view_sliver_safe_area.dart';
import 'package:skf/core/models/download_types.dart';
import 'package:skf/pages/common/multi_select/base.dart'
    show BaseMultiSelectMixin;
import 'package:skf/pages/download/detail/widgets/item.dart';
import 'package:skf/pages/download/download_actions.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart'
    hide SliverGridDelegateWithMaxCrossAxisExtent;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class DownloadingPage extends StatefulWidget {
  const DownloadingPage({super.key});

  @override
  State<DownloadingPage> createState() => _DownloadingPageState();
}

class _DownloadingPageState extends State<DownloadingPage>
    with BaseMultiSelectMixin<CoreDownloadEntryInfo>, GridMixin {
  final _downloadActions = DownloadActions.of();
  @override
  List<CoreDownloadEntryInfo> get list => _downloadActions.waitDownloadQueue;
  @override
  void notifyStateChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final enableMultiSelect = this.enableMultiSelect;
      return popScope(
        canPop: !enableMultiSelect,
        onPopInvokedWithResult: (didPop, result) {
          if (enableMultiSelect) {
            handleSelect();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: MultiSelectAppBarWidget(
            ctr: this,
            child: AppBar(
              title: const Text('正在缓存'),
              actions: [
                IconButton(
                  tooltip: '多选',
                  onPressed: () {
                    if (enableMultiSelect) {
                      handleSelect();
                    } else {
                      this.enableMultiSelect = true;
                    }
                  },
                  icon: const Icon(Icons.edit_note),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
          body: CustomScrollView(
            slivers: [
              ViewSliverSafeArea(
                sliver: ListenableBuilder(
                  listenable: _downloadActions,
                  builder: (_, _) {
                    final queue = _downloadActions.waitDownloadQueue;
                    if (queue.isNotEmpty) {
                      return SliverGrid.builder(
                        gridDelegate: gridDelegate,
                        itemCount: queue.length,
                        itemBuilder: (context, index) {
                          final entry = queue[index];
                          final isCurr = entry.cid == _downloadActions.curCid;
                          return DetailItem(
                            entry: entry,
                            actions: _downloadActions,
                            showTitle: true,
                            isCurr: isCurr,
                            onDelete: () => _downloadActions.deleteDownload(
                              entry: entry,
                              removeQueue: true,
                              downloadNext:
                                  isCurr &&
                                  entry.status ==
                                      CoreDownloadStatus.downloading,
                            ),
                            controller: this,
                          );
                        },
                      );
                    }
                    return const HttpError();
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  void onRemove() {
    showConfirmDialog(
      context: context,
      title: const Text('确定删除选中视频？'),
      onConfirm: () async {
        SmartDialog.showLoading();
        final allChecked = this.allChecked.toSet();
        final isDownloading =
            _downloadActions.curDownload?.status ==
            CoreDownloadStatus.downloading;
        for (final entry in allChecked) {
          await _downloadActions.deleteDownload(
            entry: entry,
            refresh: false,
            downloadNext: false,
          );
        }
        _downloadActions.removeFromQueue(allChecked);
        if (isDownloading && _downloadActions.curDownload == null) {
          _downloadActions.nextDownload();
        }
        if (enableMultiSelect) {
          rxCount = 0;
          enableMultiSelect = false;
        }
        SmartDialog.dismiss();
      },
    );
  }
}
