import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:flutter/material.dart' show TabController;
import 'package:get/get.dart';

class BubbleController extends CommonListController<CoreBubbleData, CoreDynList>
    with GetSingleTickerProviderStateMixin {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  BubbleController(this.categoryId);
  final Object? categoryId;

  late final String tribeId;
  int? sortType;

  final Rxn<CoreSortInfo> sortInfo = Rxn<CoreSortInfo>();
  TabController? tabController;
  final RxnString tribeName = RxnString();
  final Rxn<List<CoreCategoryList>> tabs = Rxn<List<CoreCategoryList>>();

  @override
  void onInit() {
    super.onInit();
    tribeId = Get.arguments['id'];
    queryData();
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
  void onClose() {
    tabController?.dispose();
    tabController = null;
    super.onClose();
  }

  void onSort(int? sortType) {
    this.sortType = sortType;
    onReload();
  }
}
