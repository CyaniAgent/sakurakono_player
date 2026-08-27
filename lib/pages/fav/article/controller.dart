import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class FavArticleController
    extends CommonListControllerRiverpod<CoreFavArticleData, CoreFavArticleItemModel> {

  Ref? _ref;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) { _ref = ref; }

  FavArticleController() {
    queryData();
  }

  @override
  List<CoreFavArticleItemModel>? getDataList(CoreFavArticleData response) {
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.items;
  }

  @override
  Future<LoadingState<CoreFavArticleData>> customGetData() async {
    final result = await (_ref!.read(favRepositoryProvider)).favArticle(page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onRemove(int index, String id) async {
    final res = await (_ref!.read(favRepositoryProvider)).communityAction(opusId: id, action: 4);
    if (res.isSuccess) {
      if (loadingState case Success(:final response)) {
        response!.removeAt(index);
      }
      notifyListeners();
      SmartDialog.showToast('已取消收藏');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }
}
