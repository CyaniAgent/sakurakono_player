/// Follow-group assignment panel — ported from the bilibili adapter's
/// `pages/group_panel/view.dart` (GroupPanel) onto core models/repos.
/// The adapter original stays for its other call sites.
library;

import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/common/widgets/loading_widget/loading_widget.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/follow/follow_actions.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowTagPanel extends StatefulWidget {
  final int mid;
  final List<int>? tags;
  final ScrollController? scrollController;
  const FollowTagPanel({
    super.key,
    required this.mid,
    this.tags,
    this.scrollController,
  });

  @override
  State<FollowTagPanel> createState() => _FollowTagPanelState();
}

class _FollowTagPanelState extends State<FollowTagPanel> {
  LoadingState<List<CoreMemberTagItemModel>> loadingState =
      LoadingState.loading();
  bool _showDefaultBtn = true;
  late final Set<int> tags = widget.tags == null
      ? {}
      : Set<int>.from(widget.tags!);
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  @override
  void initState() {
    super.initState();
    _queryFollowUpTags();
  }

  void _queryFollowUpTags() {
    _ref!.read(memberRepositoryProvider).followUpTags().then((res) {
      if (mounted) {
        loadingState = switch (res) {
              Loading() => LoadingState.loading(),
              Success(:final response) => Success(
                response.toList()
                  ..removeFirstWhere((e) => e.tagid == 0),
              ),
              Error(:final errMsg) => Error(errMsg),
            };
        _showDefaultBtn = tags.isEmpty;
        setState(() {});
      }
    });
  }

  Future<void> onSave() async {
    if (!loadingState.isSuccess) {
      AppNavigator.back();
      return;
    }
    feedBack();
    // 保存
    final res = await _ref!.read(memberRepositoryProvider).addUsers(
      widget.mid.toString(),
      tags.isEmpty ? '0' : tags.join(','),
    );
    if (res.isSuccess) {
      SmartDialog.showToast('保存成功');
      AppNavigator.back(result: tags);
    } else {
      res.toast();
    }
  }

  Widget get _buildBody {
    return switch (loadingState) {
      Loading() => m3eLoading,
      Success(:final response) => ListView.builder(
        controller: widget.scrollController,
        itemCount: response.length,
        itemBuilder: (context, index) {
          final item = response[index];
          return Material(
            type: MaterialType.transparency,
            child: Builder(
              builder: (context) {
                void onTap() {
                  final tagid = item.tagid!;
                  if (tags.contains(tagid)) {
                    tags.remove(tagid);
                    item.count = (item.count ?? 0) - 1;
                  } else {
                    tags.add(tagid);
                    item.count = (item.count ?? 0) + 1;
                  }
                  (context as Element).markNeedsBuild();
                  setState(() {
                    _showDefaultBtn = tags.isEmpty;
                  });
                }

                return ListTile(
                  onTap: onTap,
                  dense: true,
                  leading: const Icon(Icons.group_outlined),
                  minLeadingWidth: 0,
                  title: Text('${item.name} (${item.count})'),
                  subtitle: item.tip?.isNotEmpty == true
                      ? Text(item.tip!)
                      : null,
                  trailing: Transform.scale(
                    scale: 0.9,
                    child: Checkbox(
                      value: tags.contains(item.tagid),
                      onChanged: (_) => onTap(),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      Error(:final errMsg) => scrollErrorWidget(
        controller: widget.scrollController,
        errMsg: errMsg,
        onReload: _queryFollowUpTags,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: .end,
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          leading: const IconButton(
            tooltip: '关闭',
            onPressed: AppNavigator.back,
            icon: Icon(Icons.close_outlined),
          ),
          title: const Text('设置关注分组'),
          actions: [
            TextButton.icon(
              onPressed: () => FollowActions.createFavTag(
                context,
                _onCreateFavTag,
              ),
              icon: Icon(Icons.add, color: theme.colorScheme.primary),
              label: const Text('新建分组'),
              style: const ButtonStyle(
                visualDensity: .compact,
                padding: WidgetStatePropertyAll(
                  .symmetric(horizontal: 18, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        Expanded(child: _buildBody),
        Divider(
          height: 1,
          color: theme.disabledColor.withValues(alpha: 0.08),
        ),
        Padding(
          padding: .only(
            right: 20,
            top: 12,
            bottom: MediaQuery.viewPaddingOf(context).bottom + 12,
          ),
          child: FilledButton.tonal(
            onPressed: onSave,
            style: const ButtonStyle(visualDensity: .compact),
            child: Text(_showDefaultBtn ? '保存至默认分组' : '保存'),
          ),
        ),
      ],
    );
  }

  void _onCreateFavTag(({int tagid, String tagName}) res) {
    if (!mounted) return;
    if (loadingState case Success(:final response)) {
      response.add(CoreMemberTagItemModel.fromCreate(res, count: 1));
      tags.add(res.tagid);
      setState(() {
        _showDefaultBtn = false;
      });
    } else {
      _queryFollowUpTags();
    }
  }
}
