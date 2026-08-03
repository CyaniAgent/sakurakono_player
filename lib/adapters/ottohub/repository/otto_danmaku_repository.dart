import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/danmaku_types.dart';
import 'package:skf/core/repository/danmaku_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [DanmakuRepository] that delegates to [IDanmakuApi].
class OttoDanmakuRepository implements DanmakuRepository {
  final OttohubClient _client;

  OttoDanmakuRepository(this._client);

  IDanmakuApi get _api => _client.danmaku;

  // ---- conversion helpers ----

  LoadingState<T> _ok<T>(T value) => Success(value);

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  // ---- Core model conversion ----

  CoreDanmakuElement _toCoreDanmakuElement(DanmakuItem d) =>
      CoreDanmakuElement(
        id: d.danmakuId,
        content: d.text,
        progress: (d.time * 1000).round(), // seconds → ms
        mode: _modeToInt(d.mode),
        color: int.tryParse(d.color.replaceFirst('#', ''), radix: 16),
        fontsize: int.tryParse(d.fontSize),
      );

  static int? _modeToInt(String mode) {
    switch (mode) {
      case 'scroll':
        return 1;
      case 'top':
        return 5;
      case 'bottom':
        return 4;
      default:
        return 1;
    }
  }

  CoreDanmakuSegmentReply _toCoreSegment(List<DanmakuItem> items) =>
      CoreDanmakuSegmentReply(
        elems: items.map(_toCoreDanmakuElement).toList(),
      );

  @override
  Future<LoadingState<CoreDanmakuPost>> shootDanmaku({
    int type = 1,
    required int oid,
    required String msg,
    int mode = 1,
    required String bvid,
    int? progress,
    int? color,
    int? fontSize,
    int? pool,
    bool colorful = false,
    int? checkboxType,
  }) async {
    try {
      final ottoMode = _intToMode(mode);
      final ottoColor = color != null ? '#${color.toRadixString(16).padLeft(6, '0').toUpperCase()}' : '#FFFFFF';
      await _api.sendDanmaku(
        vid: oid,
        text: msg,
        time: (progress ?? 0) / 1000.0, // ms → seconds
        mode: ottoMode,
        color: ottoColor,
        fontSize: (fontSize ?? 25).toString(),
        render: 'normal',
      );
      return _ok(CoreDanmakuPost(dmid: null));
    } on ApiException catch (e) {
      debugPrint('OttoDanmakuRepository.shootDanmaku ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  static String _intToMode(int mode) {
    switch (mode) {
      case 1:
        return 'scroll';
      case 4:
        return 'bottom';
      case 5:
        return 'top';
      default:
        return 'scroll';
    }
  }

  @override
  Future<LoadingState<void>> danmakuLike({
    required bool isLike,
    required int cid,
    required int id,
  }) async {
    // TODO(otto): not yet implemented — OttoHub API does not have danmaku like
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> danmakuReport({
    required int reason,
    required int cid,
    required int id,
    bool block = false,
    String? content,
  }) async {
    // TODO(otto): not yet implemented — OttoHub API does not have danmaku report
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<String?>> danmakuRecall({
    required int cid,
    required int id,
  }) async {
    try {
      await _api.deleteDanmaku(id);
      return _ok(null);
    } on ApiException catch (e) {
      debugPrint('OttoDanmakuRepository.danmakuRecall ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<String?>> danmakuEditState({
    required int oid,
    required Iterable<int> ids,
    required int state,
  }) async {
    // TODO(otto): not yet implemented — OttoHub API does not support batch edit
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreDanmakuSegmentReply>> dmSegMobile({
    required int cid,
    required int segmentIndex,
    int type = 1,
  }) async {
    try {
      final result = await _api.getDanmaku(cid);
      return _ok(_toCoreSegment(result));
    } on ApiException catch (e) {
      debugPrint('OttoDanmakuRepository.dmSegMobile ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreDanmakuViewReply>> dmView(
    int aid,
    int cid,
  ) async {
    // TODO(otto): not yet implemented — OttoHub API does not have dmView
    return _err(const ApiException('not_implemented'));
  }
}
