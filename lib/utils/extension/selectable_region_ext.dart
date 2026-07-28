import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

extension SelectableRegionStateExt on SelectableRegionState {
  void addLaunchMenuIfNeeded(
    List<ContextMenuButtonItem> buttonItems, {
    required int index,
  }) {
    try {
      if (selectionEndpoints.first != selectionEndpoints[1]) {
        buttonItems.insertOrAdd(
          index,
          ContextMenuButtonItem(
            label: '打开',
            onPressed: () {
              final text = (this as dynamic).selectable
                  ?.getSelectedContent()
                  ?.plainText
                  .trim();
              hideToolbar();
              clearSelection();
              if (text != null && text.isNotEmpty) {
                launchUrl(Uri.parse(text));
              }
            },
          ),
        );
      }
    } catch (_) {}
  }
}
