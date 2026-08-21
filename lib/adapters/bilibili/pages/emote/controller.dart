import 'package:skf/core/repository/reply_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/models_new/emote/package.dart'; // ignore: adapter import (no core equivalent for Package)
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker, TickerCallback, TickerProvider;

class EmotePanelController extends CommonListControllerRiverpod<List<Package>?, Package>
    implements TickerProvider {
  Ticker? _ticker;
  EmotePanelController() {
    queryData();
  }
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  TabController? tabController;

  @override
  Ticker createTicker(TickerCallback onTick) {
    assert(_ticker == null, 'Only one Ticker per controller');
    _ticker = Ticker(onTick);
    return _ticker!;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<List<Package>?> response) {
    if (response.response?.isNotEmpty == true) {
      tabController = TabController(
        length: response.response!.length,
        vsync: this,
      );
    }
    loadingState = response;
    return true;
  }

  @override
  Future<LoadingState<List<Package>?>> customGetData() async {
    final result = await (_ref?.read(replyRepositoryProvider) ?? Get.find<ReplyRepository>())
        .getEmoteList(business: 'reply');
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response as List<Package>?),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void dispose() {
    _ticker?.dispose();
    tabController?.dispose();
    super.dispose();
  }
}
