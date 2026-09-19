import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/utils/storage.dart';

/// OttoHub's [AccountProvider] implementation instance — provided via
/// adapter override (needs the shared [OttohubClient]).
final ottoAccountProvider = Provider<OttoAccountProvider>((ref) {
  throw UnimplementedError('Override via appRead');
});

/// OttoHub implementation of [AccountProvider].
///
/// Holds a reference to the shared [OttohubClient] so that the cached token
/// can be restored on startup, and the auth state can be tracked reactively.
class OttoAccountProvider extends AccountProvider {
  final OttohubClient _client;

  OttoAccountProvider(this._client);

  @override
  bool rxIsLogin = false;
  @override
  String rxFace = '';

  @override
  int? get userId => int.tryParse(_loggedInUid ?? '');
  @override
  String? get displayName => _loggedInName;
  @override
  bool get isLogin {
    _ensureRiverpodSync();
    return rxIsLogin;
  }
  @override
  String? get face => rxFace.isEmpty ? null : rxFace;

  String? _loggedInUid;
  String? _loggedInName;

  /// 启动时序:restoreFromCache 在 appContainer 创建前执行,无法同步
  /// Riverpod accountProvider;改为首次读取登录态时惰性同步一次。
  bool _riverpodSynced = false;

  void _syncRiverpod() {
    try {
      appRead(accountProvider.notifier)
        ..updateLogin(rxIsLogin)
        ..updateFace(rxFace)
        ..updateUserId(userId)
        ..updateDisplayName(_loggedInName);
    } catch (_) {
      // appContainer 未就绪,等下次读取。
      _riverpodSynced = false;
    }
  }

  void _ensureRiverpodSync() {
    if (_riverpodSynced) return;
    _riverpodSynced = true;
    _syncRiverpod();
  }

  /// Hive keys used for persisting credentials across app restarts.
  static const _tokenKey = 'ottohub_token';
  static const _uidKey = 'ottohub_uid';
  static const _nameKey = 'ottohub_name';
  static const _faceKey = 'ottohub_face';

  @override
  Future<void> restoreFromCache() async {
    // 生产环境 registerDependencies 前 GStorage 已 init;容器冒烟测试等
    // 场景未初始化 Hive,LateInitializationError 直接吞掉跳过恢复。
    try {
      _restoreFromCacheUnsafe();
    } catch (e) {
      debugPrint('OttoAccountProvider.restoreFromCache skipped: $e');
    }
  }

  void _restoreFromCacheUnsafe() {
    final cachedToken = GStorage.userInfo.get(_tokenKey) as String?;
    if (cachedToken != null && cachedToken.isNotEmpty) {
      _client.token = cachedToken;
      rxIsLogin = true;
      _loggedInUid = GStorage.userInfo.get(_uidKey) as String?;
      _loggedInName = GStorage.userInfo.get(_nameKey) as String?;
      final cachedFace = GStorage.userInfo.get(_faceKey) as String?;
      if (cachedFace != null) rxFace = cachedFace;
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
    if (face != null) rxFace = face;
    rxIsLogin = true;
    _riverpodSynced = true;
    _syncRiverpod();
    // Persist for next app launch.
    GStorage.userInfo.put(_tokenKey, token);
    GStorage.userInfo.put(_uidKey, uid);
    if (uname != null) GStorage.userInfo.put(_nameKey, uname);
    if (face != null) GStorage.userInfo.put(_faceKey, face);
    // 我的页头部数据源(mine controller 从该缓存渲染账号块)。
    GStorage.userInfo.put(
      'userInfoCache',
      CoreUserInfoData(
        isLogin: true,
        mid: int.tryParse(uid),
        uname: uname,
        face: face,
      ),
    );
  }

  /// Clear cached credentials on logout.
  void clearCredentials() {
    _client.token = null;
    _loggedInUid = null;
    _loggedInName = null;
    rxFace = '';
    rxIsLogin = false;
    _riverpodSynced = true;
    _syncRiverpod();
    GStorage.userInfo.delete(_tokenKey);
    GStorage.userInfo.delete(_uidKey);
    GStorage.userInfo.delete(_nameKey);
    GStorage.userInfo.delete(_faceKey);
    GStorage.userInfo.delete('userInfoCache');
  }

  Map<String, String> get authHeaders => {};
  @override
  void onAuthStateChanged(Map<String, String> headers) {}
}
