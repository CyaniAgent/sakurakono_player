import 'package:skf/adapters/bilibili/utils/app_scheme.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/adapters/bilibili/utils/play_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

/// 弹出「播放链接」输入对话框。
///
/// 结构模仿 export_import.dart 的 importFromInput（AlertDialog +
/// TextFormField autofocus + 取消/确定），但它是 JSON 专用（jsonDecode），
/// 此处不复用：输入经 [classifyPlayInput] 分类后分派。
void showPlayInputDialog(BuildContext context) {
  final controller = TextEditingController();
  final key = GlobalKey<FormFieldState<String>>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('播放链接'),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              key: key,
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'B站 链接 / BV号 / av号，或 OttoHub 视频 ID',
              ),
            ),
          ),
          IconButton(
            tooltip: '粘贴',
            icon: const Icon(Icons.content_paste),
            onPressed: () async {
              final data = await Clipboard.getData('text/plain');
              if (data?.text case final text? when (text.isNotEmpty)) {
                controller.text = text;
                key.currentState?.validate();
              } else {
                SmartDialog.showToast('剪贴板无数据');
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(
            '取消',
            style: TextStyle(
              color: ColorScheme.of(context).outline,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            final input = controller.text;
            Get.back();
            await _dispatchPlayInput(input);
          },
          child: const Text('确定'),
        ),
      ],
    ),
  );
}

/// 分派播放输入：biliUrl 走 [PiliScheme.routePushFromUrl]（返回 false 时
/// 提示），ottoVid 按 OttoHub identity mapping 直通
/// [PageUtils.toVideoPage]（bvid=数字字符串），unknown 仅提示。
Future<void> _dispatchPlayInput(String input) async {
  // classifyPlayInput 基于 trim 后值判定，分派必须使用同一 trimmed 值：
  // 直接 int.parse(input) 会在粘贴含首尾空白/换行的纯数字时抛 FormatException。
  final trimmed = input.trim();
  switch (classifyPlayInput(trimmed)) {
    case PlayInputKind.biliUrl:
      // b23.tv 等短链在此走网络 302，因此只出现在异步分派中，不进纯函数。
      final ok = await PiliScheme.routePushFromUrl(trimmed);
      if (!ok) SmartDialog.showToast('无法识别的链接');
    case PlayInputKind.ottoVid:
      // classifyPlayInput 已保证 trim 后 ^\d+$，int.parse(trimmed) 不会失败。
      final id = int.parse(trimmed);
      PageUtils.toVideoPage(bvid: trimmed, aid: id, cid: id);
    case PlayInputKind.unknown:
      SmartDialog.showToast('无法识别的链接');
  }
}
