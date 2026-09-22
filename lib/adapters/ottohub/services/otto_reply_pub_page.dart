// OttoHub 发送评论面板。
//
// 复原原 ReplyPage(bb7d917 快照)版式:经 [PublishRoute] 底部滑入,
// 多行输入(4-8 行,无字数限制)+ 按钮排(表情/@/图片/插入)+ 发送按钮,
// 键盘经 chat_bottom_container 附着于面板容器,宽度 640。
// OttoHub 评论 API 仅支持纯文本:表情/图片/@ 面板无对应服务端能力,
// 点击给出提示;草稿经 [onSave] 持久化、[initialValue] 回填。

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/publish/common_text_pub_page.dart';
import 'package:skf/pages/common/publish/publish_route.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/feed_back.dart';

/// 弹出发送评论面板(底部滑入);成功后返回消息文本。
Future<String?> showOttoReplySheet({
  required int oid,
  int? parent,
  required String hint,
  String? initialValue,
  void Function(String)? onSave,
}) async {
  return AppNavigator.push<String>(
    PublishRoute(
      pageBuilder: (buildContext, animation, secondaryAnimation) =>
          OttoReplyPubPage(
        oid: oid,
        parent: parent,
        hint: hint,
        initialValue: initialValue,
        onSave: onSave,
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
          constraints: const BoxConstraints(maxWidth: 640),
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
      padding: const EdgeInsets.only(top: 12, left: 15, right: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListenableBuilder(
            listenable: this,
            builder: (context, _) => TextField(
              controller: editController,
              autofocus: false,
              readOnly: readOnly,
              minLines: 4,
              maxLines: 8,
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
          Divider(height: 1, color: themeData.colorScheme.outline
              .withValues(alpha: 0.1)),
          Container(
            height: 52,
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                iconBtn(
                  tooltip: '表情',
                  icon: Icons.emoji_emotions_outlined,
                  onTap: () => SmartDialog.showToast('暂不支持评论表情'),
                ),
                iconBtn(
                  tooltip: '@',
                  icon: Icons.alternate_email,
                  onTap: () => SmartDialog.showToast('暂不支持@用户'),
                ),
                iconBtn(
                  tooltip: '图片',
                  icon: Icons.image_outlined,
                  onTap: () => SmartDialog.showToast('暂不支持评论图片'),
                ),
                const Spacer(),
                ListenableBuilder(
                  listenable: this,
                  builder: (context, _) => FilledButton.tonal(
                    onPressed: enablePublish ? onPublishThrottle : null,
                    style: FilledButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('发送'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget iconBtn({
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 22,
        color: themeData.colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Future<void> onCustomPublish({List? pictures}) async {
    feedBack();
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
