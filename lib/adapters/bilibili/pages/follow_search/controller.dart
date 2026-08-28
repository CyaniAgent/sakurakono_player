import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/pages/common/search/common_search_controller.dart';
import 'package:skf/core/container/app_container.dart';

class FollowSearchController
    extends CommonSearchController<CoreFollowData, CoreFollowItemModel> {
  FollowSearchController(this.mid);
  final int mid;

  @override
  Future<LoadingState<CoreFollowData>> customGetData() async {
    final result = await (appRead(memberRepositoryProvider)).getfollowSearch(
        mid: mid,
        ps: 20,
        pn: page,
        name: editController.value.text,
      );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  List<CoreFollowItemModel>? getDataList(CoreFollowData response) {
    return response.list;
  }
}
