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

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) {}

  late final bool isLogin = appRead(accountProvider).isLogin;

  late final int mid = appRead(accountProvider).userId ?? 0;


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
