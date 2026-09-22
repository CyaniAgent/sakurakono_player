import 'package:skf/common/widgets/pair.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/container/app_container.dart';

class LikeMeController
    extends
        CommonControllerRiverpod<
          CoreMsgLikeData,
          Pair<List<CoreMsgLikeItem>, List<CoreMsgLikeItem>>
        > {
  int? cursor;
  int? cursorTime;

  bool isEnd = false;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.

  LoadingState _loadingState = LoadingState.loading();
  @override
  LoadingState get loadingState => _loadingState;
  set loadingState(LoadingState value) {
    _loadingState = value;
    notifyListeners();
  }

  LikeMeController() {
    queryData();
  }

  @override
  Future<void> queryData([bool isRefresh = true]) async {
    if (!isRefresh && isEnd) return;
    if (isLoading) return;
    isLoading = true;
    final res = await customGetData();
    if (res case Success(:final response)) {
      if (!customHandleResponse(isRefresh, res)) {
        loadingState = Success(response);
      }
    } else {
      if (isRefresh && !handleError(res is Error ? res.errMsg : null)) {
        loadingState = res as Error;
      }
    }
    isLoading = false;
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
      if (loadingState case Success(:final response)) {
        latest.insertAll(0, response.first);
        total.insertAll(0, response.second);
      }
    }
    loadingState = Success(Pair(first: latest, second: total));
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
    final result = await (appRead(msgRepositoryProvider)).msgFeedLikeMe(cursor: cursor, cursorTime: cursorTime);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onRemove(dynamic id, int index, bool isLatest) async {
    try {
      final res = await (appRead(msgRepositoryProvider)).delMsgfeed(0, id);
      if (res.isSuccess) {
        Pair<List<CoreMsgLikeItem>, List<CoreMsgLikeItem>> pair =
            loadingState.data;
        if (isLatest) {
          pair.first.removeAt(index);
        } else {
          pair.second.removeAt(index);
        }
        notifyListeners();
        SmartDialog.showToast('删除成功');
      } else {
        res.toast();
      }
    } catch (_) {}
  }

  Future<void> onSetNotice(CoreMsgLikeItem item, bool isNotice) async {
    int noticeState = isNotice ? 1 : 0;
    final res = await (appRead(msgRepositoryProvider)).msgSetNotice(
      id: item.id!.toString(),
      noticeState: noticeState,
    );
    if (res.isSuccess) {
      item.noticeState = noticeState;
      notifyListeners();
      SmartDialog.showToast('设置成功');
    } else {
      res.toast();
    }
  }
}

/// LikeMeController（单实例）。
final likeMeControllerProvider = Provider<LikeMeController>((ref) => LikeMeController());
