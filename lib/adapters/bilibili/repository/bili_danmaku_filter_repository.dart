
import 'package:skf/adapters/bilibili/http/danmaku_block.dart';
import 'package:skf/adapters/bilibili/models/user/danmaku_block.dart';
import 'package:skf/core/models/danmaku_block.dart';
import 'package:skf/core/repository/danmaku_filter_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [DanmakuFilterRepository] that delegates to [DanmakuFilterHttp].
class BiliDanmakuFilterRepository implements DanmakuFilterRepository {
  // ---- conversion helpers ----

  LoadingState<T> _toCore<T, A>(LoadingState<A> state, T Function(A) convert) {
    return switch (state) {
      Success<A>(:final response) => Success<T>(convert(response)),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
      Loading() => LoadingState<T>.loading(),
    };
  }

  @override
  Future<LoadingState<CoreDanmakuBlockDataModel>> danmakuFilter() async {
    return _toCore(
      await DanmakuFilterHttp.danmakuFilter(),
      _toCoreDanmakuBlockDataModel,
    );
  }

  @override
  Future<LoadingState<void>> danmakuFilterDel({required int ids}) {
    return DanmakuFilterHttp.danmakuFilterDel(ids: ids);
  }

  @override
  Future<LoadingState<CoreSimpleRule>> danmakuFilterAdd({
    required String filter,
    required int type,
  }) async {
    return _toCore(
      await DanmakuFilterHttp.danmakuFilterAdd(filter: filter, type: type),
      (data) => CoreSimpleRule(id: data.id, type: data.type, filter: data.filter),
    );
  }

  static CoreDanmakuBlockDataModel _toCoreDanmakuBlockDataModel(
      DanmakuBlockDataModel data) {
    return CoreDanmakuBlockDataModel.fromJson(<String, dynamic>{
      'rule': data.rule.map(_simpleRuleToJson).toList(),
      'rule1': data.rule1.map(_simpleRuleToJson).toList(),
      'rule2': data.rule2.map(_simpleRuleToJson).toList(),
      'toast': data.toast,
      'valid': data.valid,
      'ver': data.ver,
    });
  }

  static Map<String, dynamic> _simpleRuleToJson(SimpleRule rule) =>
      <String, dynamic>{
        'id': rule.id,
        'type': rule.type,
        'filter': rule.filter,
      };
}