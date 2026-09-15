import 'package:skf/common/widgets/scroll_physics.dart' show ReloadMixin;
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/router/app_navigator.dart';

const int ps = 30;

abstract class BaseVideoWebCtr<R, T, V> extends CommonListControllerRiverpod<R, T>
    with ReloadMixin {
  final int mid = AppNavigator.arguments['mid'] as int;

  int? totalPage;
  int? count;
  V get order;
  set order(V value);

  BaseVideoWebCtr() {
    queryData();
  }

  @override
  void checkIsEnd(int length) {
    if (totalPage != null && page >= totalPage!) {
      isEnd = true;
    } else if (count != null && length >= count!) {
      isEnd = true;
    }
  }

  void queryBySort(V value) {
    if (isLoading) return;
    order = value;
    onReload();
  }

  void jumpToPage(int page) {
    isEnd = false;
    reload = true;
    this.page = page;
    loadingState = LoadingState.loading();
    queryData();
  }

  @override
  Future<void> onReload() {
    reload = true;
    return super.onReload();
  }
}
