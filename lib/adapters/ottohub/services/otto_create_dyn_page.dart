// 发表动态页(/createDyn 动态页「发布动态」按钮入口)。
//
// OttoHub 博客即动态:标题 + markdown 正文(submitBlog)。图片经
// submitImage 上传后以 `![](url)` 内联插入正文光标处。支持草稿持久化。

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';

import 'package:skf/common/widgets/markdown_text.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/storage_pref.dart';

class CreateDynPage extends StatefulWidget {
  const CreateDynPage({super.key});

  @override
  State<CreateDynPage> createState() => _CreateDynPageState();
}

class _CreateDynPageState extends State<CreateDynPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // 草稿回填(上次未发送的内容)。
    _contentController.text = Pref.blogDraft;
  }

  @override
  void dispose() {
    Pref.blogDraft = _contentController.text;
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    SmartDialog.showLoading(msg: '上传图片中...');
    final res = await appRead(
      userRepositoryProvider,
    ).uploadImage(File(picked.path));
    SmartDialog.dismiss();
    if (!mounted) return;
    if (res case Success(:final response)) {
      final url = response;
      final pos = _contentController.selection.baseOffset;
      final insert = '![]($url)';
      final text = _contentController.text;
      final at = pos >= 0 && pos <= text.length ? pos : text.length;
      setState(() {
        _contentController.text =
            '${text.substring(0, at)}$insert${text.substring(at)}';
        _contentController.selection = TextSelection.collapsed(
          offset: at + insert.length,
        );
      });
    } else {
      res.toast();
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      SmartDialog.showToast('标题与内容不能为空');
      return;
    }
    setState(() => _submitting = true);
    SmartDialog.showLoading(msg: '发布中...');
    final res = await appRead(
      userRepositoryProvider,
    ).publishBlog(title: title, content: content);
    SmartDialog.dismiss();
    if (!mounted) return;
    setState(() => _submitting = false);
    if (res case Success()) {
      Pref.blogDraft = '';
      SmartDialog.showToast('发布成功');
      AppNavigator.back(result: true);
    } else {
      res.toast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('发布动态'),
          actions: [
            IconButton(
              tooltip: '插入图片',
              onPressed: _submitting ? null : _pickImage,
              icon: const Icon(Icons.image_outlined),
            ),
            TextButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('发布'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            TextField(
              controller: _titleController,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: '标题',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 14,
              minLines: 8,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: '正文(支持 Markdown:图片/粗体/标题/列表)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => Dialog(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 560,
                        maxHeight: 480,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: MarkdownText(_contentController.text),
                      ),
                    ),
                  ),
                ),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('预览'),
              ),
            ),
            Text(
              '提示:正文支持 Markdown;「插入图片」会先上传到图床再以 ![](url) '
              '形式插入光标处。',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
