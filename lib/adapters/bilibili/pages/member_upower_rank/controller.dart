import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';

class UpowerRankController
    extends CommonListControllerRiverpod<CoreUpowerRankData, CoreUpowerRankInfo> {
  UpowerRankController({
    this.privilegeType,
    required this.upMid,
  }) {
    queryData();
  }

  final String upMid;
  final int? privilegeType;
  void attachRef(ProviderContainer ref) {}

  late final List<CoreLevelInfo>? tabs;

  @override
  List<CoreUpowerRankInfo>? getDataList(CoreUpowerRankData response) {
    isEnd = true;
    if (privilegeType == null &&
        response.coreLevelInfo != null &&
        response.coreLevelInfo!.length > 1) {
      tabs = response.coreLevelInfo;
    }
    return response.rankInfo;
  }

  @override
  Future<LoadingState<CoreUpowerRankData>> customGetData() async {
    final result = await (appRead(memberRepositoryProvider)).upowerRank(
      upMid: int.tryParse(upMid) ?? 0,
      page: page,
      privilegeType: privilegeType,
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
final Map<String, UpowerRankController> upowerRankRegistry = {};

final upowerRankProvider = Provider.family<UpowerRankController, String>(
  (ref, key) => upowerRankRegistry[key] ??
      (throw StateError('UpowerRankController not registered for key: $key')),
);

