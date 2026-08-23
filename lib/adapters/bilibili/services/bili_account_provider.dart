import 'package:skf/core/account/account_provider.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/bili_storage_pref.dart';

class BiliAccountProvider extends AccountProvider {
  @override
  bool rxIsLogin = false;
  @override
  String rxFace = '';

  @override
  int? get userId => Accounts.main.isLogin ? Accounts.main.mid : null;
  @override
  String? get displayName => BiliPref.userInfoCache?.uname;

  @override
  bool get isLogin => rxIsLogin;
  @override
  String? get face => rxFace.isEmpty ? null : rxFace;

  void onInit() {
    restoreFromCache();
  }

  @override
  Future<void> restoreFromCache() async {
    UserInfoData? userInfo = BiliPref.userInfoCache;
    if (userInfo != null) {
      rxFace = userInfo.face ?? '';
      rxIsLogin = true;
    }
  }

  Map<String, String> get authHeaders => {};
  @override
  void onAuthStateChanged(Map<String, String> headers) {
    restoreFromCache();
  }
}
