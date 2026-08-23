
import 'package:skf/core/account/account_provider.dart';
import 'package:get/get.dart';

/// Deprecated - use [Get.find]<[AccountProvider]>() instead.
///
/// Thin backward-compatible wrapper around [AccountProvider].
/// Direct callers may continue using this class; new code should
/// prefer [AccountProvider] directly.
class AccountService extends GetxService {
  bool isLogin = false;
  String face = '';

  @override
  void onInit() {
    super.onInit();
    final provider = Get.find<AccountProvider>();
    isLogin = provider.isLogin;
    face = provider.face ?? '';
  }
}

/// Deprecated - use [AccountMixin] from
/// `package:skf/core/account/account_mixin.dart` instead.
mixin AccountMixin on GetLifeCycleBase {
  AccountService get accountService => Get.find<AccountService>();

  void onChangeAccount(bool isLogin);
}
