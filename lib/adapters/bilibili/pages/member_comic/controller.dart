import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';

class MemberComicController
    extends CommonListController<CoreSpaceArchiveData, CoreSpaceArchiveItem> {
  MemberComicController(this.mid);

  final int mid;

  int? count;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  void checkIsEnd(int length) {
    if (count != null && length >= count!) {
      isEnd = true;
    }
  }

  @override
  List<CoreSpaceArchiveItem>? getDataList(CoreSpaceArchiveData response) {
    count = response.count;
    return response.item;
  }

  @override
  Future<LoadingState<CoreSpaceArchiveData>> customGetData() async {
    final result = await Get.find<MemberRepository>().spaceArchive(
      type: CoreContributeType.comic,
      mid: mid,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}