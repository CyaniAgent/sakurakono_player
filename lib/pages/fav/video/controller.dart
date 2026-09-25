import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/account/account_provider.dart';
class FavController
    extends CommonListControllerRiverpod<CoreFavFolderData, CoreFavFolderInfo> {
  FavController() {
    queryData();
  }

  /// 登录态/uid 实时读取:登录前后下拉刷新即生效,无需重启。
  bool get isLogin => appRead(accountProvider).isLogin;

  int get mid => appRead(accountProvider).userId ?? 0;


  @override
  Future<void> queryData([bool isRefresh = true]) {
    if (!isLogin) {
      loadingState = const Error('账号未登录');
      return Future.syncValue(null);
    }
    return super.queryData(isRefresh);
  }

  @override
  List<CoreFavFolderInfo>? getDataList(CoreFavFolderData response) {
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.list;
  }

  @override
  Future<LoadingState<CoreFavFolderData>> customGetData() async {
    final result = await (appRead(favRepositoryProvider)).userfavFolder(
    pn: page,
    ps: 20,
    mid: mid,
  );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}

/// 收藏页控制器（单实例）。登录态变更(登录/登出/换号)时自动重拉;
/// onRefresh 重置 page/isEnd,避免以旧页码拉出新账号的错误切片。
final favControllerProvider = Provider<FavController>((ref) {
  final controller = FavController();
  ref.listen(accountProvider, (prev, next) {
    if (prev?.isLogin != next.isLogin || prev?.userId != next.userId) {
      Future.microtask(controller.onRefresh);
    }
  });
  return controller;
});
