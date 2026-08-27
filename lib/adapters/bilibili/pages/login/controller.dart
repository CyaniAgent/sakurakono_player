import 'dart:async';
import 'dart:io';

import 'package:skf/common/dial_prefix.dart';
import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/radio_widget.dart';
import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/adapters/bilibili/http/login.dart';
import 'package:skf/adapters/bilibili/models/common/account_type.dart';
import 'package:skf/adapters/bilibili/models/login/model.dart'; // ignore: adapter import (no core equivalent)
import 'package:skf/adapters/bilibili/pages/login/geetest/geetest_webview_dialog.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/accounts/account.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/theme_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable state for the login page.
class LoginState {
  LoginState({
    LoadingState<({String authCode, String url})>? codeInfo,
    int? qrCodeLeftTime,
    String? statusQRCode,
    this.selectedCountryCodeId,
    String? captchaKey,
    int? smsSendCooldown,
    int? currentTabIndex,
  })  : codeInfo = codeInfo ?? LoadingState<({String authCode, String url})>.loading(),
        qrCodeLeftTime = qrCodeLeftTime ?? 180,
        statusQRCode = statusQRCode ?? '',
        captchaKey = captchaKey ?? '',
        smsSendCooldown = smsSendCooldown ?? 0,
        currentTabIndex = currentTabIndex ?? 0;

  final LoadingState<({String authCode, String url})> codeInfo;
  final int qrCodeLeftTime;
  final String statusQRCode;
  final ({int id, String cname, int countryId})? selectedCountryCodeId;
  final String captchaKey;
  final int smsSendCooldown;
  final int currentTabIndex;

  ({int id, String cname, int countryId}) get effectiveCountryCode =>
      selectedCountryCodeId ?? Login.dialPrefix.first;

