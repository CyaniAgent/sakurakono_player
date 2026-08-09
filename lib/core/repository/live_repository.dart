import 'package:skf/core/models/live_enums.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for live streaming operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class LiveRepository {
  /// Send a live chat message.
  Future<LoadingState<void>> sendLiveMsg({
    required int roomId,
    required String msg,
    Object? dmType,
    Object? emoticonOptions,
    int replyMid = 0,
    String replayDmid = '',
  });

  /// Get live room playback info (stream URLs, qualities, etc.).
  Future<LoadingState<CoreRoomPlayInfoData>> liveRoomInfo({
    required int roomId,
    Object? qn,
    bool onlyAudio = false,
  });

  /// Get live room info (H5 endpoint).
  Future<LoadingState<CoreRoomInfoH5Data>> liveRoomInfoH5({
    required int roomId,
  });

  /// Prefetch live room danmaku messages.
  Future<LoadingState<List<CoreDanmakuMsg>?>> liveRoomDmPrefetch({
    required int roomId,
  });

  /// Get danmaku WebSocket token for a live room.
  Future<LoadingState<CoreLiveDmInfoData>> liveRoomGetDanmakuToken({
    required int roomId,
  });

  /// Get available live emoticons for a room.
  Future<LoadingState<List<CoreLiveEmoteDatum>?>> getLiveEmoticons({
    required int roomId,
  });

  /// Get the live feed index (recommendation page).
  Future<LoadingState<CoreLiveIndexData>> liveFeedIndex({
    required int pn,
    bool moduleSelect = false,
  });

  /// Get the list of followed live rooms.
  Future<LoadingState<CoreLiveFollowData>> liveFollow(int page);

  /// Get the live second-level list (sorted by area).
  Future<LoadingState<CoreLiveSecondData>> liveSecondList({
    required int pn,
    required int? areaId,
    required int? parentAreaId,
    String? sortType,
  });

  /// Get all live area categories.
  Future<LoadingState<List<CoreAreaList>?>> liveAreaList();

  /// Get the user's favourite live tags.
  Future<LoadingState<List<CoreAreaItem>>> getLiveFavTag();

  /// Set the user's favourite live tags.
  Future<LoadingState<void>> setLiveFavTag({
    required String ids,
  });

  /// Get the sub-area list under a parent live area.
  Future<LoadingState<List<CoreAreaItem>?>> liveRoomAreaList({
    required int parentid,
  });

  /// Search live rooms by keyword.
  Future<LoadingState<CoreLiveSearchData>> liveSearch({
    required int page,
    required String keyword,
    required CoreLiveSearchType type,
  });

  /// Get live room info for a specific user (shield/dm block info).
  Future<LoadingState<CoreShieldInfo?>> getLiveInfoByUser(
    Object roomId,
  );

  /// Set silent mode (mute level) in a live room.
  Future<LoadingState<void>> liveSetSilent({
    required String type,
    required int level,
  });

  /// Add a shield keyword in a live room.
  Future<LoadingState<void>> addShieldKeyword({
    required String keyword,
  });

  /// Remove a shield keyword in a live room.
  Future<LoadingState<void>> delShieldKeyword({
    required String keyword,
  });

  /// Shield/unshield a user in a live room.
  Future<LoadingState<CoreShieldUserList>> liveShieldUser({
    required int uid,
    required int roomid,
    required int type,
  });

  /// Report a like action in a live room.
  Future<LoadingState<void>> liveLikeReport({
    required int clickTime,
    required int roomId,
    required int uid,
    Object? anchorId,
  });

  /// Get super chat messages for a live room.
  Future<LoadingState<CoreSuperChatData>> superChatMsg(
    Object roomId,
  );

  /// Report a danmaku message in a live room.
  Future<LoadingState<void>> liveDmReport({
    required int roomId,
    required int mid,
    required String msg,
    required String reason,
    required int reasonId,
    required int dmType,
    required String idStr,
    required int ts,
    required String sign,
  });

  /// Get the contribution rank for a live room.
  Future<LoadingState<CoreLiveContributionRankData>> liveContributionRank({
    required int ruid,
    required int roomId,
    required int page,
    required CoreLiveContributionRankType type,
  });

  /// Report a super chat message.
  Future<LoadingState<void>> superChatReport({
    required int id,
    required int roomId,
    required int uid,
    required String msg,
    required String reason,
    required int ts,
    required String token,
  });

  /// Get the medal wall for a user.
  Future<LoadingState<CoreMedalWallData>> liveMedalWall({
    required int mid,
  });
}
