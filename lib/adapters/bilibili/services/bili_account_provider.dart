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
  String? get displayName => BiliPref.userInfoCache?.uname;

  @override
  bool get isLogin => rxIsLogin.value;
  @override
  String? get face => rxFace.value;

  void onInit() {
    restoreFromCache();
  }

  @override
  Future<void> restoreFromCache() async {
    UserInfoData? userInfo = BiliPref.userInfoCache;
    if (userInfo != null) {
      rxFace.value = userInfo.face ?? '';
      rxIsLogin.value = true;
    }
  }

  Map<String, String> get authHeaders => {};
  @override
  void onAuthStateChanged(Map<String, String> headers) {
    restoreFromCache();
  }
}
