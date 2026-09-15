import 'package:skf/adapters/bilibili/models/common/member/search_type.dart';
import 'package:skf/adapters/bilibili/pages/member_search/child/controller.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter/material.dart';
import 'package:skf/router/app_navigator.dart';

class MemberSearchController extends ChangeNotifier {
  late final FocusNode focusNode;
  late final TabController tabController;
  late final TextEditingController editingController;

  final String mid;
  final String? uname;

  bool hasData = false;
  List<int> counts = [-1, -1];

  late final MemberSearchChildController arcCtr;
  late final MemberSearchChildController dynCtr;

  MemberSearchController(this.mid, {this.uname, required TickerProvider vsync}) {
    focusNode = FocusNode();
    editingController = TextEditingController();
    tabController = TabController(vsync: vsync, length: 2);
    arcCtr = MemberSearchChildController(this, MemberSearchType.archive);
    dynCtr = MemberSearchChildController(this, MemberSearchType.dynamic);
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
