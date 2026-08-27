import 'package:skf/core/models/reply_types.dart' show CoreMainListReply;
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart';

import 'package:skf/adapters/bilibili/pages/common/reply_controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply/vote/reply_vote_mixin.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

abstract class CommonDynController extends ReplyController<CoreMainListReply>
    with ReplyVoteMixin<CoreMainListReply> {
  Ref? _ref;
  @override
  void attachRef(Ref ref) { _ref = ref; }
  int get oid;
  int get replyType;

  bool showTitle = false;

  late final horizontalPreview = Pref.horizontalPreview;
  late final List<double> ratio = Pref.dynamicDetailRatio;

  late final showDynActionBar = Pref.showDynActionBar;

  @override
  Future<LoadingState<CoreMainListReply>> customGetData() async {
    final result = await (_ref!.read(replyRepositoryProvider)).mainList(
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
  List<ReplyInfo>? getDataList(CoreMainListReply response) {
    return response.replies?.whereType<ReplyInfo>().toList();
  }
}