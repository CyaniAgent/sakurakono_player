import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';

class WhisperBlockController
    extends
        CommonListControllerRiverpod<CoreImKeywordBlockingListReply, CoreImKeywordBlockingItem> {

  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  WhisperBlockController() {
    queryData();
  }

  int count = 0;
  int? listLimit;
  int? charLimit;

  @override
  List<CoreImKeywordBlockingItem>? getDataList(CoreImKeywordBlockingListReply response) {
    count = response.items.length;
    listLimit = response.listLimit;
    charLimit = response.charLimit;
    return response.items;
  }

  @override
  Future<LoadingState<CoreImKeywordBlockingListReply>> customGetData() async {
          final result = await (_ref!.read(imRepositoryProvider)).keywordBlockingList();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onAdd(String keyword) async {
    final res = await (_ref!.read(imRepositoryProvider)).keywordBlockingAdd(keyword);
    if (res.isSuccess) {
      Get.back();
      loadingState.data!.add(CoreImKeywordBlockingItem(keyword: keyword, id: 0));
      notifyListeners();
      count += 1;
      SmartDialog.showToast('添加成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  Future<void> onRemove(CoreImKeywordBlockingItem item) async {
    final res = await (_ref!.read(imRepositoryProvider)).keywordBlockingDelete(item.keyword);
    if (res.isSuccess) {
      loadingState.data!.remove(item);
      notifyListeners();
      count -= 1;
      SmartDialog.showToast('删除成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }
}



