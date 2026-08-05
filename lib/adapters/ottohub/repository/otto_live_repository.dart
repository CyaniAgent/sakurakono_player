import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/live_enums.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Stub [LiveRepository] — OttoHub SDK has no live streaming API.
///
/// All methods return [Error] with code 'not_implemented'.
class OttoLiveRepository implements LiveRepository {
  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<LoadingState<void>> sendLiveMsg({
    required Object roomId,
    required Object msg,
    Object? dmType,
    Object? emoticonOptions,
    int replyMid = 0,
    String replayDmid = '',
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreRoomPlayInfoData>> liveRoomInfo({
    required Object roomId,
    Object? qn,
    bool onlyAudio = false,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreRoomInfoH5Data>> liveRoomInfoH5({
    required Object roomId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<List<CoreDanmakuMsg>?>> liveRoomDmPrefetch({
    required Object roomId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreLiveDmInfoData>> liveRoomGetDanmakuToken({
    required Object roomId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<List<CoreLiveEmoteDatum>?>> getLiveEmoticons({
    required int roomId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreLiveIndexData>> liveFeedIndex({
    required int pn,
    bool moduleSelect = false,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreLiveFollowData>> liveFollow(int page) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreLiveSecondData>> liveSecondList({
    required int pn,
    required Object? areaId,
    required Object? parentAreaId,
    String? sortType,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<List<CoreAreaList>?>> liveAreaList() async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<List<CoreAreaItem>>> getLiveFavTag() async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> setLiveFavTag({
    required String ids,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<List<CoreAreaItem>?>> liveRoomAreaList({
    required Object parentid,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreLiveSearchData>> liveSearch({
    required int page,
    required String keyword,
    required CoreLiveSearchType type,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreShieldInfo?>> getLiveInfoByUser(
    Object roomId,
  ) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> liveSetSilent({
    required String type,
    required int level,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> addShieldKeyword({
    required String keyword,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> delShieldKeyword({
    required String keyword,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreShieldUserList>> liveShieldUser({
    required Object uid,
    required Object roomid,
    required int type,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> liveLikeReport({
    required int clickTime,
    required Object roomId,
    required Object uid,
    Object? anchorId,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreSuperChatData>> superChatMsg(
    Object roomId,
  ) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> liveDmReport({
    required int roomId,
    required Object mid,
    required String msg,
    required String reason,
    required int reasonId,
    required int dmType,
    required Object idStr,
    required Object ts,
    required Object sign,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreLiveContributionRankData>> liveContributionRank({
    required Object ruid,
    required Object roomId,
    required int page,
    required CoreLiveContributionRankType type,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> superChatReport({
    required int id,
    required Object roomId,
    required Object uid,
    required String msg,
    required String reason,
    required int ts,
    required String token,
  }) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreMedalWallData>> liveMedalWall({
    required Object mid,
  }) async =>
      _err(const ApiException('not_implemented'));
}