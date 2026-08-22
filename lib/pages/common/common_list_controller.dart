import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller.dart';

abstract class CommonListController<R, T> extends CommonController<R, T> {
  int page = 1;
  bool isEnd = false;
  bool? hasFooter;

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
