import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class FavCheeseController
    extends CommonListControllerRiverpod<CoreSpaceCheeseData, CoreSpaceCheeseItem> {
  FavCheeseController() {
    queryData();
  }
  Ref? _ref;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) { _ref = ref; }

  late final int mid = (_ref!.read(accountProvider).userId) ?? 0;


  @override
  List<CoreSpaceCheeseItem>? getDataList(CoreSpaceCheeseData response) {
    isEnd = response.page?.next == false;
    return response.items;
  }

  @override
  Future<LoadingState<CoreSpaceCheeseData>> customGetData() async {
    final result = await (_ref!.read(favRepositoryProvider)).favPugv(mid: mid, page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onRemove(int index, int sid) async {
    final res = await (_ref!.read(favRepositoryProvider)).delFavPugv(sid);
    if (res.isSuccess) {
      loadingState.data!.removeAt(index);
      notifyListeners();
      SmartDialog.showToast('已取消收藏');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }
}
