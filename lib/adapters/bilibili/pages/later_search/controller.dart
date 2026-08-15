
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/pages/common/multi_select/base.dart';
import 'package:skf/pages/common/search/common_search_controller.dart';
import 'package:skf/adapters/bilibili/pages/later/controller.dart' show BaseLaterController;

class LaterSearchController
    extends CommonSearchController<CoreLaterData, CoreLaterItemModel>
    with
        CommonMultiSelectMixin<CoreLaterItemModel>,
        DeleteItemMixin,
        BaseLaterController {
  dynamic mid;
  dynamic count;

  @override
  void onInit() {
    final args = Get.arguments;
    mid = args['mid'];
    count = args['count'];
    super.onInit();
  }

  @override
  Future<LoadingState<CoreLaterData>> customGetData() async {
    final result = await Get.find<UserRepository>().seeYouLater(
    page: page,
    keyword: editController.value.text,
  );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  List<CoreLaterItemModel>? getDataList(CoreLaterData response) {
    return response.list;
  }
}
