import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SysMsgController
    extends CommonListControllerRiverpod<List<CoreMsgSysItem>?, CoreMsgSysItem> {
  int? cursor;
  SysMsgController() {
    queryData();
  }

  @override
  void handleListResponse(List<CoreMsgSysItem> dataList) {
    if (cursor == null) {
      msgSysUpdateCursor(dataList.first.cursor);
    }
    cursor = dataList.last.cursor;
  }

  void msgSysUpdateCursor(int? cursor) {
    if (cursor != null) {
      (appRead(msgRepositoryProvider)).msgSysUpdateCursor(cursor);
    }
  }

  @override
  Future<void> onRefresh() {
    cursor = null;
    return super.onRefresh();
  }

  Future<void> onRemove(dynamic id, int index) async {
    try {
      final res = await (appRead(msgRepositoryProvider)).delSysMsg(id);
      if (res.isSuccess) {
        loadingState.data!.removeAt(index);
        notifyListeners();
        SmartDialog.showToast('删除成功');
      } else {
        res.toast();
      }
    } catch (_) {}
  }

  @override
  Future<LoadingState<List<CoreMsgSysItem>?>> customGetData() async {
    final result = await (appRead(msgRepositoryProvider)).msgFeedNotify(cursor: cursor);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }
}

/// SysMsgController（单实例）。
final sysMsgControllerProvider = Provider<SysMsgController>((ref) => SysMsgController());
