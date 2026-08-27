import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller.dart' show ScrollOrRefreshMixin;
import 'package:flutter/widgets.dart' show ChangeNotifier, ScrollController;

abstract class CommonDataController<R, T> extends ChangeNotifier
    with ScrollOrRefreshMixin {
  @override
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;

  LoadingState<T> _loadingState = LoadingState<T>.loading();
  LoadingState<T> get loadingState => _loadingState;
  set loadingState(LoadingState<T> value) {
    _loadingState = value;
    notifyListeners();
  }

  Future<LoadingState<R>> customGetData();

  bool customHandleResponse(bool isRefresh, Success<R> response) {
    return false;
  }

  bool handleError(String? errMsg) {
    return false;
  }

  Future<void> queryData([bool isRefresh = true]) async {
    if (isLoading) return;
    isLoading = true;
    final LoadingState<R> res = await customGetData();
    if (res case Success()) {
      if (!customHandleResponse(isRefresh, res)) {
        loadingState = res as LoadingState<T>;
      }
    } else {
      if (isRefresh && !handleError(res is Error ? res.errMsg : null)) {
        loadingState = res as Error;
      }
    }
    isLoading = false;
  }

  @override
  Future<void> onRefresh() => queryData();

  Future<void> onReload() => onRefresh();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
