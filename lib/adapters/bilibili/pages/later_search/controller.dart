
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/pages/common/multi_select/base.dart';
import 'package:skf/pages/common/search/common_search_controller.dart';
import 'package:skf/pages/later/controller.dart' show BaseLaterController;
import 'package:skf/core/container/app_container.dart';
import 'package:skf/router/app_navigator.dart';

class LaterSearchController
    extends CommonSearchController<CoreLaterData, CoreLaterItemModel>
    with
        CommonMultiSelectMixin<CoreLaterItemModel>,
        DeleteItemMixin,
        BaseLaterController {
  dynamic mid;
  dynamic count;

  LaterSearchController() {
    final args = AppNavigator.arguments;
    mid = args['mid'];
    count = args['count'];
  }

  @override
  Future<LoadingState<CoreLaterData>> customGetData() async {
    final result = await (appRead(userRepositoryProvider)).seeYouLater(
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
