import 'dart:async' show FutureOr, Timer;

import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models/common/video/source_type.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/stat_detail.dart';
import 'package:skf/pages/video/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/ugc/widgets/triple_mixin.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/global_data.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:skf/core/repository/repository_providers.dart';

/// Minimal state class for CommonIntroController.
///
/// Phase 3: empty — reactive fields (.obs) remain on the controller.
/// Phase 4 will migrate them here.
class CommonIntroState {
  const CommonIntroState();
}

abstract class CommonIntroController extends StateNotifier<CommonIntroState>
    with TripleMixin, FavMixin {
  CommonIntroController() : super(const CommonIntroState()) {
    onInit();
  }

  /// GetxController compatibility — StateNotifier uses [mounted].
  bool get isClosed => !mounted;
  late final String heroTag;
  late String bvid;

  // 是否稍后再看
  final RxBool hasLater = false.obs;

  final Rx<List<CoreVideoTagItem>?> videoTags = Rx<List<CoreVideoTagItem>?>(null);

  bool isProcessing = false;
  Future<void> handleAction(FutureOr Function() action) async {
    if (!isProcessing) {
      isProcessing = true;
      await action();
      isProcessing = false;
    }
  }

  @override
  late final isLogin = Accounts.main.isLogin;

  StatDetail? getStat();

  @override
  void updateFavCount(int count) {
    getStat()?.favorite += count;
  }

  final Rx<VideoDetailData> videoDetail = VideoDetailData().obs;

  void queryVideoIntro();

  bool prevPlay();
  bool nextPlay();

  void actionShareVideo(BuildContext context);

  // 同时观看
  final bool isShowOnlineTotal = Pref.enableOnlineTotal;
  late final RxString total = '1'.obs;
  Timer? timer;

  late final RxInt cid;

  late final videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);

  void onInit() {
    final args = Get.arguments;
    heroTag = args['heroTag'];
    bvid = args['bvid'];
    cid = RxInt(args['cid']);
    hasLater.value = args['sourceType'] == SourceType.watchLater;

    queryVideoIntro();
    startTimer();
  }

  void startTimer() {
    if (isShowOnlineTotal) {
      queryOnlineTotal();
      timer ??= Timer.periodic(const Duration(seconds: 10), (Timer timer) {
        queryOnlineTotal();
      });
    }
  }

  void cancelTimer() {
    timer?.cancel();
    timer = null;
  }

  // 查看同时在看人数
  Future<void> queryOnlineTotal() async {
    if (!isShowOnlineTotal) {
      return;
    }
    final result = await (_ref?.read(videoRepositoryProvider) ?? Get.find<VideoRepository>()).onlineTotal(
      aid: IdUtils.bv2av(bvid),
      bvid: bvid,
      cid: cid.value,
    );
    if (result case Success(:final response)) {
      total.value = response;
    }
  }

  void onClose() {
    cancelTimer();
    disposeTriple();
  }

  @override
  Future<void> onPayCoin(int coin, bool coinWithLike) async {
    final stat = getStat();
    if (stat == null) {
      return;
    }
    final res = await (_ref?.read(videoRepositoryProvider) ?? Get.find<VideoRepository>()).coinVideo(
      bvid: bvid,
      multiply: coin,
      selectLike: coinWithLike ? 1 : 0,
    );
    if (res.isSuccess) {
      SmartDialog.showToast('投币成功');
      coinNum.value += coin;
      GlobalData().afterCoin(coin);
      stat.coin += coin;
      if (coinWithLike && !hasLike.value) {
        stat.like++;
        hasLike.value = true;
      }
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  Future<void> queryVideoTags() async {
    final result = await (_ref?.read(userRepositoryProvider) ?? Get.find<UserRepository>()).videoTags(bvid: bvid, cid: cid.value);
    videoTags.value = result.dataOrNull;
  }

  Future<void> viewLater() async {
    final res = await (hasLater.value
? (_ref?.read(userRepositoryProvider) ?? Get.find<UserRepository>()).toViewDel(aids: IdUtils.bv2av(bvid).toString())
   : (_ref?.read(userRepositoryProvider) ?? Get.find<UserRepository>()).toViewLater(bvid: bvid));
    if (res.isSuccess) hasLater.toggle();
  }
}

mixin FavMixin on TripleMixin {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  Set? favIds;
  int? quickFavId;
  late final enableQuickFav = Pref.enableQuickFav;
  final Rx<CoreFavFolderData> favFolderData = CoreFavFolderData().obs;

  (Object, int) get getFavRidType;

  Future<LoadingState<CoreFavFolderData>> queryVideoInFolder() async {
    favIds = null;
    final (rid, type) = getFavRidType;
    final res = await (_ref?.read(favRepositoryProvider) ?? Get.find<FavRepository>()).videoInFolder(
      mid: Accounts.main.mid,
      rid: rid,
      type: type,
    );
    if (res case Success(:final response)) {
      favFolderData.value = response;
      favIds = response.list
          ?.where((item) => item.favState == 1)
          .map((item) => item.id)
          .toSet();
    }
    return switch (res) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  int get favFolderId {
    if (this.quickFavId != null) {
      return this.quickFavId!;
    }
    final quickFavId = Pref.quickFavId;
    final list = favFolderData.value.list!;
    if (quickFavId != null) {
      final folderInfo = list.firstWhereOrNull((e) => e.id == quickFavId);
      if (folderInfo != null) {
        return this.quickFavId = quickFavId;
      } else {
        GStorage.setting.delete(SettingBoxKey.quickFavId);
      }
    }
    return this.quickFavId = list.first.id;
  }

  // 收藏
  void showFavBottomSheet(BuildContext context, {bool isLongPress = false}) {
    if (!Accounts.main.isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    // 快速收藏 &
    // 点按 收藏至默认文件夹
    // 长按选择文件夹
    if (enableQuickFav) {
      if (!isLongPress) {
        actionFavVideo(isQuick: true);
      } else {
        PageUtils.showFavBottomSheet(context: context, ctr: this);
      }
    } else if (!isLongPress) {
      PageUtils.showFavBottomSheet(context: context, ctr: this);
    }
  }

  void updateFavCount(int count);

  Future<void> actionFavVideo({bool isQuick = false}) async {
    final (rid, type) = getFavRidType;
    // 收藏至默认文件夹
    if (isQuick) {
      SmartDialog.showLoading(msg: '请求中');
      queryVideoInFolder().then((res) async {
        if (res.isSuccess) {
          final hasFav = this.hasFav.value;
          final result = hasFav
? await (_ref?.read(favRepositoryProvider) ?? Get.find<FavRepository>()).unfavAll(rid, type)
   : await (_ref?.read(favRepositoryProvider) ?? Get.find<FavRepository>()).favVideo(
                  resources: '$rid:$type',
                  addIds: favFolderId.toString(),
                );
          SmartDialog.dismiss();
          if (result.isSuccess) {
            updateFavCount(hasFav ? -1 : 1);
            this.hasFav.toggle();
            SmartDialog.showToast('${hasFav ? '取消' : ''}收藏成功');
          } else {
            res.toast();
          }
        } else {
          SmartDialog.dismiss();
        }
      });
      return;
    }

    List<int?> addMediaIdsNew = [];
    List<int?> delMediaIdsNew = [];
    try {
      for (final i in favFolderData.value.list!) {
        bool isFaved = favIds?.contains(i.id) == true;
        if (i.favState == 1) {
          if (!isFaved) {
            addMediaIdsNew.add(i.id);
          }
        } else {
          if (isFaved) {
            delMediaIdsNew.add(i.id);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
    }
    SmartDialog.showLoading(msg: '请求中');
    final result = await (_ref?.read(favRepositoryProvider) ?? Get.find<FavRepository>()).favVideo(
      resources: '$rid:$type',
      addIds: addMediaIdsNew.join(','),
      delIds: delMediaIdsNew.join(','),
    );
    SmartDialog.dismiss();
    if (result.isSuccess) {
      Get.back();
      final newVal =
          addMediaIdsNew.isNotEmpty || favIds?.length != delMediaIdsNew.length;
      if (hasFav.value != newVal) {
        updateFavCount(newVal ? 1 : -1);
        hasFav.value = newVal;
      }
      SmartDialog.showToast('${newVal ? '' : '取消'}收藏成功');
    } else {
      SmartDialog.showToast(result.toString());
    }
  }
}
