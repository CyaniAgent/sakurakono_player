import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter/material.dart' show TabController;
import 'package:flutter/scheduler.dart' show Ticker, TickerCallback, TickerProvider;
import 'package:get/get.dart';

class BubbleController extends CommonListControllerRiverpod<CoreBubbleData, CoreDynList>
    implements TickerProvider {
  Ticker? _ticker;
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  BubbleController(this.categoryId) {
    tribeId = Get.arguments['id'];
    queryData();
  }
  final Object? categoryId;

  late final String tribeId;
  int? sortType;

  final Rxn<CoreSortInfo> sortInfo = Rxn<CoreSortInfo>();
  TabController? tabController;
  final RxnString tribeName = RxnString();
  final Rxn<List<CoreCategoryList>> tabs = Rxn<List<CoreCategoryList>>();

  @override
  Ticker createTicker(TickerCallback onTick) {
    assert(_ticker == null, 'Only one Ticker per controller');
    _ticker = Ticker(onTick);
    return _ticker!;
  }

  @override
  List<CoreDynList>? getDataList(CoreBubbleData response) {
    return response.content?.dynList;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<CoreBubbleData> response) {
    if (isRefresh) {
      final data = response.response;
      sortInfo.value = data.sortInfo;
      if (categoryId == null) {
        tribeName.value = data.baseInfo?.tribeInfo?.title;
        if (tabController == null) {
          if (data.category?.categoryList case final categories?
              when categories.isNotEmpty) {
            tabController = TabController(
              length: categories.length,
              vsync: this,
            );
            tabs.value = categories;
          }
        }
      }
    }
    return false;
  }

  @override
  Future<LoadingState<CoreBubbleData>> customGetData() async {
    final result = await (_ref?.read(dynamicsRepositoryProvider) ?? Get.find<DynamicsRepository>()).bubble(
      tribeId: tribeId,
      categoryId: categoryId,
      sortType: sortType,
      page: page,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void dispose() {
    _ticker?.dispose();
    tabController?.dispose();
    tabController = null;
    super.dispose();
  }

  void onSort(int? sortType) {
    this.sortType = sortType;
    onReload();
  }
}
