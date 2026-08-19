import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart'
    show SearchItemCursorReply;
import 'package:skf/adapters/bilibili/models/common/reply/reply_search_type.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply_search_item/controller.dart';

class ReplySearchChildController
    extends CommonListController<CoreSearchItemReply, Object?> {

  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  ReplySearchChildController(this.notifier, this.searchType);

  final ReplySearchNotifier notifier;
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
    final result = await (_ref?.read(replyRepositoryProvider) ??
            Get.find<ReplyRepository>())
        .searchItem(
      page: page,
      itemType: searchType == ReplySearchType.video
          ? CoreSearchItemType.video
          : CoreSearchItemType.article,
      oid: notifier.oid,
      type: notifier.type,
      keyword: notifier.editingController.text,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
