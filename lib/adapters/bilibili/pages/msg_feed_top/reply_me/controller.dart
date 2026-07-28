import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class ReplyMeController
    extends CommonListController<CoreMsgReplyData, CoreMsgReplyItem> {
  int? cursor;
  int? cursorTime;

  @override
  void onInit() {
    super.onInit();
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
    final result = await Get.find<MsgRepository>().msgFeedReplyMe(cursor: cursor, cursorTime: cursorTime);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  Future<void> onRemove(dynamic id, int index) async {
    try {
      final res = await Get.find<MsgRepository>().delMsgfeed(1, id);
      if (res.isSuccess) {
        loadingState
          ..value.data!.removeAt(index)
          ..refresh();
        SmartDialog.showToast('删除成功');
      } else {
        res.toast();
      }
    } catch (_) {}
  }
}
