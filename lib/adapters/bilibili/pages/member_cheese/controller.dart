import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';

class MemberCheeseController
    extends CommonListController<CoreSpaceCheeseData, CoreSpaceCheeseItem> {
  MemberCheeseController(this.mid);

  final int mid;

  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreSpaceCheeseItem>? getDataList(CoreSpaceCheeseData response) {
    isEnd = response.items == null || response.items!.isEmpty;
    return response.items;
  }

  @override
  Future<LoadingState<CoreSpaceCheeseData>> customGetData() async {
    final result = await (_ref?.read(memberRepositoryProvider) ?? Get.find<MemberRepository>()).spaceCheese(
      page: page,
      mid: mid,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
