import 'package:skf/core/account/account_provider.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/bili_storage_pref.dart';
import 'package:get/get.dart';

class BiliAccountProvider extends AccountProvider {
  @override
  final RxBool rxIsLogin = false.obs;
  @override
  final RxString rxFace = ''.obs;

  @override
  int? get userId => Accounts.main.isLogin ? Accounts.main.mid : null;
  @override
  // 展示缓存（与 rxFace 同源）；身份判断请用 userId / isLogin。
  String? get displayName => BiliPref.userInfoCache?.uname;

  @override
  bool get isLogin => rxIsLogin.value;
  @override
  String? get face => rxFace.value;

  @override
  void onInit() {
    super.onInit();
    restoreFromCache();
  }

  @override
  void restoreFromCache() {
    UserInfoData? userInfo = BiliPref.userInfoCache;
    if (userInfo != null) {
      rxFace.value = userInfo.face ?? '';
      rxIsLogin.value = true;
    }
  }

  @override
  Map<String, String> get authHeaders => {};
  @override
  Stream<bool> onAuthStateChanged() => rxIsLogin.stream;
}
