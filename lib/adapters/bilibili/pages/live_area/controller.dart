import 'package:skf/core/repository/repository_providers_batch2.dart';

import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:flutter/material.dart' show TabController;
import 'package:flutter/scheduler.dart' show Ticker, TickerCallback, TickerProvider;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveAreaController extends CommonListControllerRiverpod<List<CoreAreaList>?, CoreAreaList>
    implements TickerProvider {
  Ticker? _ticker;
  late final isLogin = Accounts.main.isLogin;

  bool isEditing = false;
  late final favInfo = {};

  TabController? tabController;

  @override
  Ticker createTicker(TickerCallback onTick) {
    assert(_ticker == null, 'Only one Ticker per controller');
    _ticker = Ticker(onTick);
    return _ticker!;
  }

  LiveAreaController() {
    if (isLogin) {
      queryFavTags();
    }
    queryData();
  }

  @override
  Future<void> onRefresh() {
    if (isLogin) {
      queryFavTags();
    }
    return super.onRefresh();
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<List<CoreAreaList>?> response) {
    assert(tabController == null);
    final length = response.response?.length;
    if (length != null && length != 0) {
      tabController = TabController(length: length, vsync: this);
    }
    return super.customHandleResponse(isRefresh, response);
  }

  LoadingState<List<CoreAreaItem>> favState =
      LoadingState<List<CoreAreaItem>>.loading();

  @override
  Future<LoadingState<List<CoreAreaList>?>> customGetData() async {
    final result = await (appRead(liveRepositoryProvider)).liveAreaList();
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> queryFavTags() async {
    final biliResult = await (appRead(liveRepositoryProvider)).getLiveFavTag();
    favState = switch (biliResult) {
      Loading _ => LoadingState<List<CoreAreaItem>>.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  Future<void> setFavTag() async {
    if (favState case Success(:final response)) {
      final biliResult = await (appRead(liveRepositoryProvider)).setLiveFavTag(
        ids: response.map((e) => e.id).join(','),
      );
      final res = switch (biliResult) {
        Loading _ => LoadingState.loading(),
        Success(:final response) => Success(response),
        Error(:final errMsg, :final code) => Error(errMsg, code: code),
      };
      if (res.isSuccess) {
        isEditing = !isEditing;
        SmartDialog.showToast('设置成功');
      } else {
        res.toast();
      }
    } else {
      isEditing = !isEditing;
    }
  }

  void onEdit() {
    if (isEditing) {
      setFavTag();
    } else {
      isEditing = !isEditing;
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    tabController?.dispose();
    tabController = null;
    super.dispose();
  }
}

/// LiveAreaController（单实例）。
final liveAreaControllerProvider = Provider<LiveAreaController>((ref) => LiveAreaController());
