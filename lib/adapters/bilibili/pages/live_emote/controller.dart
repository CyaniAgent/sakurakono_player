import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';

import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/live_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker, TickerCallback, TickerProvider;
import 'package:get/get.dart';

class LiveEmotePanelController
    extends CommonListControllerRiverpod<List<CoreLiveEmoteDatum>?, CoreLiveEmoteDatum>
    implements TickerProvider {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  LiveEmotePanelController(this.roomId) {
    queryData();
  }
  final int roomId;
  TabController? tabController;

  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = Ticker(onTick);
    return ticker;
  }

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<List<CoreLiveEmoteDatum>?> response,
  ) {
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
  Future<LoadingState<List<CoreLiveEmoteDatum>?>> customGetData() async {
    final result = await (_ref!.read(liveRepositoryProvider)).getLiveEmoticons(roomId: roomId);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}
