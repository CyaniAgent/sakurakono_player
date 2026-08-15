import 'dart:async';

import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_data_controller.dart';
import 'package:skf/pages/dynamics/dynamics_host.dart';
import 'package:skf/core/account/account_mixin.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/utils/extension/string_ext.dart';
import 'package:skf/core/models/ui/up_panel_position.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';

class DynamicsController
    extends CommonDataController<CoreFollowUpModel, CoreFollowUpModel>
    with GetSingleTickerProviderStateMixin, AccountMixin {
  late final TabController tabController;

  final Set<int> tempBannedList = <int>{};

  String? _offset;
  late int _page = 1;
  late bool _isEnd = false;
  Set<CoreUpItem>? _cacheUpList;
  late int hostMid = -1, currentMid = -1;
  late bool showLiveUp = Pref.expandDynLivePanel;
  late final _showAllUp = Pref.dynamicsShowAllFollowedUp;

  final upPanelPosition = UpPanelPosition.values[Pref.upPanelPosition];

  CoreDynamicsTabType get _currentTabType =>
      CoreDynamicsTabType.values[tabController.index];


  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      vsync: this,
      length: CoreDynamicsTabType.values.length,
      initialIndex: Pref.defaultDynamicTypeIndex,
    );
    queryData();
  }

  void _jumpToTab(int mid) {
    tabController.index = mid == -1 ? 0 : 4;
  }

  void onSelectUp(int mid) {
    if (currentMid == mid) {
      _jumpToTab(mid);
      if (mid == -1) {
        singleRefresh();
      }
      DynamicsHost.of().reloadTab(_currentTabType);
      return;
    }

    if (mid != -1) {
      hostMid = mid;
      DynamicsHost.of().reloadTab(CoreDynamicsTabType.up);
    }

    currentMid = mid;
    _jumpToTab(mid);
  }

  Future<void> singleRefresh() {
    if (_showAllUp) {
      _page = 1;
      _cacheUpList = null;
    }
    _offset = null;
    _isEnd = false;
    return super.onRefresh();
  }

  @override
  Future<void> onRefresh() {
    singleRefresh();
    return DynamicsHost.of().refreshTab(_currentTabType);
  }

  @override
  void animateToTop() {
    DynamicsHost.of().animateTabToTop(_currentTabType);
    scrollController.animToTop();
  }

  @override
  void toTopOrRefresh() {
    final type = _currentTabType;
    if (DynamicsHost.of().tabHasScrollClients(type)) {
      if (DynamicsHost.of().tabScrollPixels(type) == 0) {
        if (scrollController.hasClients &&
            scrollController.position.pixels != 0) {
          scrollController.animToTop();
        }
        EasyThrottle.throttle(
          'topOrRefresh',
          const Duration(milliseconds: 500),
          onRefresh,
        );
      } else {
        animateToTop();
      }
    } else {
      super.toTopOrRefresh();
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  @override
  void onChangeAccount(bool isLogin) => onReload();

  @override
  Future<LoadingState<CoreFollowUpModel>> customGetData() async {
    LoadingState<CoreFollowUpModel> biliResult;
    if (_offset == null) {
      biliResult = await Get.find<DynamicsRepository>().followUp();
    } else if (_showAllUp) {
      biliResult = await Get.find<DynamicsRepository>().followings(
        vmid: DynamicsHost.of().currentUserId,
        pn: _page,
        orderType: 'attention',
        ps: 50,
      );
    } else {
      biliResult = await Get.find<DynamicsRepository>().dynUpList(_offset);
    }
    return switch (biliResult) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  Future<void> queryData([bool isRefresh = true]) {
    if (!isRefresh && _isEnd) return Future.value();
    return super.queryData(isRefresh);
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<CoreFollowUpModel> response) {
    final res = response.response;

    if (_showAllUp) {
      if (res.upList?.isNotEmpty != true) {
        _isEnd = true;
      }
    } else {
      _offset = res.offset;
      if (res.hasMore != true || _offset.isNullOrEmpty) {
        _isEnd = true;
      }
    }

    if (isRefresh) {
      if (_showAllUp) {
        _offset = '';
        _cacheUpList = res.upList?.toSet();
      }
      loadingState.value = response;
    } else {
      if (_showAllUp) {
        _page++;
      }

      if (res.upList case final upList? when upList.isNotEmpty) {
        if (_showAllUp && _cacheUpList != null) {
          upList.removeWhere(_cacheUpList!.contains);
        }
        loadingState
          ..value.data.addAllUpList(upList)
          ..refresh();
      }
    }

    return true;
  }
}
