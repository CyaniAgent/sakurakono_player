import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/adapters/bilibili/pages/dynamics/widgets/additional_panel.dart';
import 'package:skf/adapters/bilibili/pages/dynamics/widgets/blocked_item.dart';
import 'package:skf/adapters/bilibili/pages/dynamics/widgets/content_panel.dart';
import 'package:skf/adapters/bilibili/pages/dynamics/widgets/module_panel.dart';
import 'package:flutter/material.dart';

List<Widget> dynContent(
  BuildContext context, {
  required int floor,
  required ThemeData theme,
  required CoreDynamicItemModel item,
  required bool isSave,
  required bool isDetail,
}) {
  final moduleDynamic = item.modules?.moduleDynamic;
  return [
    if (item.type != 'DYNAMIC_TYPE_NONE')
      content(
        context,
        theme: theme,
        isSave: isSave,
        isDetail: isDetail,
        item: item,
        floor: floor,
      ),
    module(
      context,
      theme: theme,
      isSave: isSave,
      isDetail: isDetail,
      item: item,
      floor: floor,
    ),
    if (moduleDynamic?.additional case final additional?)
      ?addWidget(
        theme: theme,
        context,
        idStr: item.idStr,
        additional: additional,
        floor: floor,
      ),
    if (moduleDynamic?.major?.blocked case final blocked?)
      blockedItem(context, theme: theme, blocked: blocked),
  ];
}
