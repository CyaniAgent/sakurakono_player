/// Core blacklist status model — adapter-independent.
///
/// Represents the blocking relationship between the current user and a target
/// user. Constructed from any adapter's status response.
class CoreBlackStatus {
  /// Target user UID.
  final int targetUserId;

  /// Whether the current user has blocked the target.
  final bool iBlocked;

  /// Whether the target has blocked the current user.
  final bool heBlocked;

  /// Whether the blocking is mutual (both sides).
  final bool mutualBlock;

  /// Whether any blocking relationship exists.
  final bool anyBlock;

  const CoreBlackStatus({
    required this.targetUserId,
    required this.iBlocked,
    required this.heBlocked,
    required this.mutualBlock,
    required this.anyBlock,
  });
}
