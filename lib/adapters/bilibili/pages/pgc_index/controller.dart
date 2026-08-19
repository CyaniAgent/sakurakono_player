import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/repository/pgc_repository.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/pgc_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';

class PgcIndexController
    extends CommonListController<CorePgcIndexResult, CorePgcIndexItem> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  PgcIndexController(this.indexType);
  int? indexType;
  Rx<LoadingState<CorePgcIndexConditionData>> conditionState =
      LoadingState<CorePgcIndexConditionData>.loading().obs;

  late final RxBool isExpand = false.obs;

  RxMap<String, dynamic> indexParams = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getPgcIndexCondition();
  }

  Future<void> getPgcIndexCondition() async {
    final res = await (_ref?.read(pgcRepositoryProvider) ?? Get.find<PgcRepository>()).pgcIndexCondition(
      seasonType: indexType == null ? 1 : null,
      type: 0,
      indexType: indexType,
    );
    if (res case Success(:final response)) {
      if (response.order?.isNotEmpty == true) {
        indexParams['order'] = response.order!.first.field;
      }
      if (response.filter?.isNotEmpty == true) {
        for (CorePgcConditionFilter item in response.filter!) {
          indexParams['${item.field}'] = item.values?.firstOrNull?.keyword;
        }
      }
      queryData();
    }
    conditionState.value = switch (res) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  Future<LoadingState<CorePgcIndexResult>> customGetData() async {
    final result = await (_ref?.read(pgcRepositoryProvider) ?? Get.find<PgcRepository>()).pgcIndexResult(
      page: page,
      params: indexParams,
      seasonType: indexType == null ? 1 : null,
      type: 0,
      indexType: indexType,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  List<CorePgcIndexItem>? getDataList(CorePgcIndexResult response) {
    if (response.hasNext == null || response.hasNext == 0) {
      isEnd = true;
    }
    return response.list;
  }
}
