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

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

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
    // no SDK API (SDK lacks watch_later list endpoint)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> toViewLater({
    String? bvid,
    Object? aid,
  }) async {
    // no SDK API (SDK lacks watch_later add endpoint)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> toViewDel({required String aids}) async {
    // no SDK API (SDK lacks watch_later delete endpoint)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> toViewClear([int? cleanType]) async {
    // no SDK API (SDK lacks watch_later clear endpoint)
    return _err(const ApiException('not_implemented'));
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
      final list = await _client.oldProfile.getHistoryVideoList();
      return Success(CoreHistoryData(
        list: list.map(_convertVideoSummaryToHistory).toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoUserRepository.historyList ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> pauseHistory(bool switchStatus, {Object? account}) async {
    // no SDK API (SDK lacks history pause endpoint)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<bool>> historyStatus({Object? account}) async {
    // no SDK API (SDK lacks history status endpoint)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> clearHistory({Object? account}) async {
    // no SDK API (SDK lacks history clear endpoint)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> delHistory(String kid, {Object? account}) async {
    // no SDK API (SDK lacks history delete endpoint)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreHistoryData>> searchHistory({
    required int pn,
    required String keyword,
    Object? account,
  }) async {
    // no SDK API (SDK lacks history search endpoint)
    return _err(const ApiException('not_implemented'));
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
    // SDK returns collection names only (no ids/metadata) — titles become
    // item titles with index-based ids; pn/ps slice client-side.
    try {
      final collections = await _client.oldCollection
          .getUserVideoCollections(mid);
      final start = (pn - 1) * ps;
      final end = start + ps > collections.length
          ? collections.length
          : start + ps;
      final page = start >= collections.length
          ? const <String>[]
          : collections.sublist(start, end);
      return Success(CoreSubData(
        list: page.asMap().entries.map((e) => CoreSubItemModel(
              id: start + e.key,
              fid: start + e.key,
              title: e.value,
              type: 2,
            )).toList(),
        hasMore: end < collections.length,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoUserRepository.userSubFolder ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  // ── Video tags ───────────────────────────────────────────────────

  @override
  Future<LoadingState<List<CoreVideoTagItem>?>> videoTags({
    required String bvid,
    Object? cid,
  }) async {
    // no SDK API (SDK lacks video tag list endpoint)
    return _err(const ApiException('not_implemented'));
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
    // no SDK API (SDK lacks media list endpoint)
    return _err(const ApiException('not_implemented'));
  }

  // ── Coins ────────────────────────────────────────────────────────

  @override
  Future<LoadingState<num?>> getCoin() async {
    // no SDK API (SDK lacks coin balance endpoint)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreCoinLogData>> coinLog() async {
    // no SDK API (SDK lacks coin log endpoint)
    return _err(const ApiException('not_implemented'));
  }

  // ── Reporting ────────────────────────────────────────────────────

  @override
  Future<LoadingState<void>> dynamicReport({
    required int mid,
    required String dynId,
    required int reasonType,
    String? reasonDesc,
  }) async {
    // no SDK API (SDK lacks dynamic report endpoint)
    return _err(const ApiException('not_implemented'));
  }

  // ── Space / profile settings ─────────────────────────────────────

  @override
  Future<LoadingState<CoreSpaceSettingData>> spaceSetting() async {
    // SDK UserProfile carries no privacy flags; return the default shell.
    try {
      await _client.oldProfile.getUserProfile();
      return Success(CoreSpaceSettingData(
        privacy: CorePrivacy.fromJson(<String, dynamic>{}),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoUserRepository.spaceSetting ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> spaceSettingMod(Map<String, dynamic> data) async {
    // no SDK API (SDK lacks space privacy settings update endpoint)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> spaceReserve({
    required String sid,
    required bool isFollow,
  }) async {
    // no SDK API (SDK lacks space reserve endpoint)
    return _err(const ApiException('not_implemented'));
  }

  // ── VIP ──────────────────────────────────────────────────────────

  @override
  Future<LoadingState<void>> vipExpAdd() async {
    // no SDK API (SDK lacks vip exp add endpoint)
    return _err(const ApiException('not_implemented'));
  }

  // ── Logs ─────────────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreLoginLogData>> loginLog() async {
    // no SDK API (SDK lacks login log endpoint)
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreCoinLogData>> expLog() async {
    // no SDK API (SDK lacks exp log endpoint)
    return _err(const ApiException('not_implemented'));
  }

  // ── User identity ────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreUserRealNameData>> getUserRealName(Object mid) async {
    try {
      final midNum = int.tryParse(mid.toString());
      if (midNum == null) return const Error('missing_argument');
      final detail = await _client.oldUser.getUserDetail(midNum);
      return Success(CoreUserRealNameData(name: detail.username));
    } on ApiException catch (e) {
      debugPrint('OttoUserRepository.getUserRealName ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
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
    try {
      final list = await _client.following.getFollowingList(
        mid,
        offset: pn != null ? (pn - 1) * 20 : null,
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
      debugPrint('OttoUserRepository.sameFollowing ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }
}
