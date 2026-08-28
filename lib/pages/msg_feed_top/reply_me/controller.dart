import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/container/app_container.dart';

class ReplyMeController
    extends CommonListControllerRiverpod<CoreMsgReplyData, CoreMsgReplyItem> {
  int? cursor;
  int? cursorTime;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.

  ReplyMeController() {
    queryData();
  }

  @override
  List<CoreMsgReplyItem>? getDataList(CoreMsgReplyData response) {
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
  Future<LoadingState<CoreMsgReplyData>> customGetData() async {
    final result = await (appRead(msgRepositoryProvider)).msgFeedReplyMe(cursor: cursor, cursorTime: cursorTime);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  Future<void> onRemove(dynamic id, int index) async {
    try {
      final res = await (appRead(msgRepositoryProvider)).delMsgfeed(1, id);
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