  LoginState copyWith({
    LoadingState<({String authCode, String url})>? codeInfo,
    int? qrCodeLeftTime,
    String? statusQRCode,
    ({int id, String cname, int countryId})? selectedCountryCodeId,
    String? captchaKey,
    int? smsSendCooldown,
    int? currentTabIndex,
  }) {
    return LoginState(
      codeInfo: codeInfo ?? this.codeInfo,
      qrCodeLeftTime: qrCodeLeftTime ?? this.qrCodeLeftTime,
      statusQRCode: statusQRCode ?? this.statusQRCode,
      selectedCountryCodeId:
          selectedCountryCodeId ?? this.selectedCountryCodeId,
      captchaKey: captchaKey ?? this.captchaKey,
      smsSendCooldown: smsSendCooldown ?? this.smsSendCooldown,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}

/// Notifier managing login page business logic and non-reactive resources.
class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(LoginState());

  // TextEditingControllers — owned by the notifier, disposed in dispose().
  final TextEditingController telTextController = TextEditingController();
  final TextEditingController usernameTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController smsCodeTextController = TextEditingController();
  final TextEditingController cookieTextController = TextEditingController();

  late final CaptchaDataModel captchaData = CaptchaDataModel();

  // Non-reactive fields
  int smsSendTimestamp = 0;
  bool _isReq = false;

  Timer? qrCodeTimer;
  Timer? smsSendCooldownTimer;

  @override
  void dispose() {
    qrCodeTimer?.cancel();
    smsSendCooldownTimer?.cancel();
    telTextController.dispose();
    usernameTextController.dispose();
    passwordTextController.dispose();
    smsCodeTextController.dispose();
    cookieTextController.dispose();
    super.dispose();
  }

  void updateTabIndex(int index) {
    state = state.copyWith(currentTabIndex: index);
  }

  void setSelectedCountryCodeId(
    ({int id, String cname, int countryId}) value,
  ) {
    state = state.copyWith(selectedCountryCodeId: value);
  }

  bool get shouldAutoRefreshQRCode =>
      qrCodeTimer == null || !qrCodeTimer!.isActive;

  Future<void> refreshQRCode(BuildContext context) async {
    final res = await LoginHttp.getHDcode();
    if (res case Success(:final response)) {
      qrCodeTimer?.cancel();
      state = state.copyWith(codeInfo: res);
      qrCodeTimer = Timer.periodic(const Duration(milliseconds: 1000), (t) {
        final left = 180 - t.tick;
        if (left <= 0) {
          t.cancel();
          state = state.copyWith(
            statusQRCode: '二维码已过期，请刷新',
            qrCodeLeftTime: 0,
          );
          return;
        }
        state = state.copyWith(qrCodeLeftTime: left);
        if (_isReq || state.currentTabIndex != 2) return;

        _isReq = true;
        LoginHttp.codePoll(response.authCode).then((value) async {
          _isReq = false;
          if (value['status']) {
            t.cancel();
            state = state.copyWith(statusQRCode: '扫码成功');
            await setAccount(
              value['data'],
              value['data']['cookie_info']['cookies'],
              context,
            );
            if (context.mounted) Navigator.of(context).pop();
          } else if (value['code'] == 86038) {
            t.cancel();
            state = state.copyWith(qrCodeLeftTime: 0);
          } else {
            state = state.copyWith(statusQRCode: value['msg']);
          }
        });
      });
    }
  }

  // 申请极验验证码
  void getCaptcha(
    String geeGt,
    String geeChallenge,
    VoidCallback onSuccess,
  ) {
    GeetestWebviewDialog.geetest(geeGt, geeChallenge).then((res) {
      if (res is Map) {
        captchaData
          ..validate = res['geetest_validate']
          ..seccode = res['geetest_seccode']
          ..geetest = GeetestData(
            challenge: res['geetest_challenge'],
            gt: geeGt,
          );
        SmartDialog.showToast('验证成功');
        onSuccess();
      }
    });
  }

  static String validateCookie(String cookie) {
    return cookie
        .split(';')
        .where((e) {
          try {
            Cookie.fromSetCookieValue(e.trim());
          } catch (_) {
            return false;
          }
          return true;
        })
        .join(';');
  }

  // cookie登录
  Future<void> loginByCookie(BuildContext context) async {
    if (cookieTextController.text.isEmpty) {
      SmartDialog.showToast('cookie不能为空');
      return;
    }
    try {
      final result = await Request().get(
        "/x/member/web/account",
        options: Options(
          headers: {
            "cookie": validateCookie(cookieTextController.text),
          },
          extra: {'account': AnonymousAccount()},
        ),
      );
      if (result.data['code'] == 0) {
        try {
          await LoginAccount(
            BiliCookieJar.fromJson(
              Map.fromEntries(
                cookieTextController.text.split(';').map((item) {
                  final list = item.split('=');
                  return MapEntry(list.first, list.skip(1).join());
                }),
              ),
            ),
            null,
            null,
          ).onChange();
          if (!Accounts.main.isLogin) {
            await switchAccountDialog(context);
          }
          SmartDialog.showToast('登录成功');
          if (context.mounted) Navigator.of(context).pop();
        } catch (e) {
          SmartDialog.showToast("登录失败: $e");
        }
      } else {
        SmartDialog.showToast("哔哩哔哩登录已失效，请重新登录");
      }
    } catch (e) {
      SmartDialog.showToast("获取哔哩哔哩用户信息失败，可前往账号管理重试");
    }
  }

  // app端密码登录
  Future<void> loginByPassword(BuildContext context) async {
    String username = usernameTextController.text;
    String password = passwordTextController.text;
    if (username.isEmpty || password.isEmpty) {
      SmartDialog.showToast('用户名或密码不能为空');
      return;
    }
    final webKeyRes = await LoginHttp.getWebKey();
    if (!webKeyRes['status']) {
      SmartDialog.showToast(webKeyRes['msg']);
      return;
    }
    String salt = webKeyRes['data']['hash'];
    String key = webKeyRes['data']['key'];
    final res = await LoginHttp.loginByPwd(
      username: username,
      password: password,
      key: key,
      salt: salt,
      geeValidate: captchaData.validate,
      geeSeccode: captchaData.seccode,
      geeChallenge: captchaData.geetest?.challenge,
      recaptchaToken: captchaData.token,
    );
    if (res['status']) {
      final data = res['data'];
      if (data == null) {
        SmartDialog.showToast('登录异常，接口未返回数据：${res["msg"]}');
        return;
      }
      if (data['status'] == 2) {
        SmartDialog.showToast(data['message']);
        String url = data['url']!;
        Uri currentUri = Uri.parse(url);
        final safeCenterRes = await LoginHttp.safeCenterGetInfo(
          tmpCode: currentUri.queryParameters['tmp_token']!,
        );
        if (!safeCenterRes['status']) {
          SmartDialog.showToast(
            "获取安全验证信息失败，请尝试其它登录方式\n"
            "(${safeCenterRes['code']}) ${safeCenterRes['msg']}",
          );
          return;
        }
        Map<String, String> accountInfo = {
          "hindTel": safeCenterRes['data']['account_info']!["hide_tel"],
          "hindMail": safeCenterRes['data']['account_info']!["hide_mail"],
        };
        if (!safeCenterRes['data']['account_info']!['tel_verify']) {
          SmartDialog.showToast("当前账号未支持手机号验证，请尝试其它登录方式");
          return;
        }

        TextEditingController textFieldController = TextEditingController();
        String captchaKey = '';
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            titlePadding: const EdgeInsets.only(
              left: 16,
              top: 18,
              right: 16,
              bottom: 12,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            title: const Text(
              "本次登录需要验证您的手机号",
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  accountInfo['hindTel'] ?? '未能获取手机号',
                  style: const TextStyle(fontSize: 18),
                ),
                TextField(
                  style: const TextStyle(fontSize: 15),
                  controller: textFieldController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "请输入短信验证码",
                    hintStyle: const TextStyle(fontSize: 15),
                    suffixIcon: iconButton(
                      icon: const Icon(Icons.clear),
                      size: 32,
                      onPressed: textFieldController.clear,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      maxHeight: 32,
                      maxWidth: 32,
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("发送验证码"),
                onPressed: () async {
                  final preCaptureRes = await LoginHttp.preCapture();
                  if (!preCaptureRes['status'] ||
                      preCaptureRes['data'] == null) {
                    SmartDialog.showToast(
                      "获取验证码失败，请尝试其它登录方式\n"
                      "(${preCaptureRes['code']}) ${preCaptureRes['msg']} ${preCaptureRes['data']}",
                    );
                  }
                  String geeGt = preCaptureRes['data']['gee_gt'];
                  String geeChallenge = preCaptureRes['data']['gee_challenge'];
                  captchaData.token =
                      preCaptureRes['data']['recaptcha_token'];
                  if (!isGeeArgumentValid(geeGt, geeChallenge)) {
                    SmartDialog.showToast(
                      "获取极验参数为空，请尝试其它登录方式\n"
                      "(${preCaptureRes['code']}) ${preCaptureRes['msg']} ${preCaptureRes['data']}",
                    );
                    return;
                  }

                  getCaptcha(
                    geeGt,
                    geeChallenge,
                    () async {
                      final safeCenterSendSmsCodeRes =
                          await LoginHttp.safeCenterSmsCode(
                            tmpCode:
                                currentUri.queryParameters['tmp_token']!,
                            geeChallenge: geeChallenge,
                            geeSeccode: captchaData.seccode,
                            geeValidate: captchaData.validate,
                            recaptchaToken: captchaData.token,
                            refererUrl: url,
                          );
                      if (!safeCenterSendSmsCodeRes['status']) {
                        SmartDialog.showToast(
                          "发送短信验证码失败，请尝试其它登录方式\n"
                          "(${safeCenterSendSmsCodeRes['code']}) ${safeCenterSendSmsCodeRes['msg']}",
                        );
                        return;
                      }
                      SmartDialog.showToast("短信验证码已发送，请查收");
                      captchaKey =
                          safeCenterSendSmsCodeRes['data']['captcha_key'];
                    },
                  );
                },
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  "取消",
                  style: TextStyle(
                    color: ThemeUtils.theme.colorScheme.outline,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  String? code = textFieldController.text;
                  if (code.isEmpty) {
                    SmartDialog.showToast("请输入短信验证码");
                    return;
                  }
                  final safeCenterSmsVerifyRes =
                      await LoginHttp.safeCenterSmsVerify(
                        code: code,
                        tmpCode:
                            currentUri.queryParameters['tmp_token']!,
                        requestId:
                            currentUri.queryParameters['request_id']!,
                        source: currentUri.queryParameters['source']!,
                        captchaKey: captchaKey,
                        refererUrl: url,
                      );
                  if (!safeCenterSmsVerifyRes['status']) {
                    SmartDialog.showToast(
                      "验证短信验证码失败，请尝试其它登录方式\n"
                      "(${safeCenterSmsVerifyRes['code']}) ${safeCenterSmsVerifyRes['msg']}",
                    );
                    return;
                  }
                  SmartDialog.showToast("验证成功，正在登录");
                  final oauth2AccessTokenRes =
                      await LoginHttp.oauth2AccessToken(
                        code: safeCenterSmsVerifyRes['data']['code'],
                      );
                  if (!oauth2AccessTokenRes['status']) {
                    SmartDialog.showToast(
                      "登录失败，请尝试其它登录方式\n"
                      "(${oauth2AccessTokenRes['code']}) ${oauth2AccessTokenRes['msg']}",
                    );
                    return;
                  }
                  final data = oauth2AccessTokenRes['data'];
                  if (data['token_info'] == null ||
                      data['cookie_info'] == null) {
                    SmartDialog.showToast(
                      '登录异常，接口未返回身份信息，可能是因为账号风控，请尝试其它登录方式。\n'
                      '${oauth2AccessTokenRes["msg"]}，\n $data',
                    );
                    return;
                  }
                  SmartDialog.showToast('正在保存身份信息');
                  await setAccount(
                    data['token_info'],
                    data['cookie_info']['cookies'],
                    context,
                  );
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text("确认"),
              ),
            ],
          ),
        ).whenComplete(textFieldController.dispose);

        return;
      }
      if (data['token_info'] == null || data['cookie_info'] == null) {
        SmartDialog.showToast(
          '登录异常，接口未返回身份信息，可能是因为账号风控，请尝试其它登录方式。\n'
          '${res["msg"]}，\n $data',
        );
        return;
      }
      SmartDialog.showToast('正在保存身份信息');
      await setAccount(
        data['token_info'],
        data['cookie_info']['cookies'],
        context,
      );
      if (context.mounted) Navigator.of(context).pop();
    } else {
      // handle login result
      switch (res['code']) {
        case 0:
          // login success
          break;
        case -105:
          String captureUrl = res['data']['url'];
          Uri captureUri = Uri.parse(captureUrl);
          captchaData.token =
              captureUri.queryParameters['recaptcha_token']!;
          String geeGt = captureUri.queryParameters['gee_gt']!;
          String geeChallenge =
              captureUri.queryParameters['gee_challenge']!;

          getCaptcha(geeGt, geeChallenge, () => loginByPassword(context));
          break;
        default:
          SmartDialog.showToast(res['msg']);
          // login failed
          break;
      }
    }
  }

  // 短信验证码登录
  Future<void> loginBySmsCode(BuildContext context) async {
    if (telTextController.text.isEmpty) {
      SmartDialog.showToast('手机号不能为空');
      return;
    }
    if (state.captchaKey.isEmpty) {
      SmartDialog.showToast('请先点击获取验证码');
      return;
    }
    if (smsCodeTextController.text.isEmpty) {
      SmartDialog.showToast('验证码不能为空');
      return;
    }
    if (DateTime.now().millisecondsSinceEpoch - smsSendTimestamp >
        1000 * 60 * 5) {
      SmartDialog.showToast('验证码已过期，请重新获取');
      return;
    }
    final webKeyRes = await LoginHttp.getWebKey();
    if (!webKeyRes['status']) {
      SmartDialog.showToast(webKeyRes['msg']);
      return;
    }
    String key = webKeyRes['data']['key'];
    final res = await LoginHttp.loginBySms(
      tel: telTextController.text,
      code: smsCodeTextController.text,
      captchaKey: state.captchaKey,
      cid: state.effectiveCountryCode.countryId,
      key: key,
    );
    if (res['status']) {
      SmartDialog.showToast('登录成功');
      final data = res['data'];
      await setAccount(
        data['token_info'],
        data['cookie_info']['cookies'],
        context,
      );
      if (context.mounted) Navigator.of(context).pop();
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  // app端验证码
  Future<void> sendSmsCode() async {
    if (telTextController.text.isEmpty) {
      SmartDialog.showToast('手机号不能为空');
      return;
    }

    final res = await LoginHttp.sendSmsCode(
      tel: telTextController.text,
      cid: state.effectiveCountryCode.countryId,
      geeValidate: captchaData.validate,
      geeSeccode: captchaData.seccode,
      geeChallenge: captchaData.geetest?.challenge,
      recaptchaToken: captchaData.token,
    );
    if (res['status']) {
      SmartDialog.showToast('发送成功');
      smsSendTimestamp = DateTime.now().millisecondsSinceEpoch;
      state = state.copyWith(smsSendCooldown: 60);
      final newCaptchaKey = res['data']['captcha_key'];
      state = state.copyWith(captchaKey: newCaptchaKey);
      smsSendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) {
        state = state.copyWith(smsSendCooldown: 60 - timer.tick);
        if (state.smsSendCooldown <= 0) {
          smsSendCooldownTimer?.cancel();
          state = state.copyWith(smsSendCooldown: 0);
        }
      });
    } else {
      // handle login result
      switch (res['code']) {
        case 0:
        case -105:
          String? captureUrl = res['data']?['recaptcha_url'];
          String? geeGt;
          String? geeChallenge;
          if (captureUrl != null && captureUrl.isNotEmpty) {
            Uri captureUri = Uri.parse(captureUrl);
            captchaData.token =
                captureUri.queryParameters['recaptcha_token'];
            geeGt = captureUri.queryParameters['gee_gt'];
            geeChallenge = captureUri.queryParameters['gee_challenge'];
          }

          if (!isGeeArgumentValid(geeGt, geeChallenge)) {
            if (kDebugMode) {
              debugPrint(
                '验证信息错误：${res["msg"]}\n返回内容：${res["data"]}，尝试另一个验证码接口',
              );
            }
            final preCaptureRes = await LoginHttp.preCapture();
            if (!preCaptureRes['status'] || preCaptureRes['data'] == null) {
              SmartDialog.showToast(
                "获取验证码失败，请尝试其它登录方式\n"
                "(${preCaptureRes['code']}) ${preCaptureRes['msg']} ${preCaptureRes['data']}",
              );
              return;
            }
            geeGt = preCaptureRes['data']['gee_gt'];
            geeChallenge = preCaptureRes['data']['gee_challenge'];
            captchaData.token =
                preCaptureRes['data']['recaptcha_token'];
          }

          if (!isGeeArgumentValid(geeGt, geeChallenge)) {
            SmartDialog.showToast("获取验证码失败，请尝试其它登录方式\n");
            return;
          }

          getCaptcha(geeGt!, geeChallenge!, sendSmsCode);
          break;
        default:
          SmartDialog.showToast(res['msg']);
          break;
      }
    }
  }

  bool isGeeArgumentValid(String? geeGt, String? geeChallenge) {
    return geeGt?.isNotEmpty == true &&
        geeChallenge?.isNotEmpty == true &&
        captchaData.token?.isNotEmpty == true;
  }

  Future<void> setAccount(
    Map tokenInfo,
    List cookieInfo,
    BuildContext context,
  ) async {
    final account = LoginAccount(
      BiliCookieJar.fromList(cookieInfo),
      tokenInfo['access_token'],
      tokenInfo['refresh_token'],
    );
    await Future.wait([account.onChange(), AnonymousAccount().delete()]);
    for (int i = 0; i < AccountType.values.length; i++) {
      if (Accounts.accountMode[i].mid == account.mid) {
        Accounts.accountMode[i] = account;
      }
    }
    if (Accounts.main.isLogin) {
      SmartDialog.showToast('登录成功');
    } else {
      SmartDialog.showToast('登录成功, 请先设置账号模式');
      if (context.mounted) await switchAccountDialog(context);
    }
  }

  static Future<void>? switchAccountDialog(BuildContext context) {
    if (Accounts.account.isEmpty) {
      SmartDialog.showToast('请先登录');
      Navigator.of(context).pushNamed('/loginPage');
      return null;
    }
    final colorScheme = ColorScheme.of(context);
    final selectAccount = List.of(Accounts.accountMode);
    final options = {
      AnonymousAccount(): '0',
      ...Accounts.account.toMap().map(
        (k, v) => MapEntry(v as Account, k as String),
      ),
    };
    bool quickSelect = selectAccount.every((e) => e == selectAccount.first);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          crossAxisAlignment: .start,
          mainAxisAlignment: .spaceBetween,
          children: [
            Text.rich(
              style: const TextStyle(height: 1.5),
              TextSpan(
                children: [
                  const TextSpan(text: '账号切换'),
                  TextSpan(
                    text: '\nmid为0时使用匿名',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                visualDensity: .compact,
                tapTargetSize: .shrinkWrap,
              ),
              onPressed: () {
                quickSelect = !quickSelect;
                (context as Element).markNeedsBuild();
              },
              child: Text(quickSelect ? '详细' : '快速'),
            ),
          ],
        ),
        titlePadding: const .only(left: 22, top: 16, right: 22, bottom: 3),
        contentPadding: const .symmetric(vertical: 5),
        actionsPadding: const .only(left: 16, right: 16, bottom: 10),
        content: SingleChildScrollView(
          child: AnimatedSize(
            curve: Curves.easeIn,
            alignment: .topCenter,
            duration: const Duration(milliseconds: 200),
            child: quickSelect
                ? Builder(
                    builder: (context) => RadioGroup<Account>(
                      groupValue: selectAccount[0],
                      onChanged: (v) {
                        selectAccount.fillRange(
                          0,
                          selectAccount.length,
                          v,
                        );
                        (context as Element).markNeedsBuild();
                      },
                      child: Column(
                        crossAxisAlignment: .start,
                        children: options.entries
                            .map(
                              (entry) => RadioWidget<Account>(
                                value: entry.key,
                                title: entry.value,
                                mainAxisSize: .max,
                                padding: PlatformUtils.isDesktop
                                    ? const .only(left: 12)
                                    : const .only(
                                        left: 12,
                                        top: 2,
                                        bottom: 2,
                                      ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: .start,
                    children: AccountType.values
                        .map(
                          (e) => Builder(
                            builder: (context) => RadioGroup<Account>(
                              groupValue: selectAccount[e.index],
                              onChanged: (v) {
                                selectAccount[e.index] = v!;
                                (context as Element).markNeedsBuild();
                              },
                              child: WrapRadioOptionsGroup<Account>(
                                groupTitle: e.title,
                                options: options,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: TextStyle(color: colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              for (final type in AccountType.values) {
                final index = type.index;
                final account = quickSelect
                    ? selectAccount.first
                    : selectAccount[index];
                if (account != Accounts.accountMode[index]) {
                  Accounts.set(type, account);
                }
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginState>((ref) {
      return LoginNotifier();
    });
