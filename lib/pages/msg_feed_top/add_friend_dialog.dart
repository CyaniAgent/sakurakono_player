// 添加好友弹窗(框架级):输入 UID 查找用户,确认后跳转私信会话。
//
// OttoHub 无独立「加好友」动作,发一条私信即建立会话(piliotto 同款语义)。

import 'package:flutter/material.dart';

import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/router/app_navigator.dart';

class AddFriendDialog extends StatefulWidget {
  const AddFriendDialog({super.key});

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final _uidController = TextEditingController();
  String? _avatar;
  String? _name;
  int? _uid;
  bool _searching = false;
  String? _error;

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  Future<void> _findUser() async {
    final uid = int.tryParse(_uidController.text.trim());
    if (uid == null) {
      setState(() => _error = 'UID 格式不正确,请输入数字');
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
      _uid = null;
      _name = null;
      _avatar = null;
    });
    final res = await appRead(memberRepositoryProvider).memberInfo(mid: uid);
    if (!mounted) return;
    setState(() {
      _searching = false;
      if (res case Success(:final response)) {
        _uid = response.mid ?? uid;
        _name = response.name;
        _avatar = response.face;
      } else {
        _error = '用户不存在';
      }
    });
  }

  void _openChat() {
    final uid = _uid;
    if (uid == null) return;
    AppNavigator.back();
    AppNavigator.toNamed(
      '/whisperDetail?uid=$uid'
      '&name=${Uri.encodeComponent(_name ?? '')}'
      '&face=${Uri.encodeComponent(_avatar ?? '')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('添加好友'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: .min,
          children: [
            TextField(
              controller: _uidController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '输入用户 UID',
                prefixIcon: const Icon(Icons.person),
                suffixIcon: _searching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: _findUser,
                        icon: const Icon(Icons.search),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (_) => _findUser(),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            if (_uid != null) ...<Widget>[
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      NetworkImgLayer(
                        src: _avatar,
                        width: 48,
                        height: 48,
                        type: .avatar,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              _name ?? '未知用户',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'UID: $_uid',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        const TextButton(
          onPressed: AppNavigator.back,
          child: Text('取消'),
        ),
        if (_uid != null)
          FilledButton(
            onPressed: _openChat,
            child: const Text('发送消息'),
          ),
      ],
    );
  }
}
