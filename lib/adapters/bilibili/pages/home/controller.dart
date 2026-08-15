import 'dart:async';
import 'dart:math';

import 'package:skf/adapters/bilibili/http/api.dart';
import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/adapters/bilibili/models/common/home_tab_type.dart'; // ignore: adapter import (no core equivalent for HomeTabType)
import 'package:skf/adapters/bilibili/models/common/bar_hide_type.dart';
import 'package:skf/pages/common/common_controller.dart';
import 'package:skf/adapters/bilibili/pages/common/home_tab_helper.dart';
import 'package:skf/adapters/bilibili/pages/main/controller.dart';
import 'package:skf/pages/common/common_page.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/adapters/bilibili/utils/wbi_sign.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin, ScrollOrRefreshMixin
    implements HomeBarState {
  late List<HomeTabType> tabs;
  late TabController tabController;

  @override
  RxBool? showTopBar;
  late final bool hideTopBar;

  bool enableSearchWord = Pref.enableSearchWord;
  late final RxString defaultSearch = ''.obs;
  late int lateCheckSearchAt = 0;

  ScrollOrRefreshMixin get controller => homeTabCtrFor(tabs[tabController.index]);

  @override
  ScrollController get scrollController => controller.scrollController;

  AccountProvider accountService = Get.find<AccountProvider>();

  @override
  void onInit() {
    super.onInit();

    hideTopBar = !Pref.useSideBar && Pref.hideTopBar;
    if (hideTopBar) {
      final mainCtr = Get.find<MainController>();
      switch (mainCtr.barHideType) {
        case BarHideType.instant:
          showTopBar = RxBool(true);
        case BarHideType.sync:
          mainCtr.barOffset ??= RxDouble(0.0);
      }
    }

    if (enableSearchWord) {
      lateCheckSearchAt = DateTime.now().millisecondsSinceEpoch;
      querySearchDefault();
    }

    setTabConfig();
  }

  @override
  Future<void> onRefresh() {
    return controller.onRefresh().catchError((e) {
      if (kDebugMode) debugPrint(e.toString());
    });
  }

  void setTabConfig() {
    final tabs = GStorage.setting.get(SettingBoxKey.tabBarSort) as List?;
    if (tabs != null) {
      this.tabs = tabs.map((i) => HomeTabType.values[i]).toList();
    } else {
      this.tabs = HomeTabType.values;
    }

    tabController = TabController(
      initialIndex: max(0, this.tabs.indexOf(HomeTabType.rcmd)),
      length: this.tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> querySearchDefault() async {
    try {
      final res = await Request().get(
        Api.searchDefault,
        queryParameters: await WbiSign.makSign({'web_location': 333.1365}),
      );
      if (res.data['code'] == 0) {
        defaultSearch.value = res.data['data']?['name'] ?? '';
        // defaultSearch.value = res.data['data']?['show_name'] ?? '';
      }
    } catch (_) {}
  }
}
