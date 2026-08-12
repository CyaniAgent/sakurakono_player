import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/danmaku_block.dart';
import 'package:skf/core/repository/danmaku_filter_repository.dart';
import 'package:skf/core/result/loading_state.dart';

// impossible — no SDK API (OttoHub 无此域)
/// Stub [DanmakuFilterRepository] — OttoHub SDK has no danmaku filter API.
class OttoDanmakuFilterRepository implements DanmakuFilterRepository {
  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<LoadingState<CoreDanmakuBlockDataModel>> danmakuFilter() async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<void>> danmakuFilterDel({required int ids}) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<CoreSimpleRule>> danmakuFilterAdd({
    required String filter,
    required int type,
  }) async =>
      _err(const ApiException('not_implemented'));
}