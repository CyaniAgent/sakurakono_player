import 'dart:io' show Platform;

import 'package:skf/common/widgets/animated_height.dart';
import 'package:skf/common/widgets/color_palette.dart';
import 'package:skf/main.dart' show MyApp;
import 'package:skf/adapters/bilibili/models/common/nav_bar_config.dart';
import 'package:skf/adapters/bilibili/models/common/theme/theme_color_type.dart';
import 'package:skf/pages/mine/theme_type.dart';
import 'package:skf/pages/home/view.dart';
import 'package:skf/pages/mine/controller.dart';
import 'package:skf/pages/setting/widgets/popup_item.dart';
import 'package:skf/pages/setting/widgets/select_dialog.dart';
import 'package:skf/utils/extension/get_ext.dart';
import 'package:skf/adapters/bilibili/utils/extension/theme_ext.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/utils/theme_utils.dart';
import 'package:collection/collection.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ColorSelectState {
  const ColorSelectState({
    required this.dynamicColor,
    required this.currentColor,
    required this.themeType,
    required this.schemeVariant,
  });

  final bool dynamicColor;
  final int currentColor;
  final ThemeType themeType;
  final FlexSchemeVariant schemeVariant;

  ColorSelectState copyWith({
    bool? dynamicColor,
    int? currentColor,
    ThemeType? themeType,
    FlexSchemeVariant? schemeVariant,
  }) {
    return ColorSelectState(
      dynamicColor: dynamicColor ?? this.dynamicColor,
      currentColor: currentColor ?? this.currentColor,
      themeType: themeType ?? this.themeType,
      schemeVariant: schemeVariant ?? this.schemeVariant,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ColorSelectNotifier extends StateNotifier<ColorSelectState> {
  ColorSelectNotifier()
    : super(
        ColorSelectState(
          dynamicColor: Pref.dynamicColor,
          currentColor: Pref.customColor,
          themeType: ThemeType.values[Pref.themeType],
          schemeVariant: Pref.schemeVariant,
        ),
      );

  void setDynamicColor(bool value) {
    state = state.copyWith(dynamicColor: value);
  }

  void setCurrentColor(int value) {
    state = state.copyWith(currentColor: value);
  }

  void setThemeType(ThemeType value) {
    state = state.copyWith(themeType: value);
  }

  void setSchemeVariant(FlexSchemeVariant value) {
    state = state.copyWith(schemeVariant: value);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final colorSelectProvider =
    StateNotifierProvider<ColorSelectNotifier, ColorSelectState>(
      (ref) => ColorSelectNotifier(),
    );

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class ColorSelectPage extends ConsumerWidget {
  const ColorSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ctr = ref.watch(colorSelectProvider);
    final notifier = ref.read(colorSelectProvider.notifier);
    TextStyle titleStyle = theme.textTheme.titleMedium!;
    TextStyle subTitleStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.outline,
    );
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.viewPaddingOf(
      context,
    ).copyWith(top: 0, bottom: 0);

    Future<void> onDynamicColorChanged([bool? val]) async {
      val ??= !ctr.dynamicColor;
      if (val && !await MyApp.initPlatformState()) {
        SmartDialog.showToast('设备可能不支持动态取色');
        return;
      }
      notifier.setDynamicColor(val);
      await GStorage.setting.put(SettingBoxKey.dynamicColor, val);
      Get.updateMyAppTheme();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('选择应用主题')),
      body: ListView(
        children: [
          ListTile(
            onTap: () async {
              final result = await showDialog<ThemeType>(
                context: context,
                builder: (context) => SelectDialog<ThemeType>(
                  title: '主题模式',
                  value: ctr.themeType,
                  values: ThemeType.values.map((e) => (e, e.desc)).toList(),
                ),
              );
              if (result != null) {
                try {
                  Get.find<MineController>().themeType.value = result;
                } catch (_) {}
                notifier.setThemeType(result);
                GStorage.setting.put(SettingBoxKey.themeMode, result.index);
                Get.changeThemeMode(ThemeUtils.themeMode = result.toThemeMode);
              }
            },
            leading: const Icon(Icons.flashlight_on_outlined),
            title: Text('主题模式', style: titleStyle),
            subtitle: Text(
              '当前模式：${ctr.themeType.desc}',
              style: subTitleStyle,
            ),
          ),
          PopupListTile<FlexSchemeVariant>(
            enabled: !ctr.dynamicColor,
            leading: const Icon(Icons.palette_outlined),
            title: const Text('调色板风格'),
            value: () =>
                (ctr.schemeVariant, ctr.schemeVariant.variantName),
            itemBuilder: (_) => FlexSchemeVariant.values
                .map(
                  (e) => PopupMenuItem(value: e, child: Text(e.variantName)),
                )
                .toList(),
            onSelected: (value, setState) {
              notifier.setSchemeVariant(value);
              GStorage.setting
                  .put(SettingBoxKey.schemeVariant, value.index)
                  .whenComplete(Get.updateMyAppTheme);
            },
          ),
          if (!Platform.isIOS)
            ListTile(
              title: const Text('动态取色'),
              leading: ExcludeFocus(
                child: Checkbox(
                  value: ctr.dynamicColor,
                  onChanged: onDynamicColorChanged,
                  materialTapTargetSize: .shrinkWrap,
                  visualDensity: const .new(horizontal: -4, vertical: -4),
                ),
              ),
              onTap: onDynamicColorChanged,
            ),
          Padding(
            padding: padding + const .all(12),
            child: AnimatedHeight(
              expand: ctr.dynamicColor,
              duration: const Duration(milliseconds: 200),
              child: Wrap(
                alignment: .center,
                spacing: 22,
                runSpacing: 18,
                children: colorThemeTypes.mapIndexed(
                  (i, e) {
                    return GestureDetector(
                      behavior: .opaque,
                      onTap: () {
                        notifier.setCurrentColor(i);
                        GStorage.setting
                            .put(SettingBoxKey.customColor, i)
                            .whenComplete(Get.updateMyAppTheme);
                      },
                      child: Column(
                        spacing: 3,
                        children: [
                          ColorPalette(
                            colorScheme: e.color.asColorSchemeSeed(
                              ctr.schemeVariant,
                              theme.brightness,
                            ),
                            selected: ctr.currentColor == i,
                          ),
                          Text(
                            e.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: ctr.currentColor != i
                                  ? theme.colorScheme.outline
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: ExcludeFocus(
              child: IgnorePointer(
                child: Container(
                  height: size.height / 2,
                  width: size.width,
                  color: theme.colorScheme.surface,
                  child: const HomePage(),
                ),
              ),
            ),
          ),
          ExcludeFocus(
            child: IgnorePointer(
              child: NavigationBar(
                destinations: NavigationBarType.values
                    .map(
                      (item) => NavigationDestination(
                        icon: item.icon,
                        label: item.label,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}
