import 'package:skf/core/models/auth_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for authentication operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed. Methods returning bare [Future]<[Map]> correspond to
/// operations whose API responses have not yet been wrapped in [LoadingState].
abstract class AuthRepository {
  /// Get a QR code for scanning login.
  Future<LoadingState<({String authCode, String url})>> getQRCode();

  /// Poll the QR code login status.
  Future<Map> pollQRCode(String authCode);

  /// Login by password.
  Future<Map> loginByPassword(
    String username,
    String password,
    String key,
    String salt, {
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  });

  /// Login by SMS verification code.
  Future<Map> loginBySms(
    String captchaKey,
    String tel,
    String code,
    Object cid,
    String key,
  );

  /// Send an SMS verification code.
  Future<Map> sendSmsCode(
    Object cid,
    String tel, {
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  });

  /// Query captcha data.
  Future<Map> queryCaptcha();

  /// Get RSA key and salt for password login.
  Future<Map> getWebKey();

  /// Log out the given [account].
  Future<Map> logout(CoreAccount account);

  /// Get the list of login devices.
  Future<LoadingState<CoreLoginDevicesData>> loginDevices();

  /// Get safe-center info by temp code.
  Future<Map> safeCenterGetInfo(String tmpCode);

  /// Pre-capture for risk control verification.
  Future<Map> preCapture();

  /// Send an SMS code for safe-center verification.
  Future<Map> safeCenterSmsCode({
    String? smsType,
    required String tmpCode,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
    required String refererUrl,
  });

  /// Verify an SMS code for safe-center verification.
  Future<Map> safeCenterSmsVerify({
    String? type,
    required String code,
    required String tmpCode,
    required String requestId,
    required String source,
    required String captchaKey,
    required String refererUrl,
  });

  /// Exchange an OAuth2 authorization code for an access token.
  Future<Map> oauth2AccessToken(String code);
}
