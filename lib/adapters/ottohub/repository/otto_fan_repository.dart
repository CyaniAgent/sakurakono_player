import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/fan_model.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/core/repository/fan_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [FanRepository] that delegates to OttoHub SDK APIs.
///
/// Uses [IFollowingApi] for fan list and active follower data.
class OttoFanRepository implements FanRepository {
  final OttohubClient _client;

  OttoFanRepository(this._client);

  IFollowingApi get _api => _client.following;

  // ---- conversion helpers ----

  LoadingState<T> _ok<T>(T value) => Success(value);

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  CoreFollowItemModel _toCoreFollowItem(FollowingUser u) =>
      CoreFollowItemModel(
        mid: u.uid,
        uname: u.username,
        face: u.avatarUrl,
        sign: u.intro,
      );

  CoreActiveFollower _toCoreActiveFollower(ActiveFollower f) =>
      CoreActiveFollower(
        uid: f.uid,
        username: f.username,
        avatarUrl: f.avatarUrl,
        latestActivityTime: f.latestActivityTime,
      );

  @override
  Future<LoadingState<CoreFollowData>> fans({
    int? vmid,
    int? pn,
    int ps = 20,
    String? orderType,
  }) async {
    try {
      final result = await _api.getFansList(
        vmid ?? 0,
        offset: pn != null ? (pn - 1) * ps : null,
        num: ps,
      );
      return _ok(CoreFollowData(
        list: result.userList.map(_toCoreFollowItem).toList(),
        total: result.userList.length,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoFanRepository.fans ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreActiveFollower?>> activeFollower() async {
    try {
      final list = await _api.getActiveFollowers(0, num: 1);
      return _ok(list.isNotEmpty ? _toCoreActiveFollower(list.first) : null);
    } on ApiException catch (e) {
      debugPrint('OttoFanRepository.activeFollower ApiException: ${e.errorCode}');
      return _err(e);
    }
  }
}
