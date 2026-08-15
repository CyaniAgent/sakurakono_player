import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/utils/storage_pref.dart';
class FavController
    extends CommonListController<CoreFavFolderData, CoreFavFolderInfo> {
  late final bool isLogin = Pref.userInfoCache?.isLogin == true;

  // 登录态 mid：core 通用路径（BiliAccountProvider.userId 未实现，改用缓存）。
  late final int mid = Pref.userInfoCache?.mid ?? 0;

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
    final result = await Get.find<FavRepository>().userfavFolder(
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
