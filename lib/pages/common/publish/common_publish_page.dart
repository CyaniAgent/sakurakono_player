import 'dart:async';
import 'dart:io';
import 'dart:math' show max;

import 'package:skf/pages/common/publish/publish_panel_type.dart';
import 'package:skf/utils/extension/context_ext.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:chat_bottom_container/chat_bottom_container.dart';
import 'package:flutter/material.dart';

abstract class CommonPublishPage<T> extends StatefulWidget {
  const CommonPublishPage({
    super.key,
    this.initialValue,
    this.imageLengthLimit,
    this.onSave,
    this.autofocus = true,
  });

  final String? initialValue;
  final int? imageLengthLimit;
  final ValueChanged<T>? onSave;
  final bool autofocus;
}

abstract class CommonPublishPageState<T extends CommonPublishPage>
    extends State<T>
    with WidgetsBindingObserver
    implements Listenable {
  late bool _paused = false;
  final FocusNode focusNode = FocusNode();
  late final controller = ChatBottomPanelContainerController<PanelType>(
    uiScale: Pref.uiScale,
  );
  TextEditingController get editController;

  final _listeners = <VoidCallback>{};

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @protected
  void notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  PanelType _panelType = PanelType.none;
  PanelType get panelType => _panelType;
  set panelType(PanelType value) {
    if (_panelType != value) {
      _panelType = value;
      notifyListeners();
    }
  }

  bool _readOnly = false;
  bool get readOnly => _readOnly;
  set readOnly(bool value) {
    if (_readOnly != value) {
      _readOnly = value;
      notifyListeners();
    }
  }

  bool _enablePublish = false;
  bool get enablePublish => _enablePublish;
  set enablePublish(bool value) {
    if (_enablePublish != value) {
      _enablePublish = value;
      notifyListeners();
    }
  }

  bool isPublishing = false;

  bool hasPub = false;
  void initPubState();

  bool get handleKeyboard => Platform.isAndroid && widget.autofocus;

  @override
  void initState() {
    super.initState();
    if (handleKeyboard) {
      WidgetsBinding.instance.addObserver(this);
    }

    initPubState();

    if (widget.autofocus) {
      _requestFocus(duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    if (!hasPub) {
      onSave();
    }
    focusNode.dispose();
    editController.dispose();
    if (handleKeyboard) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  void _safeRequestFocus() {
    if (mounted) {
      focusNode.requestFocus();
    }
  }

  void _requestFocus({Duration duration = const Duration(microseconds: 200)}) {
    Future.delayed(duration, _safeRequestFocus);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .resumed) {
      if (_paused) {
        _paused = false;
        final panelType = this.panelType;
        if (panelType == .keyboard || panelType == .none) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (focusNode.hasFocus) {
              focusNode.unfocus();
              _requestFocus();
            } else {
              _requestFocus();
            }
          });
        }
      }
    } else if (state == .paused) {
      _paused = true;
      if (focusNode.hasFocus) {
        focusNode.unfocus();
      }
    }
  }

  void updatePanelType(PanelType type) {
    final isSwitchToKeyboard = PanelType.keyboard == type;
    bool isUpdated = false;
    switch (type) {
      case PanelType.keyboard:
        updateInputView(isReadOnly: false);
        break;
      case PanelType.emoji || PanelType.more:
        isUpdated = updateInputView(isReadOnly: true);
        break;
      default:
        break;
    }

    void updatePanelTypeFunc() {
      controller.updatePanelType(
        isSwitchToKeyboard
            ? ChatBottomPanelType.keyboard
            : ChatBottomPanelType.other,
        data: type,
        forceHandleFocus: isSwitchToKeyboard
            ? ChatBottomHandleFocus.requestFocus
            : ChatBottomHandleFocus.unfocus,
      );
    }

    if (isUpdated) {
      // Waiting for the input view to update.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        updatePanelTypeFunc();
      });
    } else {
      updatePanelTypeFunc();
    }
  }

  Future<void> hidePanel([_]) async {
    if (focusNode.hasFocus) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      focusNode.unfocus();
    }
    updateInputView(isReadOnly: false);
    if (ChatBottomPanelType.none == controller.currentPanelType) return;
    controller.updatePanelType(ChatBottomPanelType.none);
  }

  bool updateInputView({
    required bool isReadOnly,
  }) {
    if (readOnly != isReadOnly) {
      readOnly = isReadOnly;
      return true;
    }
    return false;
  }

  Widget buildEmojiPickerPanel() {
    double height = context.isTablet ? 300 : 170;
    final keyboardHeight = controller.keyboardHeight;
    if (keyboardHeight != 0) {
      height = max(height, keyboardHeight);
    }
    return SizedBox(
      height: height,
      child: customPanel,
    );
  }

  Widget buildMorePanel(ThemeData theme) => throw UnimplementedError();

  Widget buildPanelContainer(ThemeData theme, [Color? panelBgColor]) {
    return ChatBottomPanelContainer<PanelType>(
      controller: controller,
      inputFocusNode: focusNode,
      otherPanelWidget: (type) {
        if (type == null) return const SizedBox.shrink();
        switch (type) {
          case PanelType.emoji:
            return buildEmojiPickerPanel();
          case PanelType.more:
            return buildMorePanel(theme);
          default:
            return const SizedBox.shrink();
        }
      },
      onPanelTypeChange: (panelType, data) {
        switch (panelType) {
          case ChatBottomPanelType.none:
            this.panelType = PanelType.none;
            break;
          case ChatBottomPanelType.keyboard:
            this.panelType = PanelType.keyboard;
            break;
          case ChatBottomPanelType.other:
            if (data == null) return;
            this.panelType = data;
            break;
        }
      },
      panelBgColor: panelBgColor ?? Theme.of(context).colorScheme.surface,
    );
  }

  void onSubmitted(String value) {
    if (enablePublish) onPublishThrottle();
  }

  void onPublishThrottle() {
    if (isPublishing) return;
    isPublishing = true;
    onPublish().whenComplete(() => isPublishing = false);
  }

  Future<void> onPublish();

  Future<void> onCustomPublish({List? pictures});

  Widget? get customPanel => null;

  void onChanged(String value) {
    enablePublish = value.trim().isNotEmpty;
  }

  void onSave();
}
