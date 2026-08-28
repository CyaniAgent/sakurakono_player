import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';


import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/live_enums.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/core/container/app_container.dart';

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
    final result = await (appRead(liveRepositoryProvider)).liveContributionRank(
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

/// 每实例注册表 — 页面 view 创建后登记，按 key 经 provider 读取（替代 GetX tag 注册）。
/// 
final Map<String, ContributionRankController> contributionRankRegistry = {};

final contributionRankProvider = Provider.family<ContributionRankController, String>(
  (ref, key) => contributionRankRegistry[key] ??
      (throw StateError('ContributionRankController not registered for key: $key')),
);

