/// Abstract token that can be used to cancel an in-flight operation.
///
/// This is a core abstraction that replaces adapter-specific cancel tokens
/// (e.g., [dio.CancelToken]). Adapter implementations should map this to
/// their concrete cancel token type.
abstract class CoreCancelToken {
  /// Whether this token has been cancelled.
  bool get isCancelled;

  /// Cancels the operation associated with this token.
  ///
  /// The optional [reason] provides context for the cancellation.
  void cancel([Object? reason]);
}