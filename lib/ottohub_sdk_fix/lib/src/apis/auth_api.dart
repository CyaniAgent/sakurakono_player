import '../base_api.dart';
import '../models/auth/login_response.dart';

/// 认证模块接口。
///
/// 提供用户登录、注册、验证码发送、密码重置、每日签到功能。
abstract class IAuthApi {
  /// 用户登录。
  ///
  /// [uidEmail]: 用户名或邮箱。
  /// [password]: 密码。
  /// **返回**: [LoginResponse] 包含 uid、token、用户信息。
  /// **抛出**: [ApiException] — `missing_argument`, `error_password`。
  Future<LoginResponse> login(String uidEmail, String password);

  /// 用户注册。
  ///
  /// [email]: 邮箱。
  /// [verificationCode]: 注册验证码。
  /// [password]: 密码。
  /// [confirmPassword]: 确认密码。
  /// **抛出**: [ApiException] — `missing_argument`, `mismatch_pw`, `error_pw`,
  ///   `email_exist`, `error_verification_code`, `system_error`。
  Future<void> register({
    required String email,
    required String verificationCode,
    required String password,
    required String confirmPassword,
  });

  /// 发送注册验证码到指定邮箱。
  ///
  /// **抛出**: [ApiException] — `missing_argument`, `email_exist`, `error_email`。
  Future<void> sendRegisterVerificationCode(String email);

  /// 发送密码重置验证码到指定邮箱。
  ///
  /// **抛出**: [ApiException] — `missing_argument`, `email_unexist`, `system_error`。
  Future<void> sendPasswordResetVerificationCode(String email);

  /// 重置密码。
  ///
  /// [email]: 邮箱。
  /// [verificationCode]: 重置验证码。
  /// [password]: 新密码。
  /// [confirmPassword]: 确认密码。
  /// **抛出**: [ApiException] — `missing_argument`, `mismatch_pw`, `error_pw`,
  ///   `email_unexist`, `error_verification_code`, `system_error`。
  Future<void> resetPassword({
    required String email,
    required String verificationCode,
    required String password,
    required String confirmPassword,
  });

  /// 每日签到。
  ///
  /// **返回**: 签到时返回的 `if_today_first_login` 值。
  /// **抛出**: [ApiException] — `missing_argument`, `error_token`, `system_error`。
  Future<String> signIn();
}

class AuthApi extends BaseApi implements IAuthApi {
  AuthApi(super.dio, super.getToken, {super.config});

  @override
  Future<LoginResponse> login(String uidEmail, String password) async {
    final data = await post('/auth/login', data: {
      'uid_email': uidEmail,
      'pw': password,
    });
    return LoginResponse.fromJson(data);
  }

  @override
  Future<void> register({
    required String email,
    required String verificationCode,
    required String password,
    required String confirmPassword,
  }) async {
    await post('/auth/register', data: {
      'email': email,
      'register_verification_code': verificationCode,
      'pw': password,
      'confirm_pw': confirmPassword,
    });
  }

  @override
  Future<void> sendRegisterVerificationCode(String email) async {
    await post('/auth/register/verification-code', data: {
      'email': email,
    });
  }

  @override
  Future<void> sendPasswordResetVerificationCode(String email) async {
    await post('/auth/password-reset/verification-code', data: {
      'email': email,
    });
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String verificationCode,
    required String password,
    required String confirmPassword,
  }) async {
    await post('/auth/password-reset', data: {
      'email': email,
      'passwordreset_verification_code': verificationCode,
      'pw': password,
      'confirm_pw': confirmPassword,
    });
  }

  @override
  Future<String> signIn() async {
    final data = await post('/auth/sign-in', auth: true);
    return data['if_today_first_login'] as String;
  }
}
