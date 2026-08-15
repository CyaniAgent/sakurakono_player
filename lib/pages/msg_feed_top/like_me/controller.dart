import 'package:skf/common/widgets/pair.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/pages/common/common_data_controller.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class LikeMeController
    extends
        CommonDataController<
          CoreMsgLikeData,
          Pair<List<CoreMsgLikeItem>, List<CoreMsgLikeItem>>
        > {
  int? cursor;
  int? cursorTime;

  bool isEnd = false;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<void> queryData([bool isRefresh = true]) {
    if (!isRefresh && isEnd) {
      return Future.syncValue(null);
    }
    return super.queryData(isRefresh);
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<CoreMsgLikeData> response) {
    CoreMsgLikeData data = response.response;
    if (data.total?.cursor?.isEnd == true ||
        data.total?.items.isNullOrEmpty == true) {
      isEnd = true;
    }
    cursor = data.total?.cursor?.id;
    cursorTime = data.total?.cursor?.time;
    List<CoreMsgLikeItem> latest = data.latest?.items ?? <CoreMsgLikeItem>[];
    List<CoreMsgLikeItem> total = data.total?.items ?? <CoreMsgLikeItem>[];
    if (!isRefresh) {
      if (loadingState.value case Success(:final response)) {
        latest.insertAll(0, response.first);
        total.insertAll(0, response.second);
      }
    }
    loadingState.value = Success(Pair(first: latest, second: total));
    return true;
  }

  @override
  Future<void> onRefresh() {
    cursor = null;
    cursorTime = null;
    return super.onRefresh();
  }

  @override
  Future<LoadingState<CoreMsgLikeData>> customGetData() async {
    final result = await Get.find<MsgRepository>().msgFeedLikeMe(cursor: cursor, cursorTime: cursorTime);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  Future<void> onRemove(dynamic id, int index, bool isLatest) async {
    try {
      final res = await Get.find<MsgRepository>().delMsgfeed(0, id);
      if (res.isSuccess) {
        Pair<List<CoreMsgLikeItem>, List<CoreMsgLikeItem>> pair =
            loadingState.value.data;
        if (isLatest) {
          pair.first.removeAt(index);
        } else {
          pair.second.removeAt(index);
        }
        loadingState.refresh();
        SmartDialog.showToast('删除成功');
      } else {
        res.toast();
      }
    } catch (_) {}
  }

  Future<void> onSetNotice(CoreMsgLikeItem item, bool isNotice) async {
    int noticeState = isNotice ? 1 : 0;
    final res = await Get.find<MsgRepository>().msgSetNotice(
      id: item.id!.toString(),
      noticeState: noticeState,
    );
    if (res.isSuccess) {
      item.noticeState = noticeState;
      loadingState.refresh();
      SmartDialog.showToast('设置成功');
    } else {
      res.toast();
    }
  }
}
