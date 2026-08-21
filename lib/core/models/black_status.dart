import 'package:freezed_annotation/freezed_annotation.dart';

part 'black_status.freezed.dart';

/// Core blacklist status model — adapter-independent.
///
/// Represents the blocking relationship between the current user and a target
/// user. Constructed from any adapter's status response.
@freezed
abstract class CoreBlackStatus with _$CoreBlackStatus {
  const factory CoreBlackStatus({
    /// Target user UID.
    required int targetUserId,

    /// Whether the current user has blocked the target.
    required bool iBlocked,

    /// Whether the target has blocked the current user.
    required bool heBlocked,

    /// Whether the blocking is mutual (both sides).
    required bool mutualBlock,

    /// Whether any blocking relationship exists.
    required bool anyBlock,
  }) = _CoreBlackStatus;
}
