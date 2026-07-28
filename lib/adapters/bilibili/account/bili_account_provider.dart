import 'package:skf/adapters/bilibili/services/account_service.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/utils/storage.dart';
import 'package:get/get.dart';

class BiliAccountProvider implements AccountProvider {
  @override
  bool get isLoggedIn => Accounts.main.isLogin;

  @override
  String? get userId => Accounts.main.mid.toString();

  @override
  String? get displayName =>
      GStorage.userInfo.get('userInfoCache')?.uname;

  @override
  String? get avatarUrl =>
      GStorage.userInfo.get('userInfoCache')?.face;

  @override
  Future<void> login() {
    throw UnimplementedError('Use Get.toNamed(\'/loginPage\') from UI layer');
  }

  @override
  Future<void> logout() => Accounts.clear();

  @override
  Map<String, String> get authHeaders => Accounts.main.headers;

  @override
  Map<String, String> get grpcMetadata => Accounts.main.grpcHeaders;

  @override
  Stream<bool> onAuthStateChanged() async* {
    yield Accounts.main.isLogin;
    yield* Get.find<AccountService>().isLogin.stream;
  }
}
