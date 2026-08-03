import 'dart:async';
import 'package:get/get.dart';
import 'package:skf/core/account/account_provider.dart';

/// Mixin for controllers that need to react to auth state changes.
/// Substitutes the old Bilibili-specific AccountMixin.
mixin AccountMixin on GetLifeCycleBase {
  StreamSubscription<bool>? _listener;

  AccountProvider get accountService => Get.find<AccountProvider>();

  void onChangeAccount(bool isLogin);

  @override
  void onInit() {
    super.onInit();
    _listener = accountService.onAuthStateChanged().listen(onChangeAccount);
  }

  @override
  void onClose() {
    _listener?.cancel();
    _listener = null;
    super.onClose();
  }
}
