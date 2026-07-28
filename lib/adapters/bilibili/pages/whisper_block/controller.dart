import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class WhisperBlockController
    extends
        CommonListController<CoreImKeywordBlockingListReply, CoreImKeywordBlockingItem> {
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  RxInt count = 0.obs;
  int? listLimit;
  int? charLimit;

  @override
  List<CoreImKeywordBlockingItem>? getDataList(CoreImKeywordBlockingListReply response) {
    count.value = response.items.length;
    listLimit = response.listLimit;
    charLimit = response.charLimit;
    return response.items;
  }

  @override
  Future<LoadingState<CoreImKeywordBlockingListReply>> customGetData() async {
          final result = await Get.find<ImRepository>().keywordBlockingList();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onAdd(String keyword) async {
    final res = await Get.find<ImRepository>().keywordBlockingAdd(keyword);
    if (res.isSuccess) {
      Get.back();
      loadingState
        ..value.data!.add(CoreImKeywordBlockingItem(keyword: keyword, id: 0))
        ..refresh();
      count.value += 1;
      SmartDialog.showToast('添加成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  Future<void> onRemove(CoreImKeywordBlockingItem item) async {
    final res = await Get.find<ImRepository>().keywordBlockingDelete(item.keyword);
    if (res.isSuccess) {
      loadingState
        ..value.data!.remove(item)
        ..refresh();
      count.value -= 1;
      SmartDialog.showToast('删除成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }
}



