import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/multi_select/base.dart'
    show BaseMultiSelectMixin;
import 'package:skf/pages/common/search/common_search_controller.dart';
import 'package:skf/pages/download/download_actions.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/storage.dart';
import 'package:flutter/widgets.dart' show Text;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadSearchController
    extends
        CommonSearchController<
          List<CoreDownloadEntryInfo>,
          CoreDownloadEntryInfo
        >
    with BaseMultiSelectMixin<CoreDownloadEntryInfo> {
  final _downloadActions = DownloadActions.of();

  @override
  List<CoreDownloadEntryInfo> get list => loadingState.data!;
  @override
  void notifyStateChanged() => notifyListeners();

  @override
  Future<LoadingState<List<CoreDownloadEntryInfo>>> customGetData() async {
    final text = editController.text.toLowerCase();
    return Success(
      _downloadActions.downloadList
          .where(
            (e) =>
                e.title.toLowerCase().contains(text) ||
                e.showTitle.toLowerCase().contains(text),
          )
          .toList(),
    );
  }

  void onRemoveSingle(int index, CoreDownloadEntryInfo entry) {
    loadingState.data!.removeAt(index);
    notifyListeners();
    _downloadActions.deleteDownload(
      entry: entry,
      removeList: true,
    );
    GStorage.watchProgress.delete(entry.cid.toString());
  }

  @override
  void onRemove() {
    showConfirmDialog(
      context: AppNavigator.context!,
      title: const Text('确定删除选中视频？'),
      onConfirm: () async {
        SmartDialog.showLoading();
        final allChecked = this.allChecked.toSet();
        for (final entry in allChecked) {
          await GStorage.watchProgress.delete(entry.cid.toString());
          await _downloadActions.deleteDownload(
            entry: entry,
            removeList: true,
            refresh: false,
          );
        }
        loadingState.data!.removeWhere(allChecked.contains);
        notifyListeners();
        _downloadActions.refreshFlagListeners();
        if (enableMultiSelect) {
          rxCount = 0;
          enableMultiSelect = false;
        }
        SmartDialog.dismiss();
      },
    );
  }
}

/// DownloadSearchController（单实例）。
final downloadSearchControllerProvider = Provider<DownloadSearchController>((ref) => DownloadSearchController());
