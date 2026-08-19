import 'dart:io' show File;

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart' hide showTimePicker;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/time_picker.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_create_vote/controller.dart';
import 'package:skf/utils/date_utils.dart';
import 'package:skf/utils/extension/file_ext.dart';
import 'package:skf/utils/platform_utils.dart';

class CreateVotePage extends ConsumerStatefulWidget {
  const CreateVotePage({super.key, this.voteId});

  final int? voteId;

  @override
  ConsumerState<CreateVotePage> createState() => _CreateVotePageState();
}

class _CreateVotePageState extends ConsumerState<CreateVotePage> {
  late final imagePicker = ImagePicker();

  late TextStyle _leadingStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _leadingStyle = TextStyle(
      fontSize: 15,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
    );
    final state = ref.watch(createVoteProvider(widget.voteId));
    final notifier = ref.read(createVoteProvider(widget.voteId).notifier);
    final padding = MediaQuery.viewPaddingOf(context);
    final divider = Divider(
      height: 20,
      thickness: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.voteId != null ? '' : '发起'}投票'),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: padding.left + 16,
          right: padding.right + 16,
          bottom: padding.bottom + 100,
        ),
        children: [
          const Text(
            '投票类型',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildType(theme, state, notifier),
          const SizedBox(height: 40),
          _buildInput(
            theme,
            key: ValueKey('${state.key}title'),
            initialValue: state.title,
            onChanged: notifier.updateTitle,
            desc: '投票标题',
            hintText: '请填写标题',
            inputFormatters: [LengthLimitingTextInputFormatter(32)],
          ),
          divider,
          _buildInput(
            theme,
            key: ValueKey('${state.key}desc'),
            initialValue: state.desc,
            onChanged: notifier.updateDesc,
            desc: '投票说明',
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
          ),
          divider,
          const SizedBox(height: 40),
          _buildOptions(theme, state, notifier, divider),
          const SizedBox(height: 40),
          Row(
            spacing: 12,
            children: [
              SizedBox(
                width: 100,
                child: Text('单选/多选', style: _leadingStyle),
              ),
              _buildChoiceCnt(state, notifier),
            ],
          ),
          const SizedBox(height: 4),
          divider,
          Row(
            spacing: 12,
            children: [
              SizedBox(
                width: 100,
                child: Text('投票截止时间', style: _leadingStyle),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: state.endtime,
                    firstDate: notifier.now,
                    lastDate: notifier.end,
                  );
                  if (newDate != null && context.mounted) {
                    TimeOfDay? newTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        state.endtime,
                      ),
                    );
                    if (newTime != null) {
                      final newEndtime = DateTime(
                        newDate.year,
                        newDate.month,
                        newDate.day,
                        newTime.hour,
                        newTime.minute,
                      );
                      if (newEndtime.difference(DateTime.now()) >=
                          const Duration(minutes: 5)) {
                        notifier.updateEndtime(newEndtime);
                      } else {
                        SmartDialog.showToast('至少选择5分钟之后');
                      }
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormatUtils.longFormatD.format(
                      state.endtime,
                    ),
                  ),
                ),
              ),
            ],
          ),
          divider,
          const SizedBox(height: 40),
          FilledButton.tonal(
            onPressed: state.canCreate
                ? () async {
                    final result = await notifier.onCreate();
                    if (result != null && context.mounted) {
                      Navigator.of(context).pop(result);
                    }
                  }
                : null,
            child: const Text('发起投票'),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    ThemeData theme, {
    Key? key,
    String? initialValue,
    required ValueChanged<String> onChanged,
    required String desc,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
    bool showDel = false,
    bool showImg = false,
    String? imgUrl,
    VoidCallback? onDel,
    VoidCallback? onPickImg,
  }) {
    return Row(
      spacing: 12,
      children: [
        SizedBox(
          width: 65,
          child: Text(
            desc,
            style: _leadingStyle,
          ),
        ),
        Expanded(
          child: TextFormField(
            key: key,
            initialValue: initialValue,
            onChanged: onChanged,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: hintText ?? desc,
              hintStyle: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.outline.withValues(alpha: 0.7),
              ),
            ),
            inputFormatters: inputFormatters,
          ),
        ),
        if (showImg)
          GestureDetector(
            onTap: onPickImg,
            child: NetworkImgLayer(
              src: imgUrl,
              width: 40,
              height: 40,
              borderRadius: const BorderRadius.all(
                Radius.circular(6),
              ),
            ),
          ),
        if (showDel)
          iconButton(
            size: 26,
            iconSize: 18,
            tooltip: '移除',
            icon: const Icon(Icons.clear),
            onPressed: onDel,
            iconColor: theme.colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }

  Widget _buildType(
    ThemeData theme,
    CreateVoteState state,
    CreateVoteNotifier notifier,
  ) {
    return Row(
      spacing: 16,
      children: List.generate(
        2,
        (index) {
          final isEnable = index == state.type;
          final style = TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isEnable
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            backgroundColor: isEnable
                ? theme.colorScheme.secondaryContainer
                : Colors.transparent,
            foregroundColor: isEnable
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
          );
          Widget child = TextButton(
            style: style,
            onPressed: () => notifier.updateType(index),
            child: Text(
              '${const ['文字', '图片'][index]}投票',
              style: const TextStyle(fontSize: 14, height: 1),
              strutStyle: const StrutStyle(
                height: 1,
                leading: 0,
                fontSize: 14,
              ),
            ),
          );
          if (isEnable) {
            child = Stack(
              clipBehavior: Clip.none,
              children: [
                child,
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomRight: Radius.circular(6),
                      ),
                      color: theme.colorScheme.primary,
                    ),
                    child: Icon(
                      size: 10,
                      Icons.check,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          }
          return child;
        },
      ),
    );
  }

  Widget _buildOptions(
    ThemeData theme,
    CreateVoteState state,
    CreateVoteNotifier notifier,
    Widget divider,
  ) {
    final showImg = state.type == 1;
    final showDel = state.options.length > 2;
    List<Widget> children = [];
    for (int i = 0; i < state.options.length; i++) {
      final e = state.options[i];
      children
        ..add(
          _buildInput(
            theme,
            key: ObjectKey(e),
            showDel: showDel,
            onDel: () {
              FocusManager.instance.primaryFocus?.unfocus();
              notifier.onDel(i);
            },
            showImg: showImg,
            imgUrl: e.imgUrl,
            onPickImg: () => EasyThrottle.throttle(
              'picImg',
              const Duration(milliseconds: 500),
              () => _onPickImg(notifier, i),
            ),
            initialValue: e.optDesc,
            onChanged: (value) => notifier.updateOptionDesc(i, value),
            desc: '选项${i + 1}',
            hintText: '选项内容，最多20字',
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
          ),
        )
        ..add(divider);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...children,
        if (state.options.length < 20)
          FilledButton(
            onPressed: () => notifier.addOption(),
            style: FilledButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.only(
                left: 10,
                right: 14,
                top: 4,
                bottom: 4,
              ),
              visualDensity: .standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              backgroundColor: theme.colorScheme.onInverseSurface,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16),
                Text(
                  ' 添加选项',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildChoiceCnt(CreateVoteState state, CreateVoteNotifier notifier) {
    final choiceCnt = state.choiceCnt;
    final choices = List.generate(
      state.options.length,
      (i) => i + 1,
    );
    return Listener(
      onPointerDown: (_) =>
          FocusManager.instance.primaryFocus?.unfocus(),
      child: PopupMenuButton<int>(
        initialValue: choiceCnt,
        requestFocus: false,
        onSelected: notifier.updateChoiceCnt,
        itemBuilder: (context) {
          return choices
              .map(
                (e) => PopupMenuItem(
                  value: e,
                  child: Text(e == 1 ? '单选' : '最多选$e项'),
                ),
              )
              .toList();
        },
        child: Text(
          choiceCnt == 1 ? '单选         ' : '最多选$choiceCnt项',
        ),
      ),
    );
  }

  void _onPickImg(CreateVoteNotifier notifier, int index) {
    EasyThrottle.throttle(
      'imagePicker',
      const Duration(milliseconds: 500),
      () async {
        try {
          final pickedFile = await imagePicker.pickImage(
            imageQuality: 100,
            source: ImageSource.gallery,
            requestFullMetadata: false,
          );
          if (pickedFile != null) {
            final path = pickedFile.path;
            notifier.onUpload(index, path).whenComplete(() {
              if (PlatformUtils.isMobile) {
                File(path).tryDel();
              }
            });
          }
        } catch (e) {
          SmartDialog.showToast(e.toString());
        }
      },
    );
  }
}
