import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/dynamics/dynamics_host.dart';
import 'package:flutter/material.dart';

Widget blockedItem(
  BuildContext context, {
  required ThemeData theme,
  required CoreModuleBlocked blocked,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 1),
    child: DynamicsHost.of().buildBlockedItem(context, theme, blocked),
  );
}
