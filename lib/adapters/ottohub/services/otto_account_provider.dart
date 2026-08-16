import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/utils/storage.dart';
import 'package:get/get.dart';

/// OttoHub implementation of [AccountProvider].
///
/// Holds a reference to the shared [OttohubClient] so that the cached token
/// can be restored on startup, and the auth state can be tracked reactively.
class OttoAccountProvider extends AccountProvider {
  final OttohubClient _client;

  OttoAccountProvider(this._client);

  @override
  final RxBool rxIsLogin = false.obs;
  @override
  final RxString rxFace = ''.obs;

  @override
  int? get userId => int.tryParse(_loggedInUid ?? '');
  @override
  String? get displayName => _loggedInName;
  @override
  bool get isLogin => rxIsLogin.value;
  @override
  String? get face => rxFace.value;

  String? _loggedInUid;
  String? _loggedInName;

  /// Hive keys used for persisting credentials across app restarts.
  static const _tokenKey = 'ottohub_token';
  static const _uidKey = 'ottohub_uid';
  static const _nameKey = 'ottohub_name';
  static const _faceKey = 'ottohub_face';

  @override
  void onInit() {
    super.onInit();
    restoreFromCache();
  }

  @override
  void restoreFromCache() {
    final cachedToken = GStorage.userInfo.get(_tokenKey) as String?;
    if (cachedToken != null && cachedToken.isNotEmpty) {
      _client.token = cachedToken;
      rxIsLogin.value = true;
      _loggedInUid = GStorage.userInfo.get(_uidKey) as String?;
      _loggedInName = GStorage.userInfo.get(_nameKey) as String?;
      final cachedFace = GStorage.userInfo.get(_faceKey) as String?;
      if (cachedFace != null) rxFace.value = cachedFace;
    }
  }

  /// Update cached credentials after a successful login.
  ///
  /// Called from [OttoAuthRepository.loginByPassword] after the token is set.
  void updateCredentials({
    required String uid,
    required String token,
    String? uname,
    String? face,
  }) {
    _client.token = token;
    _loggedInUid = uid;
    _loggedInName = uname;
    if (face != null) rxFace.value = face;
    rxIsLogin.value = true;
    // Persist for next app launch.
    GStorage.userInfo.put(_tokenKey, token);
    GStorage.userInfo.put(_uidKey, uid);
    if (uname != null) GStorage.userInfo.put(_nameKey, uname);
    if (face != null) GStorage.userInfo.put(_faceKey, face);
  }

  /// Clear cached credentials on logout.
  void clearCredentials() {
    _client.token = null;
    _loggedInUid = null;
    _loggedInName = null;
    rxFace.value = '';
    rxIsLogin.value = false;
    GStorage.userInfo.delete(_tokenKey);
    GStorage.userInfo.delete(_uidKey);
    GStorage.userInfo.delete(_nameKey);
    GStorage.userInfo.delete(_faceKey);
  }

  @override
  Map<String, String> get authHeaders => {};
  @override
  Stream<bool> onAuthStateChanged() => rxIsLogin.stream;
}
