import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/auth_types.dart';
import 'package:skf/core/repository/auth_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/ottohub/services/otto_account_provider.dart';

/// Implementation of [AuthRepository] that delegates to [IAuthApi].
///
/// ## Supported operations
/// | AuthRepository method   | OttoHub SDK support                    |
/// |-------------------------|----------------------------------------|
/// | loginByPassword         | ✅ `IAuthApi.login(uidEmail, password)` |
/// | logout                  | ✅ Token cleared locally               |
/// | Others (SMS, QR, …)    | ❌ Email/password auth only             |
///
/// The OttoHub SDK does **not** support SMS login, QR code login,
/// captcha, RSA key exchange (getWebKey), device listing, safe center,
/// or OAuth2 — those methods always return an error.
class OttoAuthRepository implements AuthRepository {
  final OttohubClient _client;

  OttoAuthRepository(this._client);

  /// Convenience getter for the auth API module.
  IAuthApi get _api => _client.auth;

  // ── LoadingState helpers (for LoadingState-returning methods) ────────

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  // ── Map response helpers (for Map-returning methods) ─────────────────

  Map<String, dynamic> _okMap([Map<String, dynamic>? data]) => <String, dynamic>{
    'status': 'ok',
    'data': ?data,
  };

  Map<String, dynamic> _errMap(ApiException e) => <String, dynamic>{
    'status': 'error',
    'message': e.errorCode,
  };

  // ═════════════════════════════════════════════════════════════════════
  // QR code login — OttoHub API uses email/password, not QR
  // ═════════════════════════════════════════════════════════════════════

  @override
  Future<LoadingState<({String authCode, String url})>> getQRCode() async {
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<Map> pollQRCode(String authCode) async {
    return _errMap(const ApiException('not_implemented'));
  }

  // ═════════════════════════════════════════════════════════════════════
  // Password login  ✅  supported via IAuthApi.login()
  // ═════════════════════════════════════════════════════════════════════

  @override
  Future<Map> loginByPassword(
    String username,
    String password,
    String key,
    String salt, {
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  }) async {
    // The key/salt/geeCaptcha/recaptcha parameters are BiliBili-specific.
    // OttoHub SDK handles password verification internally.
    try {
      final result = await _api.login(username, password);
      _client.token = result.token;

      // Notify account provider so it persists the token and updates
      // reactive auth state (rxIsLogin, rxFace, etc.).
      Get.find<OttoAccountProvider>().updateCredentials(
        uid: result.uid,
        token: result.token,
        uname: result.email,
        face: result.avatarUrl,
      );

      return _okMap(<String, dynamic>{
        'mid': int.tryParse(result.uid),
        'token': result.token,
        'face': result.avatarUrl,
        'uname': result.email ?? '',
      });
    } on ApiException catch (e) {
      debugPrint('OttoAuthRepository.loginByPassword ApiException: ${e.errorCode}');
      return _errMap(e);
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // SMS login — OttoHub SDK uses email-based auth, not SMS
  // ═════════════════════════════════════════════════════════════════════

  @override
  Future<Map> loginBySms(
    String captchaKey,
    String tel,
    String code,
    Object cid,
    String key,
  ) async {
    // OttoHub SDK does not expose an SMS login endpoint.
    // Use loginByPassword with an email-registered account instead.
    return _errMap(const ApiException('not_implemented'));
  }

  // ═════════════════════════════════════════════════════════════════════
  // SMS code — OttoHub SDK sends email verification codes, not SMS
  // ═════════════════════════════════════════════════════════════════════

  @override
  Future<Map> sendSmsCode(
    Object cid,
    String tel, {
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  }) async {
    // The SDK provides sendRegisterVerificationCode(email) and
    // sendPasswordResetVerificationCode(email) for email-based verification.
    // SMS delivery is not supported.
    return _errMap(const ApiException('not_implemented'));
  }

  // ═════════════════════════════════════════════════════════════════════
  // Captcha — OttoHub API does not require captcha for auth
  // ═════════════════════════════════════════════════════════════════════

  @override
  Future<Map> queryCaptcha() async {
    return _errMap(const ApiException('not_implemented'));
  }

  // ═════════════════════════════════════════════════════════════════════
  // Web key (RSA) — OttoHub SDK sends passwords directly
  // ═════════════════════════════════════════════════════════════════════

  @override
  Future<Map> getWebKey() async {
    // OttoHub SDK handles password hashing client-side; no RSA key
    // exchange endpoint is needed or available.
    return _errMap(const ApiException('not_implemented'));
  }

  // ═════════════════════════════════════════════════════════════════════
  // Logout  ✅  clear local token
  // ═════════════════════════════════════════════════════════════════════

  @override
  Future<Map> logout(CoreAccount account) async {
    // OttoHub SDK's IAuthApi has no server-side logout endpoint.
    // Clearing the token locally is sufficient — all subsequent API
    // calls will be unauthenticated.
    _client.token = null;
    Get.find<OttoAccountProvider>().clearCredentials();
    return _okMap();
  }

  // ═════════════════════════════════════════════════════════════════════
  // Login devices — not exposed by OttoHub SDK
  // ═════════════════════════════════════════════════════════════════════

  @override
  Future<LoadingState<CoreLoginDevicesData>> loginDevices() async {
    return _err(const ApiException('not_implemented'));
  }

  // ═════════════════════════════════════════════════════════════════════
  // Safe center — no equivalent concept in OttoHub SDK
  // ═════════════════════════════════════════════════════════════════════

  @override
  Future<Map> safeCenterGetInfo(String tmpCode) async {
    return _errMap(const ApiException('not_implemented'));
  }

  @override
  Future<Map> preCapture() async {
    return _errMap(const ApiException('not_implemented'));
  }

  @override
  Future<Map> safeCenterSmsCode({
    String? smsType,
    required String tmpCode,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
    required String refererUrl,
  }) async {
    return _errMap(const ApiException('not_implemented'));
  }

  @override
  Future<Map> safeCenterSmsVerify({
    String? type,
    required String code,
    required String tmpCode,
    required String requestId,
    required String source,
    required String captchaKey,
    required String refererUrl,
  }) async {
    return _errMap(const ApiException('not_implemented'));
  }

  // ═════════════════════════════════════════════════════════════════════
  // OAuth2 — OttoHub SDK does not use OAuth2
  // ═════════════════════════════════════════════════════════════════════

  @override
  Future<Map> oauth2AccessToken(String code) async {
    return _errMap(const ApiException('not_implemented'));
  }
}
