import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/core/repository/black_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/blacklist_data.dart';
import 'package:skf/core/models/blacklist_item.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class BlackListController
    extends CommonListController<CoreBlackListData, CoreBlackListItem> {
  RxInt total = (-1).obs;

  Ref? _ref;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) { _ref = ref; }

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoreBlackListItem>? getDataList(CoreBlackListData response) {
    total.value = response.total ?? 0;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    if (length >= total.value) {
      isEnd = true;
    }
  }

  void onRemove(BuildContext context, int index, name, mid) {
    showConfirmDialog(
      context: context,
      title: Text('确定将 $name 移出黑名单？'),
      onConfirm: () async {
        final result = await (_ref?.read(videoRepositoryProvider) ?? Get.find<VideoRepository>()).relationMod(mid: mid, act: 6, reSrc: 11);
        if (result.isSuccess) {
          loadingState
            ..value.data!.removeAt(index)
            ..refresh();
          total.value -= 1;
          SmartDialog.showToast('移除成功');
        }
      },
    );
  }

  @override
  Future<LoadingState<CoreBlackListData>> customGetData() async {
    final result = await (_ref?.read(blackRepositoryProvider) ?? Get.find<BlackRepository>()).blackList(pn: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
