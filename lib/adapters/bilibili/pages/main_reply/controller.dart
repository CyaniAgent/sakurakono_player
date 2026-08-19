import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo;
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/adapters/bilibili/pages/common/reply_controller.dart';

class MainReplyController extends ReplyController<CoreMainListReply> {

  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  late final int oid;
  late final int replyType;

  @override
  int get sourceId => oid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    oid = args['oid'];
    replyType = args['replyType'];

    queryData();
  }

  @override
  Future<LoadingState<CoreMainListReply>> customGetData() async {
    final result = await (_ref?.read(replyRepositoryProvider) ?? Get.find<ReplyRepository>()).mainList(
      type: replyType,
      oid: oid,
      mode: mode,
      cursorNext: cursorNext,
      offset: paginationReply?.nextOffset,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  List<ReplyInfo>? getDataList(CoreMainListReply response) =>
      response.replies?.whereType<ReplyInfo>().toList();
}