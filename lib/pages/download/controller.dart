import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/pages/common/multi_select/base.dart'
    show BaseMultiSelectMixin;
import 'package:skf/pages/download/download_actions.dart';
import 'package:skf/pages/download/download_page_info.dart';
import 'package:skf/utils/storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart' show Text;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class DownloadPageController extends GetxController
    with BaseMultiSelectMixin<DownloadPageInfo> {
  final _downloadActions = DownloadActions.of();
  final pages = RxList<DownloadPageInfo>();
  final flag = RxInt(0);

  @override
  List<DownloadPageInfo> get list => pages;
  @override
  RxList<DownloadPageInfo> get state => pages;

  @override
  void onInit() {
    super.onInit();
    _loadList();
    _downloadActions.addFlagListener(_loadList);
  }

  @override
  void onClose() {
    _downloadActions.removeFlagListener(_loadList);
    super.onClose();
  }

  Future<void> _loadList() async {
    await _downloadActions.waitForInitialization;
    if (isClosed) return;
    if (_downloadActions.downloadList.isEmpty) {
      pages.clear();
      return;
    }
    final list = <DownloadPageInfo>[];
    for (final entry in _downloadActions.downloadList) {
      final pageId = entry.pageId;
      final page = list.firstWhereOrNull((e) => e.pageId == pageId);
      if (page != null) {
        final aSortKey = entry.sortKey;
        final bSortKey = page.sortKey;
        if (aSortKey < bSortKey) {
          page
            ..cover = entry.cover
            ..sortKey = aSortKey;
        }
        page.entries.add(entry);
      } else {
        list.add(
          DownloadPageInfo(
            pageId: pageId,
            dirPath: entry.pageDirPath,
            title: entry.title,
            cover: entry.cover,
            sortKey: entry.sortKey,
            seasonType: entry.ep?.seasonType,
            entries: [entry],
          ),
        );
      }
    }
    pages.value = list;
    flag.value++;
  }

  @override
  void onRemove() {
    showConfirmDialog(
      context: Get.context!,
      title: const Text('确定删除选中视频？'),
      onConfirm: () async {
        SmartDialog.showLoading();
        final watchProgress = GStorage.watchProgress;
        for (final page in allChecked) {
          await watchProgress.deleteAll(
            page.entries.map((e) => e.cid.toString()),
          );
          await _downloadActions.deletePage(
            pageDirPath: page.dirPath,
            refresh: false,
          );
        }
        _downloadActions.refreshFlagListeners();
        if (enableMultiSelect.value) {
          rxCount.value = 0;
          enableMultiSelect.value = false;
        }
        SmartDialog.dismiss();
      },
    );
  }
}
