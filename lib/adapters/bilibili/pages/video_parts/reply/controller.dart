import 'package:skf/core/models/reply_types.dart' show CoreMainListReply;
import 'package:skf/core/models/video_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo;
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/adapters/bilibili/pages/common/reply_controller.dart';
import 'package:skf/pages/video/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply/vote/reply_vote_mixin.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:skf/core/container/app_container.dart';

class VideoReplyController extends ReplyController<CoreMainListReply>
    with ReplyVoteMixin<CoreMainListReply> {
  Ref? _ref;
  @override
  void attachRef(Ref ref) { _ref = ref; }
  VideoReplyController({
    required this.aid,
    required this.videoType,
    required this.heroTag,
  });
  int aid;
  final CoreVideoType videoType;
  late final isPugv = videoType == CoreVideoType.pugv;

  final String heroTag;
  late final videoCtr = appRead(videoDetailControllerProvider(heroTag));

  @override
  dynamic get sourceId => IdUtils.av2bv(aid);

  @override
  List<ReplyInfo>? getDataList(CoreMainListReply response) {
    return response.replies?.whereType<ReplyInfo>().toList();
  }

  @override
  Future<LoadingState<CoreMainListReply>> customGetData() async {
    final result = await (_ref!.read(replyRepositoryProvider)).mainList(
      oid: isPugv ? videoCtr.epId! : aid,
      type: videoType.replyType,
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
}
/// 评论控制器（每视频页一实例，按 heroTag 键控；aid/videoType 取自注册表）。
final videoReplyControllerProvider = ChangeNotifierProvider
    .family<VideoReplyController, String>(
  (ref, heroTag) => VideoReplyController(
    aid: videoDetailRegistry[heroTag]?.aid ?? 0,
    videoType: videoDetailRegistry[heroTag]?.videoType ?? CoreVideoType.ugc,
    heroTag: heroTag,
  ),
);
