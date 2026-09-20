// OttoHub 发送评论面板。
//
// 经 [PublishRoute] 底部滑入(与发送弹幕面板同款交互):多行输入 +
// 发送按钮,键盘经 chat_bottom_container 附着于面板容器。
// 发送走 replyAdd;成功后携带消息文本返回,由调用方本地插入列表。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/publish/common_text_pub_page.dart';
import 'package:skf/pages/common/publish/publish_route.dart';
import 'package:skf/router/app_navigator.dart';

/// 弹出发送评论面板(底部滑入);成功后返回消息文本。
Future<String?> showOttoReplySheet({
  required int oid,
  int? parent,
  required String hint,
  String? initialValue,
}) async {
  return AppNavigator.push<String>(
    PublishRoute(
      pageBuilder: (buildContext, animation, secondaryAnimation) =>
          OttoReplyPubPage(
        oid: oid,
        parent: parent,
        hint: hint,
        initialValue: initialValue,
      ),
    ),
  );
}

class OttoReplyPubPage extends CommonTextPubPage {
  /// 评论主体 ID(视频 vid)。
  final int oid;

  /// 被回复的评论 ID(null = 发表根评论)。
  final int? parent;
  final String hint;

  const OttoReplyPubPage({
    super.key,
    super.initialValue,
    super.onSave,
    required this.oid,
    required this.hint,
    this.parent,
  });

  @override
  State<OttoReplyPubPage> createState() => _OttoReplyPubPageState();
}

class _OttoReplyPubPageState extends CommonTextPubPageState<OttoReplyPubPage> {
  late ThemeData themeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeData = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return ViewSafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            color: themeData.colorScheme.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputView(),
              buildPanelContainer(themeData, Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: this,
              builder: (context, _) => TextField(
                controller: editController,
                autofocus: false,
                readOnly: readOnly,
                minLines: 1,
                maxLines: 5,
                inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                onChanged: onChanged,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: themeData.colorScheme.outline,
                  ),
                ),
                style: themeData.textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ListenableBuilder(
            listenable: this,
            builder: (context, _) => iconButton(
              tooltip: '发送',
              iconSize: 22,
              iconColor: enablePublish
                  ? themeData.colorScheme.primary
                  : themeData.colorScheme.outline,
              onPressed: enablePublish ? onPublishThrottle : null,
              icon: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> onCustomPublish({List? pictures}) async {
    SmartDialog.showLoading(msg: '发送中...');
    final res = await appRead(replyRepositoryProvider).replyAdd(
      type: 2,
      oid: widget.oid,
      message: editController.text.trim(),
      parent: widget.parent,
    );
    SmartDialog.dismiss();
    if (res case Success()) {
      hasPub = true;
      AppNavigator.back(result: editController.text.trim());
      SmartDialog.showToast('评论成功');
    } else {
      res.toast();
    }
  }
}
