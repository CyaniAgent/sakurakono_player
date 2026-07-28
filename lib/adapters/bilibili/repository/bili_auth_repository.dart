
import 'package:skf/adapters/bilibili/http/login.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/core/models/auth_types.dart';
import 'package:skf/core/repository/auth_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// {@template bili_auth_repository}
/// Implementation of [AuthRepository] that delegates to [LoginHttp].
/// {@endtemplate}
class BiliAuthRepository implements AuthRepository {
  @override
  Future<LoadingState<({String authCode, String url})>> getQRCode() {
    return LoginHttp.getHDcode();
  }

  @override
  Future<Map> pollQRCode(String authCode) {
    return LoginHttp.codePoll(authCode) as Future<Map>;
  }

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
  }) {
    return LoginHttp.loginByPwd(
      username: username,
      password: password,
      key: key,
      salt: salt,
      geeChallenge: geeChallenge,
      geeSeccode: geeSeccode,
      geeValidate: geeValidate,
      recaptchaToken: recaptchaToken,
    ) as Future<Map>;
  }

  @override
  Future<Map> loginBySms(
    String captchaKey,
    String tel,
    String code,
    Object cid,
    String key,
  ) {
    return LoginHttp.loginBySms(
      captchaKey: captchaKey,
      tel: tel,
      code: code,
      cid: cid,
      key: key,
    ) as Future<Map>;
  }

  @override
  Future<Map> sendSmsCode(
    Object cid,
    String tel, {
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  }) {
    return LoginHttp.sendSmsCode(
      cid: cid,
      tel: tel,
      geeChallenge: geeChallenge,
      geeSeccode: geeSeccode,
      geeValidate: geeValidate,
      recaptchaToken: recaptchaToken,
    ) as Future<Map>;
  }

  @override
  Future<Map> queryCaptcha() {
    return LoginHttp.queryCaptcha() as Future<Map>;
  }

  @override
  Future<Map> getWebKey() {
    return LoginHttp.getWebKey() as Future<Map>;
  }

  @override
  Future<Map> logout(CoreAccount account) {
    return LoginHttp.logout(Accounts.main);
  }

  @override
  Future<LoadingState<CoreLoginDevicesData>> loginDevices() async {
    final result = await LoginHttp.loginDevices();
    return switch (result) {
      Success(:final response) => Success(CoreLoginDevicesData(
        devices: response.devices
            ?.map((d) => CoreLoginDevice(
                  deviceName: d.deviceName,
                  isCurrentDevice: d.isCurrentDevice,
                  latestLoginAt: d.latestLoginAt,
                  source: d.source,
                ))
            .toList(),
      )),
      Error(:final errMsg) => Error(errMsg),
      Loading() => LoadingState.loading(),
    };
  }

  @override
  Future<Map> safeCenterGetInfo(String tmpCode) {
    return LoginHttp.safeCenterGetInfo(tmpCode: tmpCode) as Future<Map>;
  }

  @override
  Future<Map> preCapture() {
    return LoginHttp.preCapture() as Future<Map>;
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
  }) {
    return LoginHttp.safeCenterSmsCode(
      smsType: smsType,
      tmpCode: tmpCode,
      geeChallenge: geeChallenge,
      geeSeccode: geeSeccode,
      geeValidate: geeValidate,
      recaptchaToken: recaptchaToken,
      refererUrl: refererUrl,
    ) as Future<Map>;
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
  }) {
    return LoginHttp.safeCenterSmsVerify(
      type: type,
      code: code,
      tmpCode: tmpCode,
      requestId: requestId,
      source: source,
      captchaKey: captchaKey,
      refererUrl: refererUrl,
    ) as Future<Map>;
  }

  @override
  Future<Map> oauth2AccessToken(String code) {
    return LoginHttp.oauth2AccessToken(code: code) as Future<Map>;
  }
}