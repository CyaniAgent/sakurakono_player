import 'dart:math' show max;
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/core/container/app_container.dart';

import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/button/toolbar_icon_button.dart';
import 'package:skf/common/widgets/custom_icon.dart';
import 'package:skf/common/widgets/flutter/draggable_scrollable_sheet.dart';
import 'package:skf/common/widgets/flutter/text_field/controller.dart';
import 'package:skf/common/widgets/flutter/text_field/text_field.dart';
import 'package:skf/core/utils/pair.dart';
import 'package:skf/common/widgets/time_picker.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models/common/publish_panel_type.dart';
import 'package:skf/adapters/bilibili/models/common/reply/reply_option_type.dart';
import 'package:skf/core/models/dynamics_types.dart' show CoreReplyOptionType;
import 'package:skf/adapters/bilibili/models/dynamics/result.dart' show PicModel;
import 'package:skf/adapters/bilibili/models/dynamics/vote_model.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_reserve_info/data.dart';
import 'package:skf/adapters/bilibili/pages/common/publish/common_rich_text_pub_page.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_create_reserve/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_create_vote/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_mention/controller.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_select_topic/controller.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_select_topic/view.dart';
import 'package:skf/adapters/bilibili/pages/emote/controller.dart';
import 'package:skf/adapters/bilibili/pages/emote/view.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/date_utils.dart';
import 'package:skf/utils/extension/context_ext.dart';
import 'package:skf/utils/grid.dart';
import 'package:skf/adapters/bilibili/utils/request_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide showTimePicker;
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class CreateDynPanel extends CommonRichTextPubPage {
  const CreateDynPanel({
    super.key,
    super.imageLengthLimit = 18,
    super.items,
    super.pics,
    this.scrollController,
    this.topic,
    this.editConfig,
    this.title,
    this.isPrivate = false,
    this.replyOption = .allow,
    this.onSuccess,
  });

  final ScrollController? scrollController;
  final String? title;
  final Pair<int, String>? topic;
  final bool isPrivate;
  final ReplyOptionType replyOption;
  final ({String dynId, String? repostDynId})? editConfig;
  final VoidCallback? onSuccess;

  @override
  State<CreateDynPanel> createState() => _CreateDynPanelState();

  static void onCreateDyn(
    BuildContext context, {
    String? title,
    bool isPrivate = false,
    ReplyOptionType replyOption = .allow,
    List<RichTextItem>? items,
    List<PicModel>? pics,
    Pair<int, String>? topic,
    ({String dynId, String? repostDynId})? editConfig,
    VoidCallback? onSuccess,
  }) => showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => DynDraggableScrollableSheet(
      snap: true,
      expand: false,
      initialChildSize: 1,
      minChildSize: 0,
      maxChildSize: 1,
      snapSizes: const [1],
      builder: (context, scrollController) => CreateDynPanel(
        scrollController: scrollController,
        title: title,
        items: items,
        pics: pics,
        topic: topic,
        isPrivate: isPrivate,
        editConfig: editConfig,
        replyOption: replyOption,
        onSuccess: onSuccess,
      ),
    ),
  );
}

class _CreateDynPanelState extends CommonRichTextPubPageState<CreateDynPanel> {
  late final bool _isEdit;
  late bool _isPrivate;
  Pair<int, String>? _topic;
  late ReplyOptionType _replyOption;
  late final TextEditingController _titleEditCtr;
  DateTime? _publishTime;
  ReserveInfoData? _reserveCard;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.editConfig != null;
    _isPrivate = widget.isPrivate;
    _replyOption = widget.replyOption;
    _topic = widget.topic;
    _titleEditCtr = TextEditingController(text: widget.title);
  }

  @override
  void dispose() {
    _titleEditCtr.dispose();
    Get
      ..delete<EmotePanelController>()
      ..delete<SelectTopicController>()
      ..delete<DynMentionController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAppBar(theme),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            controller: widget.scrollController,
            physics: const ClampingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Builder(builder: (context) {
                    final hasTopic = _topic != null;
                    return Row(
                      spacing: 10,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            overlayColor: hasTopic ? Colors.transparent : null,
                            splashFactory: hasTopic
                                ? NoSplash.splashFactory
                                : null,
                            shape: hasTopic
                                ? null
                                : RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: hasTopic
                                          ? Colors.transparent
                                          : theme.colorScheme.outline
                                                .withValues(alpha: 0.2),
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(25),
                                    ),
                                  ),
                            minimumSize: Size.zero,
                            padding: hasTopic
                                ? const EdgeInsets.symmetric(vertical: 12)
                                : const EdgeInsets.all(12),
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _onSelectTopic,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: .middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Icon(
                                      CustomIcons.topic_tag,
                                      size: 18,
                                      color: hasTopic
                                          ? null
                                          : theme.colorScheme.outline,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: hasTopic
                                      ? _topic!.second
                                      : '选择话题',
                                  style: TextStyle(
                                    color: hasTopic
                                        ? null
                                        : theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (hasTopic)
                          iconButton(
                            size: 22,
                            iconSize: 16,
                            icon: const Icon(Icons.clear),
                            bgColor: theme.colorScheme.onInverseSurface,
                            iconColor: theme.colorScheme.onSurfaceVariant,
                            onPressed: () => setState(() { _topic = null; }),
                          ),
                      ],
                    );
                  }
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _titleEditCtr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '标题，选填20字',
                    isDense: true,
                    visualDensity: .standard,
                    contentPadding: EdgeInsets.zero,
                    border: const OutlineInputBorder(
                      gapPadding: 0,
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.outline.withValues(alpha: 0.7),
                    ),
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildEditWidget(theme),
              ),
              const SizedBox(height: 16),
              _buildReserveItem(theme),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPubTimeWidget,
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
}
