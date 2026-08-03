/// Core follow status model — adapter-independent.
///
/// Represents the relationship status between the current user and a target
/// user. `status` values: 0 = not followed, 1 = followed, 2 = mutual follow.
class CoreFollowStatus {
  final int status;

  const CoreFollowStatus({required this.status});
}
