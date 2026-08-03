/// Core active follower model — adapter-independent.
///
/// Represents a single follower sorted by latest activity time.
class CoreActiveFollower {
  final int uid;
  final String username;
  final String avatarUrl;
  final String latestActivityTime;

  CoreActiveFollower({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    required this.latestActivityTime,
  });
}
