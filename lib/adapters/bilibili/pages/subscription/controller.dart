import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubController extends CommonListControllerRiverpod<CoreSubData, CoreSubItemModel> {
  late final account = Accounts.main;

  SubController() {
    queryData();
  }

  @override
  Future<void> queryData([bool isRefresh = true]) {
    if (!account.isLogin) {
      loadingState = const Error('账号未登录');
      return Future.syncValue(null);
    }
    return super.queryData(isRefresh);
  }

  // 取消订阅
  void cancelSub(CoreSubItemModel subFolderItem) {
    showDialog(
      context: AppNavigator.context!,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('确定取消订阅吗？'),
        actions: [
          TextButton(
            onPressed: AppNavigator.back,
            child: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              final res = await (appRead(favRepositoryProvider)).cancelSub(
                id: subFolderItem.id!,
                type: subFolderItem.type!,
              );
              if (res.isSuccess) {
                if (loadingState case Success(:final response)) {
                  response?.remove(subFolderItem);
                  loadingState = loadingState;
                }
                SmartDialog.showToast('取消订阅成功');
              } else {
                SmartDialog.showToast(res.toString());
              }
              AppNavigator.back();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  List<CoreSubItemModel>? getDataList(CoreSubData response) {
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.list;
  }

  @override
  Future<LoadingState<CoreSubData>> customGetData() async {
    final result = await (appRead(userRepositoryProvider)).userSubFolder(
      pn: page,
      ps: 20,
      mid: account.mid,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}

/// SubController（单实例）。
final subControllerProvider = Provider<SubController>((ref) => SubController());
