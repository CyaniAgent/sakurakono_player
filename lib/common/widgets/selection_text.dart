import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SelectionText extends StatelessWidget {
  const SelectionText(
    String this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    this.onSelectionChanged,
  }) : textSpan = null;

  const SelectionText.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.textAlign,
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    this.onSelectionChanged,
  }) : data = null;

  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final TextAlign? textAlign;
  final SelectableRegionContextMenuBuilder? contextMenuBuilder;
  final ValueChanged<SelectedContent?>? onSelectionChanged;

  static Widget _defaultContextMenuBuilder(
    BuildContext context,
    SelectableRegionState selectableRegionState,
  ) {
    return AdaptiveTextSelectionToolbar.selectableRegion(
      selectableRegionState: selectableRegionState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      onSelectionChanged: onSelectionChanged,
      contextMenuBuilder: contextMenuBuilder,
      child: Text.rich(
        style: style,
        textAlign: textAlign,
        TextSpan(
          text: data,
          children: textSpan != null ? <InlineSpan>[textSpan!] : null,
        ),
      ),
    );
  }
}
