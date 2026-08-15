import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class LikeDetailController
    extends CommonListController<CoreMsgLikeDetailData, CoreMsgLikeDetailItem> {
  late final String cardId;
  late final String? uri;
  late final int counts;

  int lastMid = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
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
    final result = await Get.find<MsgRepository>().msgLikeDetail(cardId: cardId, pn: page, lastMid: lastMid);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };
  }
}
