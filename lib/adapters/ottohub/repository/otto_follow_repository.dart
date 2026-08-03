import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/core/models/follow_status.dart';
import 'package:skf/core/repository/follow_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [FollowRepository] that delegates to [IFollowingApi].
class OttoFollowRepository implements FollowRepository {
  final OttohubClient _client;

  OttoFollowRepository(this._client);

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

  @override
  Future<LoadingState<CoreFollowData>> followings({
    int? vmid,
    int? pn,
    int ps = 20,
    String orderType = '',
  }) async {
    try {
      final uid = vmid ?? 0;
      final result = await _api.getFollowingList(
        uid,
        offset: pn,
        num: ps,
      );
      return _ok(CoreFollowData(
        list: result.userList.map(_toCoreFollowItem).toList(),
        total: result.userList.length,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoFollowRepository.followings ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<void>> toggleFollow({
    required int fid,
    int? type,
  }) async {
    try {
      await _api.toggleFollow(fid);
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoFollowRepository.toggleFollow ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreFollowStatus>> followStatus({
    required int fid,
  }) async {
    try {
      final resp = await _api.getStatus(fid);
      return _ok(CoreFollowStatus(status: resp.followStatus));
    } on ApiException catch (e) {
      debugPrint('OttoFollowRepository.followStatus ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<void>> sortFollowTag({required String tagids}) async {
    // OttoHub API does not have follow tags
    return _err(const ApiException('not_implemented'));
  }
}
