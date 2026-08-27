
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/adapters/bilibili/common/setting_providers.dart';
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
    final provider = appRead(accountProvider);
    isLogin = provider.isLogin;
    face = provider.face;
  }
}

/// Deprecated - use [AccountMixin] from
/// `package:skf/core/account/account_mixin.dart` instead.
mixin AccountMixin on GetLifeCycleBase {
  AccountService get accountService => appRead(accountServiceProvider);

  void onChangeAccount(bool isLogin);
}
