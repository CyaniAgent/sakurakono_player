import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/common/widgets/reorder_mixin.dart';
import 'package:skf/core/models/member_types.dart' show CoreMemberTagItemModel;
import 'package:skf/pages/follow/controller.dart';
import 'package:skf/pages/follow/follow_models.dart' show isCustomFollowTag;
import 'package:skf/router/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowTagSortPage extends StatefulWidget {
  const FollowTagSortPage({
    super.key,
    required this.notifier,
    required this.initialTabs,
  });

  final FollowControllerNotifier notifier;
  final List<CoreMemberTagItemModel> initialTabs;

  @override
  State<FollowTagSortPage> createState() => _FollowTagSortPageState();
}

class _FollowTagSortPageState extends State<FollowTagSortPage>
    with ReorderMixin {
  List<CoreMemberTagItemModel> _defTags = <CoreMemberTagItemModel>[];
  List<CoreMemberTagItemModel> _customTags = <CoreMemberTagItemModel>[];
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  @override
  void initState() {
    super.initState();
    for (final e in widget.initialTabs) {
      if (isCustomFollowTag(e.tagid)) {
        _customTags.add(e);
      } else {
        _defTags.add(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('关注分组排序'),
        actions: _customTags.isNotEmpty
            ? [
                TextButton(
                  onPressed: () async {
                    final res = await (_ref?.read(followRepositoryProvider) ?? appRead(followRepositoryProvider)).sortFollowTag(
                      tagids: _customTags.map((e) => e.tagid).join(','),
                    );
                    if (res.isSuccess) {
                      SmartDialog.showToast('排序完成');
                      final tabs = _defTags + _customTags;
                      widget.notifier.state = widget.notifier.state.copyWith(
                        tabs: tabs,
                        currentTabIndex: 0,
                      );
                      if (mounted) {
                        AppNavigator.back();
                      }
                    } else {
                      res.toast();
                    }
                  },
                  child: const Text('完成'),
                ),
                const SizedBox(width: 16),
              ]
            : null,
      ),
      body: _buildBody,
    );
  }

  void onReorderItem(int oldIndex, int newIndex) {
    _customTags.insert(newIndex, _customTags.removeAt(oldIndex));
    setState(() {});
  }

  Widget get _buildBody {
    return ReorderableListView.builder(
      onReorderItem: onReorderItem,
      proxyDecorator: proxyDecorator,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
      ),
      header: Column(
        children: _defTags.map((e) => _buildItem(e, enabled: false)).toList(),
      ),
      itemCount: _customTags.length,
      itemBuilder: (context, index) {
        return _buildItem(_customTags[index]);
      },
    );
  }

  Widget _buildItem(
    CoreMemberTagItemModel item, {
    bool enabled = true,
  }) {
    return ListTile(
      textColor: enabled ? null : scheme.outline,
      key: ValueKey(item.tagid),
      leading: enabled
          ? const Icon(Icons.group_outlined)
          : Icon(
              size: 23,
              Icons.lock_outline,
              color: scheme.outline,
            ),
      minLeadingWidth: 0,
      title: Text('${item.name} (${item.count})'),
      subtitle: item.tip?.isNotEmpty == true ? Text(item.tip!) : null,
    );
  }
}
