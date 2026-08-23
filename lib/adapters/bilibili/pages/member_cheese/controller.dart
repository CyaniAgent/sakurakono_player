import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';

class MemberCheeseController
    extends CommonListControllerRiverpod<CoreSpaceCheeseData, CoreSpaceCheeseItem> {
  MemberCheeseController(this.mid) {
    queryData();
  }

  final int mid;

  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  @override
  List<CoreSpaceCheeseItem>? getDataList(CoreSpaceCheeseData response) {
    isEnd = response.items == null || response.items!.isEmpty;
    return response.items;
  }

  @override
  Future<LoadingState<CoreSpaceCheeseData>> customGetData() async {
    final result = await (_ref!.read(memberRepositoryProvider)).spaceCheese(
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
