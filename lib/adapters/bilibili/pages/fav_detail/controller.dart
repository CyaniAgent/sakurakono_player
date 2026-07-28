import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/adapters/bilibili/models/common/video/source_type.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:skf/adapters/bilibili/pages/common/multi_select/base.dart';
import 'package:skf/adapters/bilibili/pages/common/multi_select/multi_select_controller.dart';
import 'package:skf/adapters/bilibili/pages/fav_sort/view.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter/widgets.dart' show Text, ValueChanged;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

mixin BaseFavController
    on
        CommonListController<CoreFavDetailData, CoreFavDetailItemModel>,
        DeleteItemMixin<CoreFavDetailData, CoreFavDetailItemModel> {
  bool get isOwner;
  int get mediaId;

  ValueChanged<int>? updateCount;

  void onViewFav(CoreFavDetailItemModel item, int? index);

  Future<void> onCancelFav(int index, int id, int type) async {
    final res = await Get.find<FavRepository>().favVideo(
      resources: '$id:$type',
      delIds: mediaId.toString(),
    );
    if (res.isSuccess) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
      updateCount?.call(1);
      SmartDialog.showToast('取消收藏');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  @override
  void onRemove() {
    showConfirmDialog(
      context: Get.context!,
      title: const Text('提示'),
      content: const Text('确认删除所选收藏吗？'),
      onConfirm: () async {
        final removeList = allChecked.toSet();
        final res = await Get.find<FavRepository>().favVideo(
          resources: removeList
              .map((item) => '${item.id}:${item.type}')
              .join(','),
          delIds: mediaId.toString(),
        );
        if (res.isSuccess) {
          updateCount?.call(removeList.length);
          afterDelete(removeList);
          SmartDialog.showToast('取消收藏');
        } else {
          SmartDialog.showToast(res.toString());
        }
      },
    );
  }
}

class FavDetailController
    extends MultiSelectController<CoreFavDetailData, CoreFavDetailItemModel>
    with BaseFavController {
  @override
  late int mediaId;
  late String heroTag;
  final Rx<CoreFavFolderInfo> folderInfo = CoreFavFolderInfo().obs;
  final RxBool _isOwner = false.obs;
  final Rx<CoreFavOrderType> order = CoreFavOrderType.mtime.obs;

  @override
  bool get isOwner => _isOwner.value;

  late final account = Accounts.main;

  late double dx = 0;
  late final RxBool isPlayAll = Pref.enablePlayAll.obs;

  void setIsPlayAll(bool isPlayAll) {
    if (this.isPlayAll.value == isPlayAll) return;
    this.isPlayAll.value = isPlayAll;
    GStorage.setting.put(SettingBoxKey.enablePlayAll, isPlayAll);
  }

  @override
  void onInit() {
    super.onInit();

    mediaId = int.parse(Get.parameters['mediaId']!);
    heroTag = Get.parameters['heroTag']!;

    queryData();
  }

  @override
  bool? get hasFooter => true;

  @override
  List<CoreFavDetailItemModel>? getDataList(CoreFavDetailData response) {
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.medias;
  }

  @override
  void checkIsEnd(int length) {
    if (length >= folderInfo.value.mediaCount) {
      isEnd = true;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<CoreFavDetailData> response) {
    if (isRefresh) {
      CoreFavDetailData data = response.response;
      folderInfo.value = data.info!;
      _isOwner.value = data.info?.mid == account.mid;
    }
    return false;
  }

  @override
  ValueChanged<int>? get updateCount =>
      (count) => folderInfo
        ..value.mediaCount -= count
        ..refresh();

  @override
  Future<LoadingState<CoreFavDetailData>> customGetData() async {
    final result = await Get.find<FavRepository>().userFavFolderDetail(
        pn: page,
        ps: 20,
        mediaId: mediaId,
        order: order.value,
      );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  void toViewPlayAll() {
    if (loadingState.value case Success(:final response)) {
      if (response == null || response.isEmpty) return;

      for (CoreFavDetailItemModel element in response) {
        if (element.ugc?.firstCid == null) {
          continue;
        } else {
          onViewFav(element, null);
          break;
        }
      }
    }
  }

  @override
  Future<void> onReload() {
    scrollController.jumpToTop();
    return super.onReload();
  }

  Future<void> onFav(bool isFav) async {
    if (!account.isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final res = isFav
        ? await Get.find<FavRepository>().unfavFavFolder(mediaId)
        : await Get.find<FavRepository>().favFavFolder(mediaId);

    if (res.isSuccess) {
      folderInfo
        ..value.favState = isFav ? 0 : 1
        ..refresh();
      SmartDialog.showToast('${isFav ? '取消' : ''}收藏成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  Future<void> cleanFav() async {
    final res = await Get.find<FavRepository>().cleanFav(mediaId: mediaId);
    if (res.isSuccess) {
      SmartDialog.showToast('清除成功');
      Future.delayed(const Duration(milliseconds: 200), onReload);
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  void onSort() {
    if (loadingState.value case Success(:final response)) {
      if (response != null && response.isNotEmpty) {
        if (folderInfo.value.mediaCount > 1000) {
          SmartDialog.showToast('内容太多啦！超过1000不支持排序');
          return;
        }
        Get.to(FavSortPage(favDetailController: this));
      }
    }
  }

  @override
  void onViewFav(CoreFavDetailItemModel item, int? index) {
    final folder = folderInfo.value;
    // TODO: dimension
    PageUtils.toVideoPage(
      bvid: item.bvid,
      cid: item.ugc!.firstCid!,
      cover: item.cover,
      title: item.title,
      extraArguments: isPlayAll.value
          ? {
              'sourceType': SourceType.fav,
              'mediaId': folder.id,
              'oid': item.id,
              'favTitle': folder.title,
              'count': folder.mediaCount,
              'desc': true,
              if (index != null) 'isContinuePlaying': index != 0,
              'isOwner': isOwner,
            }
          : null,
    );
  }
}
