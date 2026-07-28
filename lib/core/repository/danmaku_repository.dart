import 'package:skf/core/models/danmaku_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for danmaku data operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class DanmakuRepository {
  /// Send a danmaku (bullet comment).
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
  });

  /// Like or unlike a danmaku.
  Future<LoadingState<void>> danmakuLike({
    required bool isLike,
    required int cid,
    required int id,
  });

  /// Report a danmaku.
  Future<LoadingState<void>> danmakuReport({
    required int reason,
    required int cid,
    required int id,
    bool block = false,
    String? content,
  });

  /// Recall (delete) a danmaku you sent.
  Future<LoadingState<String?>> danmakuRecall({
    required int cid,
    required int id,
  });

  /// Batch edit danmaku state (delete/protect/cancel).
  Future<LoadingState<String?>> danmakuEditState({
    required int oid,
    required Iterable<int> ids,
    required int state,
  });

  /// Get danmaku segment (mobile gRPC).
  Future<LoadingState<CoreDanmakuSegmentReply>> dmSegMobile({
    required int cid,
    required int segmentIndex,
    int type = 1,
  });

  /// Get danmaku view (gRPC).
  Future<LoadingState<CoreDanmakuViewReply>> dmView(int aid, int cid);
}
