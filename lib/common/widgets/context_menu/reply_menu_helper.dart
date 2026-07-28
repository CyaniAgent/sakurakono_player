import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/selection_text.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:skf/utils/extension/selectable_region_ext.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';

/// Simple data class for emote display, decoupled from protobuf types.
class EmoteData {
  final String url;
  final double size;

  const EmoteData({required this.url, required this.size});
}

void showReplyCopyDialog(
  BuildContext context,
  String message,
  Map<String, EmoteData> emotes, {
  bool enableFilter = false,
  RegExp? replyRegExp,
  ValueChanged<String>? onAddFilter,
}) {
  bool showEmote = false;
  final effectiveRegExp = replyRegExp ?? RegExp('');
  showDialog(
    context: context,
    builder: (context) => Dialog(
      constraints: const BoxConstraints.tightFor(width: 380),
      child: Padding(
        padding: const .symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: SelectionText.rich(
            showEmote
                ? TextSpan(
                    children: emotes.entries.mapIndexed(
                      (i, e) {
                        final emote = e.value;
                        final size = emote.size * 25.0;
                        return TextSpan(
                          children: [
                            if (i != 0) const TextSpan(text: '\n\n'),
                            WidgetSpan(
                              child: NetworkImgLayer(
                                src: emote.url,
                                type: .emote,
                                width: size,
                                height: size,
                              ),
                            ),
                            TextSpan(text: '\n${e.key}\n${emote.url}'),
                          ],
                        );
                      },
                    ).toList(),
                  )
                : TextSpan(text: message),
            contextMenuBuilder: (_, state) {
              final buttonItems = state.contextMenuButtonItems;
              if (emotes.isNotEmpty) {
                buttonItems.insertOrAdd(
                  3,
                  ContextMenuButtonItem(
                    label: showEmote ? '文本' : '表情',
                    onPressed: () {
                      state
                        ..hideToolbar()
                        ..clearSelection();
                      showEmote = !showEmote;
                      (context as Element).markNeedsBuild();
                    },
                  ),
                );
                if (showEmote) {
                  state.addLaunchMenuIfNeeded(buttonItems, index: 4);
                }
              }
              try {
                if (state.selectionEndpoints.first !=
                    state.selectionEndpoints[1]) {
                  buttonItems.add(
                    ContextMenuButtonItem(
                      onPressed: () {
                        final selectedText = (state as dynamic).selectable
                            ?.getSelectedContent()
                            ?.plainText;
                        String text = RegExp.escape(selectedText);
                        if (enableFilter) text = '|$text';

                        showConfirmDialog(
                          context: context,
                          title: const Text('是否确认评论过滤的变更：'),
                          content: Text.rich(
                            TextSpan(
                              text: effectiveRegExp.pattern,
                              children: [
                                TextSpan(
                                  text: text,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onConfirm: () {
                            final filter = effectiveRegExp.pattern + text;
                            GStorage.setting.put(
                              SettingBoxKey.banWordForReply,
                              filter,
                            );
                            onAddFilter?.call(filter);
                            SmartDialog.showToast('已保存');
                          },
                        );
                      },
                      label: '加入过滤',
                    ),
                  );
                }
              } catch (_) {}
              return AdaptiveTextSelectionToolbar.buttonItems(
                buttonItems: buttonItems,
                anchors: state.contextMenuAnchors,
              );
            },
            style: const TextStyle(fontSize: 15, height: 1.7),
          ),
        ),
      ),
    ),
  );
}
