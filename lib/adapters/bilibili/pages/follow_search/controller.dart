
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/adapters/bilibili/pages/common/search/common_search_controller.dart';
import 'package:get/get.dart';

class FollowSearchController
    extends CommonSearchController<CoreFollowData, CoreFollowItemModel> {
  FollowSearchController(this.mid);
  final int mid;

  @override
  Future<LoadingState<CoreFollowData>> customGetData() async {
    final result = await Get.find<MemberRepository>().getfollowSearch(
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
