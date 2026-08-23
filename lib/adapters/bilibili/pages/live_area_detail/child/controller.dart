import 'dart:math';

import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/repository/live_repository.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';

class LiveAreaChildController
    extends CommonListControllerRiverpod<CoreLiveSecondData, CoreCardLiveItem> {
  final dynamic areaId;
  final dynamic parentAreaId;
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  int? count;

  String? sortType;

  // tag
  int tagIndex = 0;
  List<CoreLiveSecondTag>? newTags;

  LiveAreaChildController(this.areaId, this.parentAreaId) {
    queryData();
  }

  @override
  void checkIsEnd(int length) {
    if (count != null && length >= count!) {
      isEnd = true;
    }
  }

  @override
  List<CoreCardLiveItem>? getDataList(CoreLiveSecondData response) {
    count = response.count;
    newTags = response.newTags;
    tagIndex = max(
      0,
      newTags?.indexWhere((e) => e.sortType == sortType) ?? 0,
    );
    return response.cardList;
  }

  @override
  Future<LoadingState<CoreLiveSecondData>> customGetData() async {
    final result = await (_ref!.read(liveRepositoryProvider)).liveSecondList(
        pn: page,
        areaId: areaId,
        parentAreaId: parentAreaId,
        sortType: sortType,
      );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  void onSelectTag(int index, String? sortType) {
    if (isLoading) {
      return;
    }
    tagIndex = index;
    this.sortType = sortType;

    onRefresh();
  }
}
