import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_status.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for follow/user relationship data operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class FollowRepository {
  /// Get the followings (subscriptions) for a user.
  Future<LoadingState<CoreFollowData>> followings({
    int? vmid,
    int? pn,
    int ps = 20,
    String orderType = '',
  });

  /// Follow or unfollow a user (toggle).
  ///
  /// [fid] is the target user ID. [type] is adapter-specific (ignored for
  /// OttoHub which always toggles; on Bilibili 1=follow, 2=unfollow).
  Future<LoadingState<void>> toggleFollow({
    required int fid,
    int? type,
  });

  /// Get the follow status between the current user and [fid].
  Future<LoadingState<CoreFollowStatus>> followStatus({
    required int fid,
  });

  /// Sort follow tags/groups by the given ordered tag ids.
  Future<LoadingState<void>> sortFollowTag({required String tagids});
}
