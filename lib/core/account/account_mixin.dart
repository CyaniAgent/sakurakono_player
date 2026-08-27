import 'package:skf/core/container/app_container.dart';
import 'package:riverpod/riverpod.dart';
import 'package:skf/core/account/account_provider.dart';

/// Mixin for controllers that need to react to auth state changes.
/// Substitutes the old Bilibili-specific AccountMixin.
mixin AccountMixin {
  AccountState get accountService => appRead(accountProvider);

  void onChangeAccount(bool isLogin);

  void initAccountListener() {
    // Account listening now handled by RiverpodAccountMixin.
    // This method is kept for backward compatibility with existing callers.
  }

  void disposeAccountListener() {
    // Account listening now handled by RiverpodAccountMixin.
  }
}

/// Riverpod-aware mixin for controllers that need account state access.
///
/// Attach a [Ref] during initialization to enable Riverpod account
/// state access alongside the existing GetX-based [AccountMixin].
///
/// This is additive — existing GetX controllers continue using
/// [AccountMixin]. New code migrating to Riverpod should use this mixin.
mixin RiverpodAccountMixin {
  Ref? _accountRef;
  ProviderSubscription<AccountState>? _accountSubscription;

  /// Attach a Riverpod [Ref] for account state access.
  /// Call this during controller initialization.
  void attachAccountRef(Ref ref) {
    _accountRef = ref;
  }

  /// Read current account state (non-reactive).
  AccountState get currentAccountState =>
      _accountRef?.read(accountProvider) ?? const AccountState();

  /// Start listening to account state changes.
  /// Call in onInit or similar initialization method.
  void listenToAccountChanges(void Function(AccountState) onChange) {
    _accountSubscription =
        _accountRef?.listen(accountProvider, (prev, next) {
      onChange(next);
    });
  }

  /// Stop listening and clean up. Call in onClose or dispose.
  void disposeAccountListener() {
    _accountSubscription?.close();
    _accountSubscription = null;
  }

  /// Detach the ref. Call in onClose or dispose.
  void detachAccountRef() {
    disposeAccountListener();
    _accountRef = null;
  }
}
