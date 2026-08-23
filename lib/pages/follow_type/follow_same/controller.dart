
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/pages/follow_type/controller.dart';
import 'package:skf/core/repository/repository_providers.dart';

class FollowSameController extends FollowTypeController {
  @override
  Future<LoadingState<CoreFollowData>> customGetData() async {
    final result = await (repoRef!.read(userRepositoryProvider)).sameFollowing(mid: mid, pn: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
