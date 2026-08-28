import 'package:skf/core/result/loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/container/app_container.dart';

class FavTopicController
    extends CommonListControllerRiverpod<CoreFavTopicData, CoreFavTopicItem> {
  FavTopicController() {
    queryData();
  }

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  int? total;


  @override
  void checkIsEnd(int length) {
    if (total != null && length >= total!) {
      isEnd = true;
    }
  }

  @override
  List<CoreFavTopicItem>? getDataList(CoreFavTopicData response) {
    total = response.topicList?.pageInfo?.total;
    return response.topicList?.topicItems;
  }

  @override
  Future<void> onRefresh() {
    total = null;
    return super.onRefresh();
  }

  @override
  Future<LoadingState<CoreFavTopicData>> customGetData() async {
    final result = await (appRead(favRepositoryProvider)).favTopic(page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onDeleteTopic(int index, dynamic id) async {
    final res = await (appRead(favRepositoryProvider)).delFavTopic(id);
    if (res.isSuccess) {
      loadingState.data!.removeAt(index);
      notifyListeners();
      SmartDialog.showToast('已取消收藏');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }
}
