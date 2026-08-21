import 'package:skf/core/repository/live_repository.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/models/live_enums.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/adapters/bilibili/pages/live_search/controller.dart';

class LiveSearchChildController
    extends CommonListControllerRiverpod<CoreLiveSearchData, dynamic> {
  LiveSearchChildController(this.notifier, this.searchType);

  final LiveSearchNotifier notifier;
  final CoreLiveSearchType searchType;

  WidgetRef? _ref;
  void attachRef(WidgetRef ref) { _ref = ref; }

  @override
  void checkIsEnd(int length) {
    switch (searchType) {
      case CoreLiveSearchType.room:
        if (notifier.counts.first != -1 &&
            length >= notifier.counts.first) {
          isEnd = true;
        }
        break;
      case CoreLiveSearchType.user:
        if (notifier.counts[1] != -1 && length >= notifier.counts[1]) {
          isEnd = true;
        }
        break;
    }
  }

  @override
  List? getDataList(response) {
    switch (searchType) {
      case CoreLiveSearchType.room:
        notifier.updateCount(searchType.index, response.room?.totalRoom ?? 0);
        return response.room?.list;
      case CoreLiveSearchType.user:
        notifier.updateCount(searchType.index, response.user?.totalUser ?? 0);
        return response.user?.list;
    }
  }

  @override
  Future<LoadingState<CoreLiveSearchData>> customGetData() async {
    final result = await (_ref?.read(liveRepositoryProvider) ?? Get.find<LiveRepository>()).liveSearch(
      page: page,
      keyword: notifier.editingController.text,
      type: searchType,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
