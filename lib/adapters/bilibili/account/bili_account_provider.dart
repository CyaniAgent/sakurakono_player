import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/utils/storage.dart';
import 'package:get/get.dart';

class BiliAccountProvider extends GetxService implements AccountProvider {
  late final RxString _rxFace;
  late final RxBool _rxIsLogin;

  @override
  RxString get rxFace => _rxFace;

  @override
  RxBool get rxIsLogin => _rxIsLogin;

  BiliAccountProvider() {
    final cached = GStorage.userInfo.get('userInfoCache');
    _rxFace = RxString(cached?.face ?? '');
    _rxIsLogin = RxBool(Accounts.main.isLogin);
  }

  @override
  String? get face => GStorage.userInfo.get('userInfoCache')?.face;

  @override
  bool get isLogin => Accounts.main.isLogin;

  @override
  String? get userId => Accounts.main.mid.toString();

  @override
  String? get displayName => GStorage.userInfo.get('userInfoCache')?.uname;

  @override
  void restoreFromCache() {
    final cached = GStorage.userInfo.get('userInfoCache');
    if (cached != null) {
      _rxFace.value = cached.face ?? '';
      _rxIsLogin.value = true;
    } else {
      _rxFace.value = '';
      _rxIsLogin.value = false;
    }
  }

  @override
  Map<String, String> get authHeaders => Accounts.main.headers;

  @override
  Map<String, String> get grpcMetadata => Accounts.main.grpcHeaders;

  @override
  Stream<bool> onAuthStateChanged() async* {
    yield Accounts.main.isLogin;
    yield* rxIsLogin.stream;
  }
}
