import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/common/widgets/dialog/dialog.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/pages/common/multi_select/base.dart';
import 'package:skf/pages/common/search/common_search_controller.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:flutter/widgets.dart' show Text;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/router/app_navigator.dart';

class HistorySearchController
    extends CommonSearchController<CoreHistoryData, CoreHistoryItemModel>
    with CommonMultiSelectMixin<CoreHistoryItemModel>, DeleteItemMixin {
  @override
  Future<LoadingState<CoreHistoryData>> customGetData() async {
    final result = await (appRead(userRepositoryProvider)).searchHistory(
    pn: page,
    keyword: editController.value.text,
    account: account,
  );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  List<CoreHistoryItemModel>? getDataList(CoreHistoryData response) {
    return response.list;
  }

  final account = Accounts.history;

  Future<void> onDelHistory(int index, kid, String business) async {
    final res = await (appRead(userRepositoryProvider)).delHistory(
      '${business}_$kid',
      account: account,
    );
    if (res.isSuccess) {
      dataList!.removeAt(index);
      notifyStateChanged();
      SmartDialog.showToast('已删除');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  @override
  void onRemove() {
    showConfirmDialog(
      context: AppNavigator.context!,
      title: const Text('提示'),
      content: const Text('确认删除所选历史记录吗？'),
      onConfirm: () async {
        SmartDialog.showLoading(msg: '请求中');
        final removeList = allChecked.toSet();
        final response = await (appRead(userRepositoryProvider)).delHistory(
          removeList
              .map((item) => '${item.history.business!}_${item.kid!}')
              .join(','),
          account: account,
        );
        if (response.isSuccess) {
          afterDelete(removeList);
          SmartDialog.showToast('已删除');
        } else {
          SmartDialog.showToast(response.toString());
        }
        SmartDialog.dismiss();
      },
    );
  }
}
