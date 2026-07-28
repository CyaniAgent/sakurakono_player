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
}
