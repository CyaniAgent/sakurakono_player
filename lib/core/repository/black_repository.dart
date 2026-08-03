import 'package:skf/core/models/black_status.dart';
import 'package:skf/core/models/blacklist_data.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for blacklist data operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class BlackRepository {
  /// Get the blacklist entries for the current user.
  Future<LoadingState<CoreBlackListData>> blackList({
    required int pn,
    int ps = 50,
  });

  /// Add [uid] to the current user's blacklist.
  Future<LoadingState<void>> addBlack({required int uid});

  /// Remove [uid] from the current user's blacklist.
  Future<LoadingState<void>> removeBlack({required int uid});

  /// Check the blocking status between the current user and [uid].
  Future<LoadingState<CoreBlackStatus>> checkBlack({required int uid});
}
