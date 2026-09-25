import 'dart:async';

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
      // 单次原子更新:分步 update 会让登录态监听方看到中间态
      // (如 isLogin 已 true 而 userId 未到 → 发出 missing_mid 请求)。
      appRead(accountProvider.notifier).updateAccount(
        userId: userId,
        displayName: _loggedInName,
        face: rxFace,
        isLogin: rxIsLogin,
      );
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
  /// OttoHub token 无刷新机制,另存账密用于过期后静默重登。
  static const _tokenKey = 'ottohub_token';
  static const _uidKey = 'ottohub_uid';
  static const _nameKey = 'ottohub_name';
  static const _faceKey = 'ottohub_face';
  static const _userKey = 'ottohub_username';
  static const _passKey = 'ottohub_password';

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
    String? username,
    String? password,
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
    if (username != null && username.isNotEmpty) {
      GStorage.userInfo.put(_userKey, username);
    }
    if (password != null && password.isNotEmpty) {
      GStorage.userInfo.put(_passKey, password);
    }
    // 我的页头部数据源(mine controller 从该缓存渲染账号块)。
    // CoreUserInfoData 无 Hive 适配器,以 Map 形态存储(读取侧
    // Pref.userInfoCache 兼容两种形态)。
    GStorage.userInfo.put('userInfoCache', userInfoCacheValue);
  }

  /// 当前账号块的 Map 缓存(与 Pref.userInfoCache 的读取约定一致)。
  Map<String, dynamic> get userInfoCacheValue => CoreUserInfoData(
        isLogin: true,
        mid: userId,
        uname: displayName,
        face: face,
      ).toJson();

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
    GStorage.userInfo.delete(_userKey);
    GStorage.userInfo.delete(_passKey);
    GStorage.userInfo.delete('userInfoCache');
  }

  /// 已保存的账密(登录时持久化,供 401 自愈重登);未存过返回 null。
  ({String username, String password})? get savedCredentials {
    final u = GStorage.userInfo.get(_userKey) as String?;
    final p = GStorage.userInfo.get(_passKey) as String?;
    if (u == null || u.isEmpty || p == null || p.isEmpty) return null;
    return (username: u, password: p);
  }

  /// 凭证过期自愈:启动时用便宜接口探测一次,凭证失效则用保存的
  /// 账密静默重登并刷新本地凭证。
  ///
  /// 失效判定覆盖两种形态:HTTP 401(wrapHttpErrors 后
  /// ApiException('error_token', 401))与 HTTP 200 + error_token。
  Future<void> ensureSessionValid() async {
    // 启动钩子里容器已就绪:主动触发一次惰性同步,让重启恢复的
    // token 立刻反映到 Riverpod(侧栏头像/我的页)。调用链处于
    // MainControllerNotifier 的 provider 构建中,同步写 accountProvider
    // 会触发 "modified while building",故推迟到微任务。
    unawaited(Future.microtask(_ensureRiverpodSync));
    if (!rxIsLogin) return;
    final saved = savedCredentials;
    if (saved == null) return;
    try {
      await _client.oldIm.getNewMessageNum();
    } on ApiException catch (e) {
      final authFailed = e.errorCode == 'error_token' ||
          e.httpStatus == 401 ||
          e.httpStatus == 403;
      if (!authFailed) return;
      if (await relogin(saved.username, saved.password)) {
        debugPrint('OttoAccountProvider: token expired, re-login ok');
      }
    } catch (_) {
      // 网络等非凭证异常,交给正常错误链路。
    }
  }

  /// 用账密静默重登并刷新凭证;成功返回 true。
  Future<bool> relogin(String username, String password) async {
    try {
      final result = await _client.auth.login(username, password);
      updateCredentials(
        uid: result.uid,
        token: result.token,
        uname: result.email,
        face: result.avatarUrl,
        username: username,
        password: password,
      );
      return true;
    } catch (e) {
      debugPrint('OttoAccountProvider: re-login failed: $e');
      return false;
    }
  }

  Map<String, String> get authHeaders => {};
  @override
  void onAuthStateChanged(Map<String, String> headers) {}
}
