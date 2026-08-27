import 'dart:async' show FutureOr, Timer;

import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/models/user_types.dart';
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

/// Abstract base controller for video intro pages.
///
/// Uses [ChangeNotifier] pattern — plain fields + [notifyListeners].
/// Implements [TripleMixin.notifyChange] to propagate reactive field changes.
abstract class CommonIntroController extends ChangeNotifier
    with TripleMixin, FavMixin {
  CommonIntroController() {
    onInit();
  }

  /// GetxController compatibility.
  bool isClosed = false;
  late final String heroTag;
  late String bvid;

  // 是否稍后再看
  bool _hasLater = false;
  bool get hasLater => _hasLater;
  set hasLater(bool value) {
    if (_hasLater != value) {
      _hasLater = value;
      notifyListeners();
    }
  }

  List<CoreVideoTagItem>? _videoTags;
  List<CoreVideoTagItem>? get videoTags => _videoTags;
  set videoTags(List<CoreVideoTagItem>? value) {
    _videoTags = value;
    notifyListeners();
  }

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

  VideoDetailData _videoDetail = VideoDetailData();
  VideoDetailData get videoDetail => _videoDetail;
  set videoDetail(VideoDetailData value) {
    _videoDetail = value;
    notifyListeners();
  }

  void queryVideoIntro();

  bool prevPlay();
  bool nextPlay();

  void actionShareVideo(BuildContext context);

  // 同时观看
  final bool isShowOnlineTotal = Pref.enableOnlineTotal;
  String _total = '1';
  String get total => _total;
  set total(String value) {
    if (_total != value) {
      _total = value;
      notifyListeners();
    }
  }

  Timer? timer;

  int _cid = 0;
  int get cid => _cid;
  set cid(int value) {
    if (_cid != value) {
      _cid = value;
      notifyListeners();
    }
  }

  late final videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);

  /// TripleMixin notification callback — delegates to [notifyListeners].
  @override
  void notifyChange() => notifyListeners();

  void onInit() {
    final args = Get.arguments;
    heroTag = args['heroTag'];
    bvid = args['bvid'];
    _cid = args['cid'];
    _hasLater = args['sourceType'] == SourceType.watchLater;

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
    final result = await (_ref!.read(videoRepositoryProvider)).onlineTotal(
      aid: IdUtils.bv2av(bvid),
      bvid: bvid,
      cid: _cid,
    );
    if (result case Success(:final response)) {
      total = response;
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
    final res = await (_ref!.read(videoRepositoryProvider)).coinVideo(
      bvid: bvid,
      multiply: coin,
      selectLike: coinWithLike ? 1 : 0,
    );
    if (res.isSuccess) {
      SmartDialog.showToast('投币成功');
      coinNum += coin;
      GlobalData().afterCoin(coin);
      stat.coin += coin;
      if (coinWithLike && !hasLike) {
        stat.like++;
        hasLike = true;
      }
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  Future<void> queryVideoTags() async {
    final result = await (_ref!.read(userRepositoryProvider)).videoTags(bvid: bvid, cid: _cid);
    videoTags = result.dataOrNull;
  }

  Future<void> viewLater() async {
    final res = await (_hasLater
? (_ref!.read(userRepositoryProvider)).toViewDel(aids: IdUtils.bv2av(bvid).toString())
   : (_ref!.read(userRepositoryProvider)).toViewLater(bvid: bvid));
    if (res.isSuccess) hasLater = !hasLater;
  }
}

mixin FavMixin on TripleMixin {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  Set? favIds;
  int? quickFavId;
  late final enableQuickFav = Pref.enableQuickFav;

  CoreFavFolderData _favFolderData = CoreFavFolderData();
  CoreFavFolderData get favFolderData => _favFolderData;
  set favFolderData(CoreFavFolderData value) {
    _favFolderData = value;
    notifyChange();
  }

  (Object, int) get getFavRidType;

  Future<LoadingState<CoreFavFolderData>> queryVideoInFolder() async {
    favIds = null;
    final (rid, type) = getFavRidType;
    final res = await (_ref!.read(favRepositoryProvider)).videoInFolder(
      mid: Accounts.main.mid,
      rid: rid,
      type: type,
    );
    if (res case Success(:final response)) {
      favFolderData = response;
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
    final list = favFolderData.list!;
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
          final hasFav = this.hasFav;
          final result = hasFav
? await (_ref!.read(favRepositoryProvider)).unfavAll(rid, type)
   : await (_ref!.read(favRepositoryProvider)).favVideo(
                  resources: '$rid:$type',
                  addIds: favFolderId.toString(),
                );
          SmartDialog.dismiss();
          if (result.isSuccess) {
            updateFavCount(hasFav ? -1 : 1);
            this.hasFav = !hasFav;
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
      for (final i in favFolderData.list!) {
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
    final result = await (_ref!.read(favRepositoryProvider)).favVideo(
      resources: '$rid:$type',
      addIds: addMediaIdsNew.join(','),
      delIds: delMediaIdsNew.join(','),
    );
    SmartDialog.dismiss();
    if (result.isSuccess) {
      Get.back();
      final newVal =
          addMediaIdsNew.isNotEmpty || favIds?.length != delMediaIdsNew.length;
      if (hasFav != newVal) {
        updateFavCount(newVal ? 1 : -1);
        hasFav = newVal;
      }
      SmartDialog.showToast('${newVal ? '' : '取消'}收藏成功');
    } else {
      SmartDialog.showToast(result.toString());
    }
  }
}
