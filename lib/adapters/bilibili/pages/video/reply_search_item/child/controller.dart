import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart'
    show SearchItemCursorReply;
import 'package:skf/adapters/bilibili/models/common/reply/reply_search_type.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:skf/adapters/bilibili/pages/video/reply_search_item/controller.dart';

class ReplySearchChildController
    extends CommonListController<CoreSearchItemReply, Object?> {
  ReplySearchChildController(this.controller, this.searchType);

  final ReplySearchController controller;
  final ReplySearchType searchType;

  @override
  List<Object?>? getDataList(CoreSearchItemReply response) {
    if (response.cursor case final SearchItemCursorReply cursor?) {
      if (!cursor.hasNext) {
        isEnd = true;
      }
    }
    return response.items;
  }

  @override
  Future<LoadingState<CoreSearchItemReply>> customGetData() async {
    final result = await Get.find<ReplyRepository>().searchItem(
      page: page,
      itemType: searchType == ReplySearchType.video
          ? CoreSearchItemType.video
          : CoreSearchItemType.article,
      oid: controller.oid,
      type: controller.type,
      keyword: controller.editingController.text,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
