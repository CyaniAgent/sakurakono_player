import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:get/get.dart';
import 'package:skf/core/container/app_container.dart';

class MemberGuardController
    extends CommonListControllerRiverpod<CoreMemberGuardData, CoreGuardItem> {
  MemberGuardController() {
    queryData();
  }

  final int ruid = Get.arguments['ruid'] as int;

  late List<CoreGuardItem> tops;
  void attachRef(Ref ref) {}

  @override
  List<CoreGuardItem>? getDataList(CoreMemberGuardData response) {
    return response.guardTopList;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<CoreMemberGuardData> response) {
    if (response.response.hasMore != 1) {
      isEnd = true;
    }
    if (isRefresh) {
      final list = response.response.guardTopList;
      tops = list.take(3).toList();
      if (list.length > 3) {
        list.removeRange(0, 3);
      } else {
        list.clear();
      }
    }
    return false;
  }

  @override
  Future<LoadingState<CoreMemberGuardData>> customGetData() async {
    final result = await (appRead(memberRepositoryProvider)).memberGuard(ruid: ruid, page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}