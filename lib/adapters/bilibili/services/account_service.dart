import 'dart:async';

import 'package:skf/core/account/account_provider.dart';
import 'package:get/get.dart';

/// Deprecated - use [Get.find]<[AccountProvider]>() instead.
///
/// Thin backward-compatible wrapper around [AccountProvider].
/// Direct callers may continue using this class; new code should
/// prefer [AccountProvider] directly.
class AccountService extends GetxService {
  final RxBool isLogin = false.obs;
  final RxString face = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final provider = Get.find<AccountProvider>();
    isLogin.value = provider.isLogin;
    face.value = provider.face ?? '';
  }
}

/// Deprecated - use [AccountMixin] from
/// `package:skf/core/account/account_mixin.dart` instead.
mixin AccountMixin on GetLifeCycleBase {
  StreamSubscription<bool>? _listener;

  AccountService get accountService => Get.find<AccountService>();

  void onChangeAccount(bool isLogin);

  @override
  void onInit() {
    super.onInit();
    _listener = accountService.isLogin.listen(onChangeAccount);
  }

  @override
  void onClose() {
    _listener?.cancel();
    _listener = null;
    super.onClose();
  }
}
