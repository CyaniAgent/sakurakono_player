import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/black_status.dart';
import 'package:skf/core/models/blacklist_data.dart';
import 'package:skf/core/models/blacklist_item.dart';
import 'package:skf/core/repository/black_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [BlackRepository] that delegates to [IBlockApi].
class OttoBlackRepository implements BlackRepository {
  final OttohubClient _client;

  OttoBlackRepository(this._client);

  IBlockApi get _api => _client.block;

  // ---- conversion helpers ----

  LoadingState<T> _ok<T>(T value) => Success(value);

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  CoreBlackListItem _toCoreBlackItem(BlockRecord r) => CoreBlackListItem(
    mid: r.blockedId,
    uname: r.username,
    face: r.avatar,
    mtime: _parseTime(r.createdAt),
  );

  CoreBlackStatus _toCoreBlackStatus(BlockStatusResponse r) =>
      CoreBlackStatus(
        targetUserId: r.targetUserId,
        iBlocked: r.iBlocked,
        heBlocked: r.heBlocked,
        mutualBlock: r.mutualBlock,
        anyBlock: r.anyBlock,
      );

  /// Best-effort parse of a date-time string to epoch seconds.
  static int? _parseTime(String time) {
    final dt = DateTime.tryParse(time);
    final ms = dt?.millisecondsSinceEpoch;
    return ms != null ? ms ~/ 1000 : null;
  }

  @override
  Future<LoadingState<CoreBlackListData>> blackList({
    required int pn,
    int ps = 50,
  }) async {
    try {
      final result = await _api.getBlockList(page: pn, pageSize: ps);
      return _ok(CoreBlackListData(
        list: result.list.map(_toCoreBlackItem).toList(),
        total: result.total,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoBlackRepository.blackList ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<void>> addBlack({required int uid}) async {
    try {
      await _api.blockUser(uid);
      return _ok(null);
    } on ApiException catch (e) {
      debugPrint('OttoBlackRepository.addBlack ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<void>> removeBlack({required int uid}) async {
    try {
      await _api.unblockUser(uid);
      return _ok(null);
    } on ApiException catch (e) {
      debugPrint('OttoBlackRepository.removeBlack ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreBlackStatus>> checkBlack({required int uid}) async {
    try {
      final result = await _api.getBlockStatus(uid);
      return _ok(_toCoreBlackStatus(result));
    } on ApiException catch (e) {
      debugPrint('OttoBlackRepository.checkBlack ApiException: ${e.errorCode}');
      return _err(e);
    }
  }
}
