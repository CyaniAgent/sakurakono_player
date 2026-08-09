import 'package:skf/core/repository/live_repository.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/live_enums.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';

class ContributionRankController
    extends
        CommonListController<
          CoreLiveContributionRankData,
          CoreLiveContributionRankItem
        > {
  final int ruid;
  final int roomId;
  final CoreLiveContributionRankType type;

  ContributionRankController({
    required this.ruid,
    required this.roomId,
    required this.type,
  });

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreLiveContributionRankItem>? getDataList(
    CoreLiveContributionRankData response,
  ) {
    return response.item;
  }

  @override
  Future<LoadingState<CoreLiveContributionRankData>> customGetData() async {
    final result = await Get.find<LiveRepository>().liveContributionRank(
        ruid: ruid,
        roomId: roomId,
        page: page,
        type: type,
      );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
