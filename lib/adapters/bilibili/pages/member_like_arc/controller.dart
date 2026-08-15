import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';

class MemberLikeArcController
    extends CommonListController<CoreCoinLikeArcData, CoreCoinLikeArcItem> {
  final dynamic mid;
  MemberLikeArcController({this.mid});

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreCoinLikeArcItem>? getDataList(CoreCoinLikeArcData response) {
    return response.item;
  }

  @override
  Future<LoadingState<CoreCoinLikeArcData>> customGetData() async {
    final result = await Get.find<MemberRepository>().likeArc(mid: mid, page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}