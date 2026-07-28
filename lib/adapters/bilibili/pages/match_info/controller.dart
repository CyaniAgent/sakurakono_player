import 'package:skf/core/repository/match_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/match_contest.dart';
import 'package:skf/adapters/bilibili/pages/common/dyn/common_dyn_controller.dart';
import 'package:get/get.dart';

class MatchInfoController extends CommonDynController {
  @override
  final int oid = int.parse(Get.parameters['cid']!);
  @override
  final int replyType = 27;

  @override
  dynamic get sourceId => oid.toString();

  final Rx<LoadingState<CoreMatchContest?>> infoState =
      LoadingState<CoreMatchContest?>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    getMatchInfo();
  }

  Future<void> getMatchInfo() async {
    final res = await Get.find<MatchRepository>().matchInfo(oid);
    if (res.isSuccess) {
      queryData();
    }
    infoState.value = switch (res) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
