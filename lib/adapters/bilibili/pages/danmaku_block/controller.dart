import 'dart:convert';

import 'package:skf/adapters/bilibili/http/danmaku_block.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models/common/dm_block_type.dart';
import 'package:skf/adapters/bilibili/models/user/danmaku_block.dart' show SimpleRule;
import 'package:skf/core/models/danmaku_block.dart';
import 'package:archive/archive.dart' show getCrc32;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

CoreSimpleRule _toCore(SimpleRule r) =>
    CoreSimpleRule(id: r.id, type: r.type, filter: r.filter);

class DanmakuBlockController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final List<RxList<CoreSimpleRule>> rules = List.generate(
    DmBlockType.values.length,
    (_) => <CoreSimpleRule>[].obs,
  );

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    queryDanmakuFilter();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> queryDanmakuFilter() async {
    SmartDialog.showLoading(msg: '正在同步弹幕屏蔽规则……');
    final result = await DanmakuFilterHttp.danmakuFilter();
    SmartDialog.dismiss();
    if (result case Success(:final response)) {
      rules[0].addAll(response.rule.map(_toCore));
      rules[1].addAll(response.rule1.map(_toCore));
      rules[2].addAll(response.rule2.map(_toCore));
      if (response.toast case final toast?) {
        SmartDialog.showToast(toast);
      }
    } else {
      result.toast();
    }
  }

  Future<void> danmakuFilterDel(int tabIndex, int itemIndex, int id) async {
    SmartDialog.showLoading(msg: '正在删除弹幕屏蔽规则……');
    final res = await DanmakuFilterHttp.danmakuFilterDel(ids: id);
    SmartDialog.dismiss();
    if (res.isSuccess) {
      rules[tabIndex].removeAt(itemIndex);
      SmartDialog.showToast('删除成功');
    } else {
      res.toast();
    }
  }

  Future<void> danmakuFilterAdd({
    required String filter,
    required int type,
  }) async {
    if (type == 2) {
      filter = getCrc32(ascii.encode(filter), 0).toRadixString(16);
    }
    SmartDialog.showLoading(msg: '正在添加弹幕屏蔽规则……');
    final res = await DanmakuFilterHttp.danmakuFilterAdd(
      filter: filter,
      type: type,
    );
    SmartDialog.dismiss();
    if (res case Success(:final response)) {
      rules[type].add(_toCore(response));
      SmartDialog.showToast('添加成功');
    } else {
      res.toast();
    }
  }
}
