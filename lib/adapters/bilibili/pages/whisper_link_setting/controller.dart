import 'dart:async';

import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/adapters/bilibili/common/widgets/dialog/report_member.dart';
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:flutter/widgets.dart' show Text;

class WhisperLinkSettingController extends GetxController {
  WhisperLinkSettingController({
    required this.talkerUid,
  });

  final int talkerUid;
  RxBool isPinned = false.obs;
  late final sessionId = CoreImSessionId(privateTalkerUid: talkerUid);

  @override
  void onInit() {
    super.onInit();
    getUserInfo();
    getSessionSs();
    getMsgDnd();
    getIsPinned();
  }

  final Rx<LoadingState<List<CoreImUserInfosData>?>> userState =
      LoadingState<List<CoreImUserInfosData>?>.loading().obs;
  final Rx<LoadingState<CoreSessionSsData>> sessionSs =
      LoadingState<CoreSessionSsData>.loading().obs;
  final Rx<LoadingState<List<CoreUidSetting>?>> msgDnd =
      LoadingState<List<CoreUidSetting>?>.loading().obs;

  Future<void> getUserInfo() async {
    final result = await Get.find<MsgRepository>().imUserInfos(uids: talkerUid.toString());
    userState.value = switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  Future<void> getSessionSs() async {
    final result = await Get.find<MsgRepository>().getSessionSs(talkerUid: talkerUid);
    sessionSs.value = switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  Future<void> getMsgDnd() async {
    final result = await Get.find<MsgRepository>().getMsgDnd(uidsStr: talkerUid.toString());
    msgDnd.value = switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  Future<void> getIsPinned() async {
    final res = await Get.find<ImRepository>().sessionUpdate(sessionId: sessionId);
    if (res case Success(:final response)) {
      isPinned.value = response.session?.isPinned ?? false;
    }
  }

  void setPush(bool isPush) {
    if (isPush) {
      showConfirmDialog(
        context: Get.context!,
        title: const Text('确认关闭内容推送吗？'),
        content: const Text('若关闭此开关，你将不再收到该账号的图文消息与稿件推送，但通知类消息不受影响'),
        onConfirm: () => _setPush(isPush),
      );
      return;
    }
    _setPush(isPush);
  }

  Future<void> _setPush(bool isPush) async {
    int setting = isPush ? 1 : 0;
    final res = await Get.find<MsgRepository>().setPushSs(
      setting: setting,
      talkerUid: talkerUid,
    );
    if (res.isSuccess) {
      sessionSs
        ..value.data.pushSetting = setting
        ..refresh();
    } else {
      res.toast();
    }
  }

  Future<void> setPin() async {
    final res = isPinned.value
        ? await Get.find<ImRepository>().unpinSession(sessionId: sessionId)
        : await Get.find<ImRepository>().pinSession(sessionId: sessionId);
    if (res.isSuccess) {
      isPinned.toggle();
    } else {
      res.toast();
    }
  }

  Future<void> setMute(bool isMuted) async {
    int setting = isMuted ? 0 : 1;
    final res = await Get.find<MsgRepository>().setMsgDnd(
      uid: Accounts.main.mid,
      setting: setting,
      dndUid: talkerUid,
    );
    if (res.isSuccess) {
      if (msgDnd.value case Success(:final response) when response != null && response.isNotEmpty) {
        response.first.setting = setting;
        msgDnd.refresh();
      }
    } else {
      res.toast();
    }
  }

  Future<void> setBlock(bool isBlocked) async {
    if (isBlocked) {
      final res = await Get.find<VideoRepository>().relationMod(
        mid: talkerUid,
        act: 6,
        reSrc: 11,
      );
      if (res.isSuccess) {
        sessionSs
          ..value.data.followStatus = null
          ..refresh();
      } else {
        res.toast();
      }
    } else {
      showConfirmDialog(
        context: Get.context!,
        title: const Text('确认拉黑该用户'),
        content: const Text('加入黑名单后，将自动解除关注关系和对该用户的合集订阅关系，禁止该用户与我互动或查看我的空间'),
        onConfirm: () async {
          final res = await Get.find<VideoRepository>().relationMod(
            mid: talkerUid,
            act: 5,
            reSrc: 11,
          );
          if (res.isSuccess) {
            sessionSs
              ..value.data.followStatus = 128
              ..refresh();
          } else {
            res.toast();
          }
        },
      );
    }
  }

  void report() => showMemberReportDialog(
    Get.context!,
    name: userState.value.dataOrNull?.firstOrNull?.name,
    mid: talkerUid,
  );
}
