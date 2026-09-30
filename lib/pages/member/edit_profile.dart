// 编辑资料页(/editProfile,仅本人空间入口)。
//
// OttoHub 可编辑字段:昵称/签名/性别(update_username/update_intro/
// update_sex),保存时全量提交。头像上传无对应 API,不提供。

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/router/app_navigator.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const _sexOptions = <String>['男', '女', '保密'];

  final _nameController = TextEditingController();
  final _signController = TextEditingController();

  String? _sex;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _query();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _signController.dispose();
    super.dispose();
  }

  Future<void> _query() async {
    final mid = appRead(accountProvider).userId;
    if (mid == null) {
      setState(() => _loading = false);
      SmartDialog.showToast('账号未登录');
      return;
    }
    final res = await appRead(
      memberRepositoryProvider,
    ).memberInfo(mid: mid);
    if (!mounted) return;
    setState(() {
      switch (res) {
        case Success(:final response):
          _nameController.text = response.name ?? '';
          _signController.text = response.sign ?? '';
          _sex = response.sex;
        case final Error err:
          SmartDialog.showToast(err.errMsg ?? '加载失败');
        case Loading():
          break;
      }
      _loading = false;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SmartDialog.showToast('昵称不能为空');
      return;
    }
    setState(() => _saving = true);
    final res = await appRead(memberRepositoryProvider).updateProfile(
      username: name,
      intro: _signController.text.trim(),
      sex: _sex,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (res case Success()) {
      SmartDialog.showToast('已保存');
      AppNavigator.back();
    } else {
      res.toast();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          TextButton(
            onPressed: _loading || _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    TextField(
                      controller: _nameController,
                      maxLength: 32,
                      decoration: const InputDecoration(
                        labelText: '昵称',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _signController,
                      maxLength: 200,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '签名',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('性别', style: theme.textTheme.bodyMedium),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SegmentedButton<String>(
                            segments: _sexOptions
                                .map(
                                  (e) =>
                                      ButtonSegment(value: e, label: Text(e)),
                                )
                                .toList(),
                            selected: {_sex ?? '保密'},
                            onSelectionChanged: (selection) =>
                                setState(() => _sex = selection.first),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '仅支持修改昵称、签名与性别;头像等其余资料暂无编辑入口。',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
