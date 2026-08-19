import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/selection_text.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:skf/utils/extension/selectable_region_ext.dart';

/// Lightweight emoji data decoupled from adapter models.
class _EmojiData {
  final String? url;
  final num size;
  const _EmojiData({this.url, required this.size});
}

Widget dynTextMenuBuilder(
  SelectableRegionState state,
  String text,
  /* ModuleDynamicModel? */ dynamic moduleDynamic,
) {
  final buttonItems = state.contextMenuButtonItems
    ..insertOrAdd(
      3,
      ContextMenuButtonItem(
        label: '文本',
        onPressed: () {
          state.hideToolbar();
          _showTextDialog(text);
        },
      ),
    )
    ..insertOrAdd(
      4,
      ContextMenuButtonItem(
        label: '表情',
        onPressed: () {
          state
            ..hideToolbar()
            ..clearSelection();
          _showEmoteDialog(moduleDynamic);
        },
      ),
    );
  return AdaptiveTextSelectionToolbar.buttonItems(
    buttonItems: buttonItems,
    anchors: state.contextMenuAnchors,
  );
}

void _showEmoteDialog(/* ModuleDynamicModel? */ dynamic moduleDynamic) {
  if (moduleDynamic == null) return;
  final dynamic desc = moduleDynamic.desc;
  final dynamic major = moduleDynamic.major;
  final List? richTextNodes = desc?.richTextNodes ??
      major?.opus?.summary?.richTextNodes;
  if (richTextNodes == null || richTextNodes.isEmpty) return;
  Map<String, _EmojiData>? emotes;
  for (final e in richTextNodes) {
    if (e.type == 'RICH_TEXT_NODE_TYPE_EMOJI') {
      emotes ??= <String, _EmojiData>{};
      if (!emotes.containsKey(e.origText)) {
        emotes[e.origText] = _EmojiData(
          url: e.emoji?.url,
          size: e.emoji?.size ?? 1,
        );
      }
    }
  }
  if (emotes == null || emotes.isEmpty) return;
  SelectedContent? lastSelection;
  showDialog(
    context: AppNavigator.context!,
    builder: (context) => Dialog(
      child: Padding(
        padding: const .symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: SelectionText.rich(
            TextSpan(
              children: emotes!.entries.mapIndexed(
                (i, e) {
                  final emoji = e.value;
                  final size = emoji.size * 25.0;
                  return TextSpan(
                    children: [
                      if (i != 0) const TextSpan(text: '\n\n'),
                      WidgetSpan(
                        child: NetworkImgLayer(
                          src: emoji.url,
                          type: .emote,
                          width: size,
                          height: size,
                        ),
                      ),
                      TextSpan(text: '\n${e.key}\n${emoji.url}'),
                    ],
                  );
                },
              ).toList(),
            ),
            contextMenuBuilder: (context, state) =>
                openUrlMenuBuilder(state, lastSelection),
            onSelectionChanged: (c) => lastSelection = c,
            style: const TextStyle(fontSize: 15, height: 1.7),
          ),
        ),
      ),
    ),
  );
}

void _showTextDialog(String text) {
  SelectedContent? lastSelection;
  showDialog(
    context: AppNavigator.context!,
    builder: (context) => Dialog(
      child: Padding(
        padding: const .symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: SelectionText(
            text,
            contextMenuBuilder: (context, state) =>
                openUrlMenuBuilder(state, lastSelection),
            onSelectionChanged: (c) => lastSelection = c,
            style: const TextStyle(fontSize: 15, height: 1.7),
          ),
        ),
      ),
    ),
  );
}

Widget openUrlMenuBuilder(SelectableRegionState state, SelectedContent? selectedContent) {
  final buttonItems = state.contextMenuButtonItems;
  state.addLaunchMenuIfNeeded(buttonItems, index: 3, selectedContent: selectedContent);
  return AdaptiveTextSelectionToolbar.buttonItems(
    buttonItems: buttonItems,
    anchors: state.contextMenuAnchors,
  );
}
