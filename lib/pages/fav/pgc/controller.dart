import 'package:skf/core/result/loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/common/multi_select/multi_select_controller.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/container/app_container.dart';

class FavPgcController
    extends MultiSelectController<CoreFavPgcData, CoreFavPgcItemModel> {
  FavPgcController(this.type, this.followStatus) {
    queryData();
  }
  final int type;
  final int followStatus;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(ProviderContainer ref) {}


  @override
  bool allSelected = false;

  @override
  void handleSelect({bool checked = false, bool disableSelect = true}) {
    allSelected = checked;
    super.handleSelect(checked: checked, disableSelect: disableSelect);
  }

  @override
  List<CoreFavPgcItemModel>? getDataList(CoreFavPgcData response) {
    return response.list;
  }

  @override
  Future<LoadingState<CoreFavPgcData>> customGetData() async {
    final result = await (appRead(favRepositoryProvider)).favPgc(
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
    enableMultiSelect = false;
  }

  // 取消追番
  Future<void> pgcDel(int index, seasonId) async {
    final result = await (appRead(videoRepositoryProvider)).pgcDel(seasonId: seasonId);
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
    final res = await (appRead(videoRepositoryProvider)).pgcUpdate(
      seasonId: removeList.map((item) => item.seasonId).join(','),
      status: followStatus,
    );
    if (res case Success(:final response)) {
      try {
        final ctr = appRead(favPgcControllerProvider('$type$followStatus'));
        if (ctr.loadingState case Success(:final response)) {
          response?.insertAll(
            0,
            removeList.map((item) => item..checked = false),
          );
          ctr
            ..notifyListeners()
            ..allSelected = false;
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
    final res = await (appRead(videoRepositoryProvider)).pgcUpdate(
      seasonId: seasonId.toString(),
      status: followStatus,
    );
    if (res case Success(:final response)) {
      List<CoreFavPgcItemModel> list = loadingState.data!;
      final item = list.removeAt(index);
      notifyListeners();
      try {
        final ctr = appRead(favPgcControllerProvider('$type$followStatus'));
        if (ctr.loadingState case Success(:final response)) {
          response?.insert(0, item);
          ctr
            ..notifyListeners()
            ..allSelected = false;
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

/// 每实例注册表 — 收藏番剧子页 view 创建后登记，按 `${type}${followStatus}` 经
/// [favPgcControllerProvider] 读取（替代 GetX tag 注册）。
final Map<String, FavPgcController> favPgcControllerRegistry = {};

final favPgcControllerProvider = Provider.family<FavPgcController, String>(
  (ref, key) => favPgcControllerRegistry[key] ??
      (throw StateError('FavPgcController not registered for key: $key')),
);
