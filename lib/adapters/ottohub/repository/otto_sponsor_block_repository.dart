import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/repository/sponsor_block_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Stub [SponsorBlockRepository] — SponsorBlock is a Bilibili-adjacent service
/// with no OttoHub equivalent.
class OttoSponsorBlockRepository implements SponsorBlockRepository {
  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<LoadingState<List<CoreSegmentItemModel>>> getSkipSegments({
    required String bvid,
    required int cid,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> voteOnSponsorTime({
    required String uuid,
    int? type,
    CoreSegmentType? category,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> viewedVideoSponsorTime(String uuid) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> uptimeStatus() async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreUserInfo>> userInfo(
    List<String> query, {
    String? userId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<List<CoreSegmentItemModel>>> postSkipSegments({
    required String bvid,
    required int cid,
    required double videoDuration,
    required List<CorePostSegmentModel> segments,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<String>> getPortVideo({
    required String bvid,
    required int cid,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<String>> postPortVideo({
    required String bvid,
    required int cid,
    required String ytbId,
    required int videoDuration,
  }) async =>
      _err(const ApiException('not_implemented'));
}