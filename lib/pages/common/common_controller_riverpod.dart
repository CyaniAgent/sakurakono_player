import 'dart:async';

import 'package:skf/core/result/loading_state.dart';
import 'package:flutter/widgets.dart' show ScrollController, ChangeNotifier;
import 'package:skf/pages/common/common_controller.dart' show ScrollOrRefreshMixin;
export 'package:skf/pages/common/common_controller.dart' show ScrollOrRefreshMixin;


/// Riverpod-compatible base class replacing `CommonController<R, T>`.
///
/// Uses [ChangeNotifier] instead of GetxController. Subclasses call
/// [notifyListeners] (inherited from ChangeNotifier) instead of [update].
///
/// This class lives alongside the old GetX base class to allow gradual
/// migration via the strangler-fig pattern. Once all subclasses are
/// migrated, the old `CommonController` can be deleted.
abstract class CommonControllerRiverpod<R, T> extends ChangeNotifier
    with ScrollOrRefreshMixin {
  @override
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;

  /// Current loading state. Subclasses should update this and call
  /// [notifyListeners] to trigger rebuilds.
  LoadingState get loadingState;

  /// Fetch data from the repository. Must be implemented by subclasses.
  Future<LoadingState<R>> customGetData();

  /// Query data with optional refresh flag. Must be implemented by subclasses.
  Future<void> queryData([bool isRefresh = true]);

  /// Custom handler for successful responses. Return true to skip default handling.
  bool customHandleResponse(bool isRefresh, Success<R> response) {
    return false;
  }

  /// Custom error handler. Return true to suppress default error handling.
  bool handleError(String? errMsg) {
    return false;
  }

  @override
  Future<void> onRefresh() {
    return queryData();
  }

  Future<void> onLoadMore() {
    return queryData(false);
  }

  Future<void> onReload() {
    return onRefresh();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

/// Riverpod-compatible list controller replacing `CommonListController<R, T>`.
///
/// Adds pagination state ([page], [isEnd]) and list-specific query logic.
abstract class CommonListControllerRiverpod<R, T>
    extends CommonControllerRiverpod<R, T> {
  int page = 1;
  bool isEnd = false;
  bool? hasFooter;

  /// Current loading state with list data.
  LoadingState<List<T>?> _loadingState = LoadingState<List<T>?>.loading();
  @override
  LoadingState<List<T>?> get loadingState => _loadingState;
  set loadingState(LoadingState<List<T>?> value) {
    _loadingState = value;
    notifyListeners();
  }

  void handleListResponse(List<T> dataList) {}

  List<T>? getDataList(R response) {
    return response as List<T>?;
  }

  void checkIsEnd(int length) {}

  @override
  Future<void> queryData([bool isRefresh = true]) async {
    if (isLoading || (!isRefresh && isEnd)) return;
    isLoading = true;
    final LoadingState<R> res = await customGetData();
    if (res case Success(:final response)) {
      if (!customHandleResponse(isRefresh, res)) {
        final dataList = getDataList(response);
        if (dataList == null || dataList.isEmpty) {
          isEnd = true;
          if (isRefresh) {
            loadingState = Success(dataList);
          } else if (hasFooter == true) {
            notifyListeners();
          }
          isLoading = false;
          return;
        }
        handleListResponse(dataList);
        if (isRefresh) {
          checkIsEnd(dataList.length);
          loadingState = Success(dataList);
        } else if (loadingState case Success(:final response)) {
          response!.addAll(dataList);
          checkIsEnd(response.length);
          notifyListeners();
        }
      }
      page++;
    } else {
      if (isRefresh && !handleError(res is Error ? res.errMsg : null)) {
        loadingState = res as Error;
      }
    }
    isLoading = false;
  }

  @override
  Future<void> onRefresh() {
    page = 1;
    isEnd = false;
    return super.onRefresh();
  }

  @override
  Future<void> onReload() {
    loadingState = LoadingState<List<T>?>.loading();
    return super.onReload();
  }
}
