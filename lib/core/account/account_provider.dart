import 'dart:async';
import 'package:riverpod/riverpod.dart';

/// Immutable account state for Riverpod.
class AccountState {
  final String face;
  final bool isLogin;
  final int? userId;
  final String? displayName;

  const AccountState({
    this.face = '',
    this.isLogin = false,
    this.userId,
    this.displayName,
  });

  AccountState copyWith({
    String? face,
    bool? isLogin,
    int? userId,
    String? displayName,
    bool clearUserId = false,
    bool clearDisplayName = false,
  }) {
    return AccountState(
      face: face ?? this.face,
      isLogin: isLogin ?? this.isLogin,
      userId: clearUserId ? null : (userId ?? this.userId),
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
    );
  }
}

/// Riverpod notifier for account state.
///
/// Adapter implementations should extend this class to provide
/// platform-specific account behavior.
class AccountNotifier extends StateNotifier<AccountState> {
  AccountNotifier() : super(const AccountState());

  /// Restore login state from local cache on startup.
  /// Override in adapter implementations.
  void restoreFromCache() {}

  /// Auth headers for API requests.
  Map<String, String> get authHeaders => {};

  /// Stream of auth state changes.
  Stream<bool> onAuthStateChanged() => Stream.value(state.isLogin);

  /// Update face URL.
  void updateFace(String face) {
    state = state.copyWith(face: face);
  }

  /// Update login state.
  void updateLogin(bool isLogin) {
    state = state.copyWith(isLogin: isLogin);
  }

  /// Update user ID.
  void updateUserId(int? userId) {
    state = state.copyWith(userId: userId, clearUserId: userId == null);
  }

  /// Update display name.
  void updateDisplayName(String? displayName) {
    state = state.copyWith(
      displayName: displayName,
      clearDisplayName: displayName == null,
    );
  }

  /// Reset all state.
  void reset() {
    state = const AccountState();
  }
}

/// Riverpod provider for account state.
///
/// Adapter implementations should override this provider to provide
/// platform-specific account behavior.
final accountProvider =
    StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  return AccountNotifier();
});

/// Adapter-agnostic account service interface.
/// Each platform adapter (Bilibili, OttoHub, etc.) provides its own
/// implementation that extends RiverpodAccountMixin for state access.
abstract class AccountProvider {
  /// User avatar URL.
  String rxFace = '';
  /// Login state.
  bool rxIsLogin = false;

  /// User avatar URL.
  String? get face;
  /// Whether the user is logged in.
  bool get isLogin;
  /// Current user ID (null when not logged in).
  int? get userId;
  /// User display name.
  String? get displayName;

  /// Initialize from cache. Called once at app startup.
  Future<void> restoreFromCache();
  /// Called when the adapter detects a cookie/session change.
  void onAuthStateChanged(Map<String, String> headers);
}
