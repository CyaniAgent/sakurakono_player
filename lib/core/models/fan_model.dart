import 'package:freezed_annotation/freezed_annotation.dart';

part 'fan_model.freezed.dart';

/// Core active follower model — adapter-independent.
///
/// Represents a single follower sorted by latest activity time.
  @freezed
abstract class CoreActiveFollower with _$CoreActiveFollower {
  const factory CoreActiveFollower({
    required int uid,
    required String username,
    required String avatarUrl,
    required String latestActivityTime,
  }) = _CoreActiveFollower;
}
