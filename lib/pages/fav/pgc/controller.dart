import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/common/multi_select/multi_select_controller.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class FavPgcController
    extends MultiSelectController<CoreFavPgcData, CoreFavPgcItemModel> {
  FavPgcController(this.type, this.followStatus) {
    queryData();
  }
  final int type;
  final int followStatus;

  Ref? _ref;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) { _ref = ref; }


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
    final result = await (_ref?.read(favRepositoryProvider) ?? Get.find<FavRepository>()).favPgc(
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
    final result = await (_ref?.read(videoRepositoryProvider) ?? Get.find<VideoRepository>()).pgcDel(seasonId: seasonId);
    if (result case Success(:final response)) {
      loadingState.data!.removeAt(index);
      notifyListeners();
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
    final res = await (_ref?.read(videoRepositoryProvider) ?? Get.find<VideoRepository>()).pgcUpdate(
      seasonId: removeList.map((item) => item.seasonId).join(','),
      status: followStatus,
    );
    if (res case Success(:final response)) {
      try {
        final ctr = Get.find<FavPgcController>(tag: '$type$followStatus');
        if (ctr.loadingState case Success(:final response)) {
          response?.insertAll(
            0,
            removeList.map((item) => item..checked = false),
          );
          ctr
            ..notifyListeners()
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
    final res = await (_ref?.read(videoRepositoryProvider) ?? Get.find<VideoRepository>()).pgcUpdate(
      seasonId: seasonId.toString(),
      status: followStatus,
    );
    if (res case Success(:final response)) {
      List<CoreFavPgcItemModel> list = loadingState.data!;
      final item = list.removeAt(index);
      notifyListeners();
      try {
        final ctr = Get.find<FavPgcController>(tag: '$type$followStatus');
        if (ctr.loadingState case Success(:final response)) {
          response?.insert(0, item);
          ctr
            ..notifyListeners()
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
