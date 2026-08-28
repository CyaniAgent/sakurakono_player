import 'package:skf/adapters/bilibili/models/common/member/search_type.dart';
import 'package:skf/adapters/bilibili/pages/member_search/child/controller.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skf/router/app_navigator.dart';

class MemberSearchController extends ChangeNotifier {
  late final FocusNode focusNode;
  late final TabController tabController;
  late final TextEditingController editingController;

  final mid = Get.parameters['mid']!;
  final uname = Get.parameters['uname'];

  bool hasData = false;
  List<int> counts = [-1, -1];

  late final MemberSearchChildController arcCtr;
  late final MemberSearchChildController dynCtr;

  MemberSearchController(TickerProvider vsync) {
    focusNode = FocusNode();
    editingController = TextEditingController();
    tabController = TabController(vsync: vsync, length: 2);
    arcCtr = Get.put(
      MemberSearchChildController(this, MemberSearchType.archive),
      tag: Utils.generateRandomString(8),
    );
    dynCtr = Get.put(
      MemberSearchChildController(this, MemberSearchType.dynamic),
      tag: Utils.generateRandomString(8),
    );
  }

  void onClear() {
    if (editingController.value.text.isNotEmpty) {
      editingController.clear();
      counts = [-1, -1];
      hasData = false;
      notifyListeners();
      focusNode.requestFocus();
    } else {
      AppNavigator.back();
    }
  }

  void submit() {
    if (editingController.text.isNotEmpty) {
      hasData = true;
      notifyListeners();
      arcCtr
        ..scrollController.jumpToTop()
        ..onReload();
      dynCtr
        ..scrollController.jumpToTop()
        ..onReload();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    tabController.dispose();
    editingController.dispose();
    super.dispose();
  }
}
