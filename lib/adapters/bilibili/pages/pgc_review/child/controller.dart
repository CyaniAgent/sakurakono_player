import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/models/pgc_types.dart';
import 'package:skf/adapters/bilibili/models/common/pgc_review_type.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/container/app_container.dart';

class PgcReviewController
    extends CommonListControllerRiverpod<CorePgcReviewData, CorePgcReviewItemModel> {
  void attachRef(ProviderContainer ref) {}
  PgcReviewController({required this.type, required this.mediaId}) {
    queryData();
  }
  final CorePgcReviewType type;
  final String mediaId;

  int? count;
  String? next;
  PgcReviewSortType sortType = PgcReviewSortType.def;


  @override
  Future<void> onRefresh() {
    next = null;
    return super.onRefresh();
  }

  @override
  void checkIsEnd(int length) {
    final count = this.count;
    if (count != null && length >= count) {
      isEnd = true;
    }
  }

  @override
  List<CorePgcReviewItemModel>? getDataList(CorePgcReviewData response) {
    if (type == CorePgcReviewType.long &&
        sortType == PgcReviewSortType.latest) {
      count = null;
    } else {
      count = response.count;
    }
    next = response.next;

    return response.list;
  }

  @override
  Future<LoadingState<CorePgcReviewData>> customGetData() async {
    final result = await (appRead(pgcRepositoryProvider)).pgcReview(
      type: type,
      mediaId: mediaId,
      next: next,
      sort: sortType.sort,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onLike(CorePgcReviewItemModel item, bool isLike, String reviewId) async {
    final res = await (appRead(pgcRepositoryProvider)).pgcReviewLike(
      mediaId: mediaId,
      reviewId: reviewId,
    );
    if (res.isSuccess) {
      int likes = item.stat?.likes ?? 0;
      item.stat
        ?..liked = isLike ? 0 : 1
        ..likes = isLike ? likes - 1 : likes + 1;
      if (!isLike) {
        item.stat?.disliked = 0;
      }
      notifyListeners();
    } else {
      res.toast();
    }
  }

  Future<void> onDislike(
    CorePgcReviewItemModel item,
    bool isDislike,
    String reviewId,
  ) async {
    final res = await (appRead(pgcRepositoryProvider)).pgcReviewDislike(
      mediaId: mediaId,
      reviewId: reviewId,
    );
    if (res.isSuccess) {
      item.stat?.disliked = isDislike ? 0 : 1;
      if (!isDislike) {
        if (item.stat?.liked == 1) {
          item.stat!.likes = item.stat!.likes! - 1;
        }
        item.stat?.liked = 0;
      }
      notifyListeners();
    } else {
      res.toast();
    }
  }

  Future<void> onDel(int index, int reviewId) async {
    final res = await (appRead(pgcRepositoryProvider)).pgcReviewDel(
      mediaId: mediaId,
      reviewId: '$reviewId',
    );
    if (res.isSuccess) {
      (loadingState as Success).response!.removeAt(index);
      notifyListeners();
      SmartDialog.showToast('删除成功');
    } else {
      res.toast();
    }
  }

  void queryBySort() {
    if (isLoading) return;
    sortType = sortType == PgcReviewSortType.def
        ? PgcReviewSortType.latest
        : PgcReviewSortType.def;
    onReload();
  }
}

/// 每实例注册表 — 页面 view 创建后登记，按 key 经 provider 读取（替代 GetX tag 注册）。
/// 
final Map<String, PgcReviewController> pgcReviewRegistry = {};

final pgcReviewProvider = Provider.family<PgcReviewController, String>(
  (ref, key) => pgcReviewRegistry[key] ??
      (throw StateError('PgcReviewController not registered for key: $key')),
);

