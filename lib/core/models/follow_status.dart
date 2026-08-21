import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_status.freezed.dart';

/// Core follow status model — adapter-independent.
///
/// Represents the relationship status between the current user and a target
/// user. `status` values: 0 = not followed, 1 = followed, 2 = mutual follow.
@freezed
abstract class CoreFollowStatus with _$CoreFollowStatus {
  const factory CoreFollowStatus({
    required int status,
  }) = _CoreFollowStatus;
}
