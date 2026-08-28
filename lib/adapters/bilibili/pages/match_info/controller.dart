import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/match_contest.dart';
import 'package:skf/adapters/bilibili/pages/common/dyn/common_dyn_controller.dart';
import 'package:get/get.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/container/app_container.dart';

class MatchInfoController extends CommonDynController {
  @override
  @override
  final int oid = int.parse(Get.parameters['cid']!);
  @override
  final int replyType = 27;

  @override
  dynamic get sourceId => oid.toString();

  LoadingState<CoreMatchContest?> infoState = LoadingState<CoreMatchContest?>.loading();

  MatchInfoController() {
    getMatchInfo();
  }

  Future<void> getMatchInfo() async {
    final res = await (appRead(matchRepositoryProvider)).matchInfo(oid);
    if (res.isSuccess) {
      queryData();
    }
    infoState = switch (res) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
    notifyListeners();
  }
}
