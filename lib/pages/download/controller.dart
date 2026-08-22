import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/pages/common/multi_select/base.dart'
    show BaseMultiSelectMixin;
import 'package:skf/pages/download/download_actions.dart';
import 'package:skf/pages/download/download_page_info.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart' show Text;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter/foundation.dart';

class DownloadPageController extends ChangeNotifier
    with BaseMultiSelectMixin<DownloadPageInfo> {
  bool _isDisposed = false;
  bool get isClosed => _isDisposed;

  final _downloadActions = DownloadActions.of();
  final pages = <DownloadPageInfo>[];
  int flag = 0;

  @override
  List<DownloadPageInfo> get list => pages;
  @override
  void notifyStateChanged() => notifyListeners();

  bool get isMultiSelectMode => enableMultiSelect.value;
  set isMultiSelectMode(bool v) {
    enableMultiSelect.value = v;
    notifyListeners();
  }

  DownloadPageController() {
    _loadList();
    _downloadActions.addFlagListener(_loadList);
  }

  @override
  void dispose() {
    _downloadActions.removeFlagListener(_loadList);
    super.dispose();
  }

  Future<void> _loadList() async {
    await _downloadActions.waitForInitialization;
    if (_isDisposed) return;
    if (_downloadActions.downloadList.isEmpty) {
      pages.clear();
      notifyListeners();
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
    pages
      ..clear()
      ..addAll(list);
    flag++;
    notifyListeners();
  }

  @override
  void onRemove() {
    showConfirmDialog(
      context: AppNavigator.context!,
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
