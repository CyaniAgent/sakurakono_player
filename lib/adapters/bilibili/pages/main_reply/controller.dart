import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo;
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/pages/common/reply_controller.dart';
import 'package:get/get.dart';

class MainReplyController extends ReplyController<CoreMainListReply> {
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
    final result = await Get.find<ReplyRepository>().mainList(
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
      response.replies?.cast<ReplyInfo>();
}