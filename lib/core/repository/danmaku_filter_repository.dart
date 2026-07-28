import 'package:skf/core/models/danmaku_block.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for danmaku filter operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class DanmakuFilterRepository {
  /// Get the current danmaku block/filter rules.
  Future<LoadingState<CoreDanmakuBlockDataModel>> danmakuFilter();

  /// Delete a danmaku block/filter rule by id.
  Future<LoadingState<void>> danmakuFilterDel({required int ids});

  /// Add a new danmaku block/filter rule.
  Future<LoadingState<CoreSimpleRule>> danmakuFilterAdd({
    required String filter,
    required int type,
  });
}
