import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for fan (follower) data operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class FanRepository {
  /// Get the fan/follower list for a user.
  Future<LoadingState<CoreFollowData>> fans({
    int? vmid,
    int? pn,
    int ps = 20,
    String? orderType,
  });
}
