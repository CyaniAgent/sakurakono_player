import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/adapters/bilibili/pages/article/widgets/opus_content.dart'
    show moduleBlockedItem;
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:flutter/material.dart';

Widget blockedItem(
  BuildContext context, {
  required ThemeData theme,
  required CoreModuleBlocked blocked,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 1),
    child: moduleBlockedItem(
      context,
      theme,
      ModelConverters.blockedModule(blocked),
    ),
  );
}
