import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

class UpowerRankController
    extends CommonListController<CoreUpowerRankData, CoreUpowerRankInfo> {
  UpowerRankController({
    this.privilegeType,
    required this.upMid,
  });

  final String upMid;
  final int? privilegeType;
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  late final Rx<List<CoreLevelInfo>?> tabs = Rx<List<CoreLevelInfo>?>(null);

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreUpowerRankInfo>? getDataList(CoreUpowerRankData response) {
    isEnd = true;
    if (privilegeType == null &&
        response.coreLevelInfo != null &&
        response.coreLevelInfo!.length > 1) {
      tabs.value = response.coreLevelInfo;
    }
    return response.rankInfo;
  }

  @override
  Future<LoadingState<CoreUpowerRankData>> customGetData() async {
    final result = await (_ref?.read(memberRepositoryProvider) ?? Get.find<MemberRepository>()).upowerRank(
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