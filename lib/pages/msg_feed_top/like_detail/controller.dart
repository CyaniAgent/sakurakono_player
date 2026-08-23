import 'package:skf/router/app_navigator.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';

class LikeDetailController
    extends CommonListControllerRiverpod<CoreMsgLikeDetailData, CoreMsgLikeDetailItem> {
  late final String cardId;
  late final String? uri;
  late final int counts;

  int lastMid = 0;

  Ref? _ref;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) { _ref = ref; }

  LikeDetailController() {
    final args = AppNavigator.arguments;
    cardId = args['id'];
    uri = args['uri'];
    counts = args['counts'];
    queryData();
  }

  CoreMsgLikeDetailCard? card;

  @override
  List<CoreMsgLikeDetailItem>? getDataList(CoreMsgLikeDetailData response) {
    card = response.card;
    final items = response.items;
    if (items?.lastOrNull?.user?.mid case final mid?) {
      lastMid = mid;
    }
    return items;
  }

  @override
  void checkIsEnd(int length) {
    if (length >= counts) {
      isEnd = true;
    }
  }

  @override
  Future<void> onRefresh() {
    lastMid = 0;
    return super.onRefresh();
  }

  @override
  Future<LoadingState<CoreMsgLikeDetailData>> customGetData() async {
    final result = await (_ref!.read(msgRepositoryProvider)).msgLikeDetail(cardId: cardId, pn: page, lastMid: lastMid);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }
}
