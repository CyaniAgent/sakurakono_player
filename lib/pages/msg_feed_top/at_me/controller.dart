import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/container/app_container.dart';

class AtMeController extends CommonListControllerRiverpod<CoreMsgAtData, CoreMsgAtItem> {
  int? cursor;
  int? cursorTime;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) {}

  AtMeController() {
    queryData();
  }

  @override
  List<CoreMsgAtItem>? getDataList(CoreMsgAtData response) {
    if (response.cursor?.isEnd == true) {
      isEnd = true;
    }
    cursor = response.cursor?.id;
    cursorTime = response.cursor?.time;
    return response.items;
  }

  @override
  Future<void> onRefresh() {
    cursor = null;
    cursorTime = null;
    return super.onRefresh();
  }

  @override
  Future<LoadingState<CoreMsgAtData>> customGetData() async {
    final result = await (appRead(msgRepositoryProvider)).msgFeedAtMe(cursor: cursor, cursorTime: cursorTime);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  @pragma('vm:notify-debugger-on-exception')
  Future<void> onRemove(Object id, int index) async {
    try {
      final res = await (appRead(msgRepositoryProvider)).delMsgfeed(2, id);
      if (res.isSuccess) {
        loadingState.data!.removeAt(index);
        notifyListeners();
        SmartDialog.showToast('删除成功');
      } else {
        res.toast();
      }
    } catch (_) {}
  }
}
