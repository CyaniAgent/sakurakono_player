import 'package:skf/core/repository/live_repository.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models/common/live/live_dm_silent_type.dart'; // ignore: keep until CoreLiveDmSilentType exists
import 'package:skf/core/models/live_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class LiveDmBlockController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final roomId = Get.parameters['roomId']!;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    queryData();
  }

  late final TabController tabController;

  int? oldLevel;
  final RxInt level = 0.obs;
  final RxInt rank = 0.obs;
  final RxInt verify = 0.obs;
  final RxBool isEnable = false.obs;

  final RxList<String> keywordList = <String>[].obs;
  final RxList<CoreShieldUserList> shieldUserList = <CoreShieldUserList>[].obs;

  void updateValue() {
    isEnable.value = level.value != 0 || rank.value != 0 || verify.value != 0;
  }

  Future<void> queryData() async {
    final res = await Get.find<LiveRepository>().getLiveInfoByUser(roomId);
    if (res case Success(:final response)) {
      final shieldRules = response?.shieldRules;
      level.value = shieldRules?.level ?? 0;
      rank.value = shieldRules?.rank ?? 0;
      verify.value = shieldRules?.verify ?? 0;
      updateValue();

      if (response?.keywordList case final keywordList?) {
        this.keywordList.addAll(keywordList);
      }
      if (response?.shieldUserList case final shieldUserList?) {
        this.shieldUserList.addAll(shieldUserList);
      }
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  Future<bool> setSilent(
    LiveDmSilentType type,
    int level, {
    VoidCallback? onError,
  }) async {
    final res = await Get.find<LiveRepository>().liveSetSilent(type: type.name, level: level);
    if (res.isSuccess) {
      switch (type) {
        case LiveDmSilentType.level:
          this.level.value = level;
        case LiveDmSilentType.rank:
          rank.value = level;
        case LiveDmSilentType.verify:
          verify.value = level;
      }
      updateValue();
      return true;
    } else {
      onError?.call();
      SmartDialog.showToast(res.toString());
      return false;
    }
  }

  Future<void> setEnable(bool enable) async {
    if (enable == isEnable.value) {
      return;
    }
    final futures = enable
        ? [
            setSilent(LiveDmSilentType.rank, 1),
            setSilent(LiveDmSilentType.verify, 1),
          ]
        : [
            for (final e in LiveDmSilentType.values) setSilent(e, 0),
          ];
    final res = await Future.wait(futures);
    if (enable) {
      if (res.any((e) => e)) {
        isEnable.value = true;
      }
    } else {
      if (res.every((e) => e)) {
        isEnable.value = false;
      }
    }
  }

  Future<void> addShieldKeyword(bool isKeyword, String value) async {
    if (isKeyword) {
      final res = await Get.find<LiveRepository>().addShieldKeyword(keyword: value);
      if (res.isSuccess) {
        keywordList.insert(0, value);
      } else {
        SmartDialog.showToast(res.toString());
      }
    } else {
    final res = await Get.find<LiveRepository>().liveShieldUser(
      uid: int.tryParse(value) ?? 0,
      roomid: roomId,
      type: 1,
    );
    if (res case Success(:final response)) {
        shieldUserList.insert(0, response);
      } else {
        SmartDialog.showToast(res.toString());
      }
    }
  }

  Future<void> onRemove(int index, Object item) async {
    assert(item is CoreShieldUserList || item is String);
    if (item is CoreShieldUserList) {
      final res = await Get.find<LiveRepository>().liveShieldUser(
        uid: item.uid!,
        roomid: roomId,
        type: 0,
      );
      if (res.isSuccess) {
        shieldUserList.removeAt(index);
      } else {
        SmartDialog.showToast(res.toString());
      }
    } else {
      final res = await Get.find<LiveRepository>().delShieldKeyword(keyword: item as String);
      if (res.isSuccess) {
        keywordList.removeAt(index);
      } else {
        SmartDialog.showToast(res.toString());
      }
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
