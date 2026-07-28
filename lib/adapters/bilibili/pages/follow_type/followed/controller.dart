
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/adapters/bilibili/pages/follow_type/controller.dart';

class FollowedController extends FollowTypeController {
  @override
  Future<LoadingState<CoreFollowData>> customGetData() async {
    final result = await Get.find<UserRepository>().followedUp(mid: mid, pn: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
