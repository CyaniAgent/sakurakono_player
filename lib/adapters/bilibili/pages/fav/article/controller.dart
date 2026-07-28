import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class FavArticleController
    extends CommonListController<CoreFavArticleData, CoreFavArticleItemModel> {
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreFavArticleItemModel>? getDataList(CoreFavArticleData response) {
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.items;
  }

  @override
  Future<LoadingState<CoreFavArticleData>> customGetData() async {
    final result = await Get.find<FavRepository>().favArticle(page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onRemove(int index, String id) async {
    final res = await Get.find<FavRepository>().communityAction(opusId: id, action: 4);
    if (res.isSuccess) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
      SmartDialog.showToast('已取消收藏');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }
}
