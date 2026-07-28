import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/adapters/bilibili/pages/common/multi_select/multi_select_controller.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class FavPgcController
    extends MultiSelectController<CoreFavPgcData, CoreFavPgcItemModel> {
  final int type;
  final int followStatus;

  FavPgcController(this.type, this.followStatus);

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  final RxBool allSelected = false.obs;

  @override
  void handleSelect({bool checked = false, bool disableSelect = true}) {
    allSelected.value = checked;
    super.handleSelect(checked: checked, disableSelect: disableSelect);
  }

  @override
  List<CoreFavPgcItemModel>? getDataList(CoreFavPgcData response) {
    return response.list;
  }

  @override
  Future<LoadingState<CoreFavPgcData>> customGetData() async {
    final result = await Get.find<FavRepository>().favPgc(
    type: type,
    followStatus: followStatus,
    pn: page,
  );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  void onDisable() {
    if (checkedCount != 0) {
      handleSelect();
    }
    enableMultiSelect.value = false;
  }

  // 取消追番
  Future<void> pgcDel(int index, seasonId) async {
    final result = await Get.find<VideoRepository>().pgcDel(seasonId: seasonId);
    if (result case Success(:final response)) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
      SmartDialog.showToast(response);
    } else {
      SmartDialog.showToast(result.toString());
    }
  }

  @override
  void onRemove() {
    assert(false, 'call onUpdateList');
  }

  Future<void> onUpdateList(int followStatus) async {
    final removeList = allChecked.toSet();
    final res = await Get.find<VideoRepository>().pgcUpdate(
      seasonId: removeList.map((item) => item.seasonId).join(','),
      status: followStatus,
    );
    if (res case Success(:final response)) {
      try {
        final ctr = Get.find<FavPgcController>(tag: '$type$followStatus');
        if (ctr.loadingState.value case Success(:final response)) {
          response?.insertAll(
            0,
            removeList.map((item) => item..checked = false),
          );
          ctr
            ..loadingState.refresh()
            ..allSelected.value = false;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fav pgc onUpdate: $e');
      }
      afterDelete(removeList);
      SmartDialog.showToast(response);
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  Future<void> onUpdate(int index, int followStatus, int? seasonId) async {
    final res = await Get.find<VideoRepository>().pgcUpdate(
      seasonId: seasonId.toString(),
      status: followStatus,
    );
    if (res case Success(:final response)) {
      List<CoreFavPgcItemModel> list = loadingState.value.data!;
      final item = list.removeAt(index);
      loadingState.refresh();
      try {
        final ctr = Get.find<FavPgcController>(tag: '$type$followStatus');
        if (ctr.loadingState.value case Success(:final response)) {
          response?.insert(0, item);
          ctr
            ..loadingState.refresh()
            ..allSelected.value = false;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fav pgc pgcUpdate: $e');
      }
      SmartDialog.showToast(response);
    } else {
      SmartDialog.showToast(res.toString());
    }
  }
}
