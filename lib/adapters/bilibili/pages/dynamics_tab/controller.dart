import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/pages/dynamics/controller.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/core/account/account_mixin.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class DynamicsTabController
    extends CommonListController<CoreDynamicsDataModel, CoreDynamicItemModel>
    with AccountMixin {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  DynamicsTabController({required this.dynamicsType});
  final CoreDynamicsTabType dynamicsType;

  String? offset;

  late final mainController = Get.find<MainControllerNotifier>();
  final dynamicsController = Get.find<DynamicsController>();

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

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
    final result = await (_ref?.read(dynamicsRepositoryProvider) ?? Get.find<DynamicsRepository>()).followDynamic(
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
    final res = await (_ref?.read(msgRepositoryProvider) ?? Get.find<MsgRepository>()).removeDynamic(dynIdStr: dynamicId.toString());
    if (res.isSuccess) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
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

  void onBlock(int index) {
    if (dynamicsType != .up) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
    }
  }

  void onUnfold(CoreDynamicItemModel item, int index) {
    try {
      final list = loadingState.value.data!;
      final ids = item.modules!.moduleFold!.ids!;
      final flag = index + ids.length + 1;
      for (int i = index + 1; i < flag; i++) {
        list[i].visible = true;
      }
      item.modules!.moduleFold = null;
      loadingState.refresh();
    } catch (_) {}
  }

  @override
  void onChangeAccount(bool isLogin) => onReload();
}
