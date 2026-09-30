// 私信聊天面板(框架级,无 Scaffold)。
//
// 消息气泡列表(我方右/对方左)+ 底部输入行。数据经
// ImRepository(syncFetchSessionMsgs / sendMsg)。被两处复用:
// /whisperDetail 整页(适配器包 Scaffold+AppBar,showHeader: false)
// 与消息页宽屏右栏(showHeader: true,自带对话标题行)。

import 'package:flutter/material.dart';

import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';

class WhisperChatPanel extends StatefulWidget {
  const WhisperChatPanel({
    super.key,
    required this.uid,
    this.name,
    this.face,
    this.showHeader = false,
  });

  final int uid;
  final String? name;
  final String? face;

  /// 宽屏右栏内嵌时显示头像+名称标题行(整页形态由 AppBar 承担)。
  final bool showHeader;

  @override
  State<WhisperChatPanel> createState() => _WhisperChatPanelState();
}

class _WhisperChatPanelState extends State<WhisperChatPanel> {
  final _messages = <CoreImMsg>[];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _loading = true;
  bool _sending = false;

  /// 首载失败(区别于「无消息」空态,可重试)。
  String? _error;
  final int _myUid = appRead(accountProvider).userId ?? 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await appRead(imRepositoryProvider).syncFetchSessionMsgs(
      talkerId: widget.uid,
    );
    if (!mounted) return;
    setState(() {
      if (res case Success(:final response)) {
        _messages
          ..clear()
          ..addAll(response.messages);
        _error = null;
      } else if (_messages.isEmpty) {
        _error = switch (res) {
          final Error e => e.errMsg ?? '加载失败',
          _ => '加载失败',
        };
      }
      _loading = false;
    });
    _scrollToBottom();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    _sending = true;
    final res = await appRead(imRepositoryProvider).sendMsg(
      senderUid: _myUid,
      receiverId: widget.uid,
      content: text,
    );
    _sending = false;
    if (!mounted) return;
    if (res case Success()) {
      setState(() {
        _messages.add(
          CoreImMsg(
            msgType: 1,
            content: text,
            senderUid: _myUid,
            timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          ),
        );
        _inputController.clear();
      });
      _scrollToBottom();
    } else {
      res.toast();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (widget.showHeader)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(50),
                ),
              ),
            ),
            child: Row(
              children: [
                NetworkImgLayer(
                  src: widget.face,
                  width: 40,
                  height: 40,
                  type: .avatar,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.name ?? '私信',
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _messages.isEmpty
              ? HttpError(isSliver: false, errMsg: _error, onReload: _load)
              : _messages.isEmpty
              ? const Center(child: Text('还没有消息,发一条私信吧'))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final mine = msg.senderUid == _myUid;
                    return _bubble(context, msg, mine);
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: '输入私信内容',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubble(BuildContext context, CoreImMsg msg, bool mine) {
    final theme = Theme.of(context);
    return Align(
      alignment: mine ? .centerRight : .centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const .symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.widthOf(context) * 0.7),
        decoration: BoxDecoration(
          color: mine
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(mine ? 12 : 2),
            bottomRight: Radius.circular(mine ? 2 : 12),
          ),
        ),
        child: Text(msg.content, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
