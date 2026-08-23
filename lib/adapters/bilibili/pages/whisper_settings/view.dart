import 'package:skf/common/widgets/dialog/simple_dialog_option.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/common/widgets/loading_widget/loading_widget.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/app/im/v1.pb.dart'
    show IMSettingType, Setting;
import 'package:skf/core/models/im_types.dart' show CoreImSettingType;
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/pages/whisper_block/view.dart';
import 'package:skf/adapters/bilibili/pages/whisper_settings/controller.dart';
import 'package:skf/adapters/bilibili/pages/whisper_settings/widgets/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:protobuf/protobuf.dart' show PbMap;

class WhisperSettingsPage extends StatefulWidget {
  const WhisperSettingsPage({
    super.key,
    this.imSettingType,
    this.onUpdate,
  });

  /// gRPC setting type for direct construction. When null, the page
  /// resolves a [CoreImSettingType] from route arguments (['type']).
  final IMSettingType? imSettingType;
  final ValueChanged<Map<int, Setting>>? onUpdate;

  @override
  State<WhisperSettingsPage> createState() => _WhisperSettingsPageState();
}

class _WhisperSettingsPageState extends State<WhisperSettingsPage> {
  late final WhisperSettingsController _controller;
  @override
  void initState() {
    super.initState();
    final type =
        widget.imSettingType ?? _feedSettingTypeFromArgs(AppNavigator.arguments);
    _controller = Get.put(
      WhisperSettingsController(imSettingType: type),
      tag: type.name,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: ListenableBuilder(listenable: _controller, builder: (_, __) => Text(_controller.title)),
      ),
      body: ListenableBuilder(listenable: _controller, builder: (_, __) => _buildBody(theme, _controller.loadingState)),
    );
  }

  Future<bool> onSet(
    int key,
    PbMap<int, Setting> response,
    Setting item,
  ) async {
    final settings = {key: item};
    final res = await _controller.onSet(settings);
    if (res) {
      widget.onUpdate?.call(settings);
    }
    return res;
  }

  void onRedirect(
    ThemeData theme,
    int key,
    PbMap<int, Setting> response,
    Setting item,
  ) {
    if (item.redirect.settingPage.hasParentSettingType()) {
      AppNavigator.to(
        WhisperSettingsPage(
          imSettingType: item.redirect.settingPage.parentSettingType,
          onUpdate: (value) {
            _controller.loadingState
              .data[key]?.redirect.settingPage.subSettings.addAll(value);
            _controller.loadingState = _controller.loadingState;
          },
        ),
        preventDuplicates: false,
      );
    } else if (item.redirect.hasWindowSelect()) {
      String? selected;
      showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          clipBehavior: Clip.hardEdge,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          children: item.redirect.windowSelect.item.map(
            (e) {
              if (e.selected) {
                selected ??= e.text;
              }
              return DialogOption(
                onPressed: () async {
                  if (!e.selected) {
                    AppNavigator.back();
                    for (final j in item.redirect.windowSelect.item) {
                      j.selected = false;
                    }
                    item.redirect.selectedSummary = e.text;
                    e.selected = true;
                    _controller.loadingState = _controller.loadingState;
                    final settings = {key: item};
                    final res = await _controller.onSet(settings);
                    if (!res) {
                      for (final j in item.redirect.windowSelect.item) {
                        j.selected = j.text == selected;
                      }
                      item.redirect.selectedSummary = selected!;
                      _controller.loadingState = _controller.loadingState;
                    }
                  }
                },
                child: Text(
                  e.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: e.selected ? theme.colorScheme.primary : null,
                  ),
                ),
              );
            },
          ).toList(),
        ),
      );
    } else if (item.redirect.otherPage.hasUrl()) {
      if (item.redirect.title == '黑名单') {
        AppNavigator.toNamed('/blackListPage');
      } else if (item.redirect.otherPage.url.startsWith('http')) {
        AppNavigator.toNamed(
          '/webview',
          parameters: {'url': item.redirect.otherPage.url},
        );
      } else {
        SmartDialog.showToast(item.redirect.otherPage.url);
      }
    } else if (item.redirect.settingPage.hasUrl()) {
      if (item.redirect.title == '消息屏蔽词') {
        AppNavigator.to(const WhisperBlockPage());
      } else if (item.redirect.settingPage.url.startsWith('http')) {
        AppNavigator.toNamed(
          '/webview',
          parameters: {'url': item.redirect.settingPage.url},
        );
      } else {
        SmartDialog.showToast(item.redirect.settingPage.url);
      }
    }
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<PbMap<int, Setting>> loadingState,
  ) {
    late final divider = Divider(
      height: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
    return switch (loadingState) {
      Loading() => const SizedBox.shrink(),
      Success<PbMap<int, Setting>>(:final response) => Builder(
        builder: (context) {
          final keys = response.keys.toList()..sort();
          return ListView.separated(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final item = response[key]!;
              return ImSettingsItem(
                item: item,
                onSet: () => onSet(key, response, item),
                onRedirect: () => onRedirect(theme, key, response, item),
              );
            },
            separatorBuilder: (context, index) => divider,
          );
        },
      ),
      Error(:final errMsg) => scrollErrorWidget(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }
}

/// Maps a core feed setting type (route argument) to the legacy gRPC enum
/// values used by the message-feed settings pages (OLD_* variants).
IMSettingType _feedSettingTypeFromArgs(dynamic args) {
  if (args is! Map) return IMSettingType.SETTING_TYPE_NEED_ALL;
  return switch (args['type']) {
    CoreImSettingType.replyMe => IMSettingType.SETTING_TYPE_OLD_REPLY_ME,
    CoreImSettingType.atMe => IMSettingType.SETTING_TYPE_OLD_AT_ME,
    CoreImSettingType.receiveLike =>
        IMSettingType.SETTING_TYPE_OLD_RECEIVE_LIKE,
    _ => IMSettingType.SETTING_TYPE_NEED_ALL,
  };
}
