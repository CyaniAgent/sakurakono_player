import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/core/account/account_provider.dart';
class FavController
    extends CommonListController<CoreFavFolderData, CoreFavFolderInfo> {
  Ref? _ref;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) { _ref = ref; }

  late final bool isLogin = Get.find<AccountProvider>().isLogin;

  late final int mid = Get.find<AccountProvider>().userId ?? 0;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<void> queryData([bool isRefresh = true]) {
    if (!isLogin) {
      loadingState.value = const Error('账号未登录');
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
    final result = await (_ref?.read(favRepositoryProvider) ?? Get.find<FavRepository>()).userfavFolder(
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
