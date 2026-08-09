import 'package:skf/core/models/pgc_types.dart';
import 'package:skf/adapters/bilibili/models/common/pgc_review_type.dart';
import 'package:skf/core/repository/pgc_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class PgcReviewController
    extends CommonListController<CorePgcReviewData, CorePgcReviewItemModel> {
  PgcReviewController({required this.type, required this.mediaId});

  final CorePgcReviewType type;
  final String mediaId;

  final count = RxnInt();
  String? next;
  final sortType = PgcReviewSortType.def.obs;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<void> onRefresh() {
    next = null;
    return super.onRefresh();
  }

  @override
  void checkIsEnd(int length) {
    final count = this.count.value;
    if (count != null && length >= count) {
      isEnd = true;
    }
  }

  @override
  List<CorePgcReviewItemModel>? getDataList(CorePgcReviewData response) {
    if (type == CorePgcReviewType.long &&
        sortType.value == PgcReviewSortType.latest) {
      count.value = null;
    } else {
      count.value = response.count;
    }
    next = response.next;

    return response.list;
  }

  @override
  Future<LoadingState<CorePgcReviewData>> customGetData() async {
    final result = await Get.find<PgcRepository>().pgcReview(
      type: type,
      mediaId: mediaId,
      next: next,
      sort: sortType.value.sort,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> onLike(CorePgcReviewItemModel item, bool isLike, String reviewId) async {
    final res = await Get.find<PgcRepository>().pgcReviewLike(
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
      loadingState.refresh();
    } else {
      res.toast();
    }
  }

  Future<void> onDislike(
    CorePgcReviewItemModel item,
    bool isDislike,
    String reviewId,
  ) async {
    final res = await Get.find<PgcRepository>().pgcReviewDislike(
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
      loadingState.refresh();
    } else {
      res.toast();
    }
  }

  Future<void> onDel(int index, int reviewId) async {
    final res = await Get.find<PgcRepository>().pgcReviewDel(
      mediaId: mediaId,
      reviewId: '$reviewId',
    );
    if (res.isSuccess) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
      SmartDialog.showToast('删除成功');
    } else {
      res.toast();
    }
  }

  void queryBySort() {
    if (isLoading) return;
    sortType.value = sortType.value == PgcReviewSortType.def
        ? PgcReviewSortType.latest
        : PgcReviewSortType.def;
    onReload();
  }
}