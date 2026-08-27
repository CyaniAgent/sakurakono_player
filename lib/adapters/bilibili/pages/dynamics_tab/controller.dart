import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/pages/dynamics/controller.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class DynamicsTabController
    extends CommonListControllerRiverpod<CoreDynamicsDataModel, CoreDynamicItemModel> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  DynamicsTabController({required this.dynamicsType}) {
    queryData();
  }
  final CoreDynamicsTabType dynamicsType;

  String? offset;

  late final mainController = appRead(mainControllerProvider);
  final dynamicsController = appRead(dynamicsControllerProvider);

  @override
  Future<void> onRefresh() {
    if (dynamicsType == .all) {
      mainController.setDynCount();
    }
    offset = null;
    return super.onRefresh();
  }

  @override
  List<CoreDynamicItemModel>? getDataList(CoreDynamicsDataModel response) {
    offset = response.offset;
    return response.items;
  }

  @override
  Future<LoadingState<CoreDynamicsDataModel>> customGetData() async {
    final result = await (_ref!.read(dynamicsRepositoryProvider)).followDynamic(
      offset: offset,
      type: dynamicsType,
      hostMid: dynamicsController.hostMid,
      tempBannedList: dynamicsController.tempBannedList,
    );
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  Future<void> onRemove(int index, dynamic dynamicId) async {
    final res = await (_ref!.read(msgRepositoryProvider)).removeDynamic(dynIdStr: dynamicId.toString());
    if (res.isSuccess) {
      loadingState.data!.removeAt(index);
      notifyListeners();
      SmartDialog.showToast('删除成功');
    } else {
      res.toast();
    }
  }

  @override
  Future<void> onReload() {
    scrollController.jumpToTop();
    return super.onReload();
  }

  /// Public rebuild trigger for external consumers that mutate
  /// [loadingState] directly ([notifyListeners] is protected).
  void refreshState() => notifyListeners();

  void onBlock(int index) {
    if (dynamicsType != .up) {
      loadingState.data!.removeAt(index);
      notifyListeners();
    }
  }

  void onUnfold(CoreDynamicItemModel item, int index) {
    try {
      final list = loadingState.data!;
      final ids = item.modules!.moduleFold!.ids!;
      final flag = index + ids.length + 1;
      for (int i = index + 1; i < flag; i++) {
        list[i].visible = true;
      }
      item.modules!.moduleFold = null;
      notifyListeners();
    } catch (_) {}
  }

  }
