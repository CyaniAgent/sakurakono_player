import 'package:skf/core/adapter/adapter_registry.dart';
import 'package:skf/core/adapter/play_input_kind.dart';
import 'package:skf/pages/setting/setting_host.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 弹出「播放链接」输入对话框。
///
/// 结构模仿 export_import.dart 的 importFromInput（AlertDialog +
/// TextFormField autofocus + 取消/确定），但它是 JSON 专用（jsonDecode），
/// 此处不复用：输入经激活适配器的 classifyPlayInput 分类后分派。
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
          onPressed: AppNavigator.back,
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
            AppNavigator.back();
            await _dispatchPlayInput(input);
          },
          child: const Text('确定'),
        ),
      ],
    ),
  );
}

Future<void> _dispatchPlayInput(String input) async {
  // classifyPlayInput 基于 trim 后值判定，分派必须使用同一 trimmed 值：
  // 直接 int.parse(input) 会在粘贴含首尾空白/换行的纯数字时抛 FormatException。
  final trimmed = input.trim();
  switch (AdapterRegistry.active.classifyPlayInput(trimmed)) {
    case PlayInputKind.videoUrl:
      // B站短链等在此走网络 302，因此只出现在异步分派中，不进纯函数。
      // 分派走激活适配器的 openUrl（B站: PiliScheme.routePushFromUrl）。
      final ok = await AdapterRegistry.active.openUrl(trimmed);
      if (!ok) SmartDialog.showToast('无法识别的链接');
    case PlayInputKind.numericId:
      // classifyPlayInput 已保证 trim 后 ^\d+$，int.parse(trimmed) 不会失败。
      // 纯数字 ID 打开视频页由宿主分派（B站: PageUtils.toVideoPage）。
      SettingHost.of().openVideoById(trimmed);
    case PlayInputKind.unknown:
      SmartDialog.showToast('无法识别的链接');
  }
}
