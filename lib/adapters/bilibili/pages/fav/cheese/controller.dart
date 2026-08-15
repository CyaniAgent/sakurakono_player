import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class FavCheeseController
    extends CommonListController<CoreSpaceCheeseData, CoreSpaceCheeseItem> {
  final mid = Accounts.main.mid;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreSpaceCheeseItem>? getDataList(CoreSpaceCheeseData response) {
    isEnd = response.page?.next == false;
    return response.items;
  }

  @override
  Future<LoadingState<CoreSpaceCheeseData>> customGetData() async {
    final result = await Get.find<FavRepository>().favPugv(mid: mid, page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onRemove(int index, int sid) async {
    final res = await Get.find<FavRepository>().delFavPugv(sid);
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
