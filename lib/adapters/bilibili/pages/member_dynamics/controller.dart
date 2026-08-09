import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class MemberDynamicsController
    extends CommonListController<CoreDynamicsDataModel, CoreDynamicItemModel> {
  MemberDynamicsController(this.mid);
  int mid;
  String offset = '';

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<void> onRefresh() {
    offset = '';
    return super.onRefresh();
  }

  @override
  Future<void> queryData([bool isRefresh = true]) {
    if (!isRefresh && (isEnd || offset == '-1')) {
      return Future.syncValue(null);
    }
    return super.queryData(isRefresh);
  }

  @override
  List<CoreDynamicItemModel>? getDataList(CoreDynamicsDataModel response) {
    offset = response.offset?.isNotEmpty == true ? response.offset! : '-1';
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.items;
  }

  @override
  Future<LoadingState<CoreDynamicsDataModel>> customGetData() async {
    final result = await Get.find<MemberRepository>().memberDynamic(
      offset: offset,
      mid: mid,
    );
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  Future<void> onRemove(dynamic dynamicId) async {
    final res = await Get.find<MsgRepository>().removeDynamic(dynIdStr: dynamicId);
    if (res.isSuccess) {
      loadingState
        ..value.data!
            .removeWhere((item) => (item).idStr == dynamicId)
        ..refresh();
      SmartDialog.showToast('删除成功');
    } else {
      res.toast();
    }
  }

  Future<void> onSetTop(bool isTop, String dynamicId) async {
    final res = await (isTop
        ? Get.find<DynamicsRepository>().rmTop(dynamicId: dynamicId)
        : Get.find<DynamicsRepository>().setTop(dynamicId: dynamicId));
    if (res.isSuccess) {
      final list = loadingState.value.data!;
      list[0].modules!
        ..moduleTag = null
        ..moduleAuthor?.isTop = false;
      if (isTop) {
        loadingState.refresh();
        SmartDialog.showToast('取消置顶成功');
      } else {
        final item = list.firstWhere((item) => item.idStr == dynamicId);
        (item).modules!
          ..moduleTag = CoreModuleTag(text: '置顶')
          ..moduleAuthor?.isTop = true;
        list
          ..remove(item)
          ..insert(0, item);
        loadingState.refresh();
        SmartDialog.showToast('置顶成功');
      }
    } else {
      res.toast();
    }
  }
}
