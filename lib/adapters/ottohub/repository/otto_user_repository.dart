import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
// ignore: implementation_imports
import 'package:ottohub_sdk_dart/src/models/old_api/old_user_models.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Converts a [VideoSummary] to a [CoreHistoryItemModel] with available fields.
CoreHistoryItemModel _convertVideoSummaryToHistory(VideoSummary v) {
  return CoreHistoryItemModel(
    title: v.title,
    cover: v.coverUrl,
    history: CoreHistory(
      oid: v.vid,
      bvid: v.vid.toString(),
      cid: v.vid,
      business: 'archive',
    ),
    uri: v.vid.toString(),
    authorName: v.username,
    authorMid: v.uid,
    duration: v.duration,
  );
}

/// Implementation of [UserRepository] that delegates to OttoHub SDK APIs.
///
/// Uses [IOldUserApi] for user lookups and [IOldProfileApi] for profile
/// management (profile fetch, update, favorites, history, etc.).
class OttoUserRepository implements UserRepository {
  final OttohubClient _client;

  OttoUserRepository(this._client);

  // ── Profile & stats ──────────────────────────────────────────────

  @override
  Future<LoadingState<CoreUserInfoData>> userInfo() async {
    try {
      final profile = await _client.oldProfile.getUserProfile();
      UserDetail? detail;
      try {
        detail = await _client.oldUser.getUserDetail(profile.uid);
      } catch (e) {
        debugPrint('OttoUserRepository.userInfo error: $e');
        // non-fatal: avatar optional
      }
      return Success(CoreUserInfoData(
        isLogin: true,
        face: detail?.avatarUrl,
        mid: profile.uid,
        uname: profile.username,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoUserRepository.userInfo ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreUserStat>> userStatOwner() async {
    try {
      final data = await _client.oldProfile.getUserData();
      return Success(CoreUserStat(
        following: data.followingsCount,
        follower: data.fansCount,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoUserRepository.userStatOwner ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  // ── Watch later ──────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreLaterData>> seeYouLater({
    required int page,
    int viewed = 0,
    String keyword = '',
    bool asc = false,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> toViewLater({
    String? bvid,
    Object? aid,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> toViewDel({required String aids}) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> toViewClear([int? cleanType]) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── History ──────────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreHistoryData>> historyList({
    required String type,
    int? max,
    int? viewAt,
    Object? account,
  }) async {
    try {
      final listData = await _client.video.getHistoryList();
      return Success(CoreHistoryData(
        list: listData.videoList
            .map(_convertVideoSummaryToHistory)
            .toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoUserRepository.historyList ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> pauseHistory(bool switchStatus, {Object? account}) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<bool>> historyStatus({Object? account}) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> clearHistory({Object? account}) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> delHistory(String kid, {Object? account}) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreHistoryData>> searchHistory({
    required int pn,
    required String keyword,
    Object? account,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── Relationships ────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreRelationData>> userRelation(int mid) async {
    try {
      final status = await _client.following.getStatus(mid);
      return Success(CoreRelationData(
        attribute: status.followStatus,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoUserRepository.userRelation ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  // ── Subscriptions ────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreSubData>> userSubFolder({
    required int mid,
    required int pn,
    required int ps,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── Video tags ───────────────────────────────────────────────────

  @override
  Future<LoadingState<List<CoreVideoTagItem>?>> videoTags({
    required String bvid,
    Object? cid,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── Media list ───────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreMediaListData>> getMediaList({
    required int type,
    required String bizId,
    required int ps,
    Object? oid,
    int? otype,
    bool withCurrent = false,
    bool desc = true,
    dynamic sortField = 1,
    bool direction = false,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── Coins ────────────────────────────────────────────────────────

  @override
  Future<LoadingState<num?>> getCoin() async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreCoinLogData>> coinLog() async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── Reporting ────────────────────────────────────────────────────

  @override
  Future<LoadingState<void>> dynamicReport({
    required int mid,
    required String dynId,
    required int reasonType,
    String? reasonDesc,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── Space / profile settings ─────────────────────────────────────

  @override
  Future<LoadingState<CoreSpaceSettingData>> spaceSetting() async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> spaceSettingMod(Map<String, dynamic> data) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> spaceReserve({
    required String sid,
    required bool isFollow,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── VIP ──────────────────────────────────────────────────────────

  @override
  Future<LoadingState<void>> vipExpAdd() async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── Logs ─────────────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreLoginLogData>> loginLog() async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreCoinLogData>> expLog() async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── User identity ────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreUserRealNameData>> getUserRealName(Object mid) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }

  // ── Following ────────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreFollowData>> followedUp({
    required int mid,
    required int pn,
  }) async {
    try {
      final midNum = int.tryParse(mid.toString());
      if (midNum == null) return const Error('missing_argument');
      final list = await _client.following.getFollowingList(
        midNum,
        offset: (pn - 1) * 20,
        num: 20,
      );
      return Success(CoreFollowData(
        list: list.userList
            .map((u) => CoreFollowItemModel(
                  mid: u.uid,
                  uname: u.username,
                  face: u.avatarUrl,
                  sign: u.intro,
                ))
            .toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoUserRepository.followedUp ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreFollowData>> sameFollowing({
    required int mid,
    int? pn,
  }) async {
    // TODO(otto): not yet implemented - SDK API unavailable
    return const Error('OttoHub: 功能暂未支持');
  }
}
