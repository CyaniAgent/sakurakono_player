import 'package:skf/adapters/bilibili/http/sponsor_block.dart';
import 'package:skf/adapters/bilibili/models/common/sponsor_block/action_type.dart';
import 'package:skf/adapters/bilibili/models/common/sponsor_block/post_segment_model.dart';
import 'package:skf/adapters/bilibili/models/common/sponsor_block/segment_type.dart';
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/repository/sponsor_block_repository.dart';
import 'package:skf/core/result/loading_state.dart';
// ignore: unused_import
import 'package:skf/common/widgets/pair.dart';

/// Implementation of [SponsorBlockRepository] that delegates to [SponsorBlock].
class BiliSponsorBlockRepository implements SponsorBlockRepository {
  @override
  Future<LoadingState<List<CoreSegmentItemModel>>> getSkipSegments({
    required String bvid,
    required int cid,
  }) async {
    final result = await SponsorBlock.getSkipSegments(bvid: bvid, cid: cid);
    if (result case Success(response: final r)) {
      return Success(
        r.map((e) => CoreSegmentItemModel.fromJson(e.toJson())).toList(),
      );
    }
    return result as LoadingState<List<CoreSegmentItemModel>>;
  }

  @override
  Future<LoadingState<void>> voteOnSponsorTime({
    required String uuid,
    int? type,
    CoreSegmentType? category,
  }) {
    return SponsorBlock.voteOnSponsorTime(
      uuid: uuid,
      type: type,
      category: category != null ? _toAdapterSegmentType(category) : null,
    );
  }

  @override
  Future<LoadingState<void>> viewedVideoSponsorTime(String uuid) {
    return SponsorBlock.viewedVideoSponsorTime(uuid);
  }

  @override
  Future<LoadingState<void>> uptimeStatus() {
    return SponsorBlock.uptimeStatus();
  }

  @override
  Future<LoadingState<CoreUserInfo>> userInfo(
    List<String> query, {
    String? userId,
  }) async {
    final result = await SponsorBlock.userInfo(query, userId: userId);
    if (result case Success(response: final r)) {
      return Success(CoreUserInfo.fromJson(r.toJson()));
    }
    return result as LoadingState<CoreUserInfo>;
  }

  @override
  Future<LoadingState<List<CoreSegmentItemModel>>> postSkipSegments({
    required String bvid,
    required int cid,
    required double videoDuration,
    required List<CorePostSegmentModel> segments,
  }) async {
    final result = await SponsorBlock.postSkipSegments(
      bvid: bvid,
      cid: cid,
      videoDuration: videoDuration,
      segments: segments.map(_toAdapterPostSegment).toList(),
    );
    if (result case Success(response: final r)) {
      return Success(
        r.map((e) => CoreSegmentItemModel.fromJson(e.toJson())).toList(),
      );
    }
    return result as LoadingState<List<CoreSegmentItemModel>>;
  }

  @override
  Future<LoadingState<String>> getPortVideo({
    required String bvid,
    required int cid,
  }) {
    return SponsorBlock.getPortVideo(bvid: bvid, cid: cid);
  }

  @override
  Future<LoadingState<String>> postPortVideo({
    required String bvid,
    required int cid,
    required String ytbId,
    required int videoDuration,
  }) {
    return SponsorBlock.postPortVideo(
      bvid: bvid,
      cid: cid,
      ytbId: ytbId,
      videoDuration: videoDuration,
    );
  }

  static SegmentType _toAdapterSegmentType(CoreSegmentType t) =>
      SegmentType.values.firstWhere((a) => a.name == t.name);

  static ActionType _toAdapterActionType(CoreActionType t) =>
      ActionType.values.firstWhere((a) => a.name == t.name);

  static PostSegmentModel _toAdapterPostSegment(CorePostSegmentModel m) =>
      PostSegmentModel(
        segment: Pair<double, double>(
          first: m.segment.first,
          second: m.segment.second,
        ),
        category: _toAdapterSegmentType(m.category),
        actionType: _toAdapterActionType(m.actionType),
      );
}
