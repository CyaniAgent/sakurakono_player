import 'package:flutter/material.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/app_meta.dart';
import 'package:skf/router/app_navigator.dart';

/// 框架级登录页:调用当前适配器的 AuthRepository.loginByPassword。
/// 适配器决定 key/salt 是否需要(B 站 RSA / OttoHub 直传)。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtr.dispose();
    _passwordCtr.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameCtr.text.trim();
    final password = _passwordCtr.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = '请输入账号和密码');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await (appRead(authRepositoryProvider)).loginByPassword(
        username,
        password,
        '', // key — OttoHub 忽略
        '', // salt — OttoHub 忽略
      );
      if (!mounted) return;
      if (res['status'] == 'ok' || res['code'] == 0) {
        AppNavigator.back();
      } else {
        setState(() => _error = res['message']?.toString() ?? '登录失败');
      }
    } catch (e) {
      if (mounted) setState(() => _error = '登录异常: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('登录 ${AppMeta.appName}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const .symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                TextField(
                  controller: _usernameCtr,
                  decoration: const InputDecoration(
                    labelText: '账号 (UID / 邮箱 / 用户名)',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  autofillHints: const [AutofillHints.username],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtr,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _login(),
                ),
                if (_error != null)
                  Padding(
                    padding: const .only(top: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('登录'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
