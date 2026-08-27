import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';

import 'package:skf/core/repository/live_repository.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/live_enums.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class ContributionRankController
    extends
        CommonListController<
          CoreLiveContributionRankData,
          CoreLiveContributionRankItem
        > {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  final int ruid;
  final int roomId;
  final CoreLiveContributionRankType type;

  ContributionRankController({
    required this.ruid,
    required this.roomId,
    required this.type,
  }) {
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
    final result = await (_ref!.read(liveRepositoryProvider)).liveContributionRank(
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
