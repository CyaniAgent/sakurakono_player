import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart'
    show MainListReply, VoteCard, ReplyInfo;
import 'package:skf/pages/common/common_controller_riverpod.dart';

mixin ReplyVoteMixin<R> on CommonListControllerRiverpod<R, ReplyInfo> {
  VoteCard? voteCard;

  @override
  bool customHandleResponse(bool isRefresh, Success<R> response) {
    if (isRefresh) {
      final res = response.response;
      if (res is MainListReply && res.hasVoteCard()) {
        voteCard = res.voteCard;
      }
    }
    return super.customHandleResponse(isRefresh, response);
  }
}