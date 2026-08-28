import 'dart:math';

import 'package:skf/core/models/live_types.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/container/app_container.dart';

class LiveAreaChildController
    extends CommonListControllerRiverpod<CoreLiveSecondData, CoreCardLiveItem> {
  final dynamic areaId;
  final dynamic parentAreaId;

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
    final result = await (appRead(liveRepositoryProvider)).liveSecondList(
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

/// 每实例注册表 — 页面 view 创建后登记，按 key 经 provider 读取（替代 GetX tag 注册）。
/// 
final Map<String, LiveAreaChildController> liveAreaChildRegistry = {};

final liveAreaChildProvider = Provider.family<LiveAreaChildController, String>(
  (ref, key) => liveAreaChildRegistry[key] ??
      (throw StateError('LiveAreaChildController not registered for key: $key')),
);

