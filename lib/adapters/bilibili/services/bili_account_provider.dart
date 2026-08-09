import 'package:skf/core/account/account_provider.dart';
import 'package:skf/adapters/bilibili/utils/bili_storage_pref.dart';
import 'package:get/get.dart';

class BiliAccountProvider extends AccountProvider {
  @override
  final RxBool rxIsLogin = false.obs;
  @override
  final RxString rxFace = ''.obs;

  @override
  String? get userId => null; // TODO: expose from Accounts
  @override
  String? get displayName => null; // TODO: expose from Accounts

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
  Map<String, String> get grpcMetadata => {};
  @override
  Stream<bool> onAuthStateChanged() => rxIsLogin.stream;
}
