import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/adapters/bilibili/models/common/dm_block_type.dart';
import 'package:skf/adapters/bilibili/models/user/danmaku_rule.dart';
import 'package:skf/adapters/bilibili/pages/danmaku_block/controller.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/controller.dart';
import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/common/widgets/keep_alive_wrapper.dart';
import 'package:skf/common/widgets/loading_widget/loading_widget.dart';
import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/core/models/danmaku_block.dart' show CoreSimpleRule;
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';

class DanmakuBlockPage extends ConsumerStatefulWidget {
  const DanmakuBlockPage({super.key});

  @override
  ConsumerState<DanmakuBlockPage> createState() => _DanmakuBlockPageState();
}

class _DanmakuBlockPageState extends ConsumerState<DanmakuBlockPage>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  PlPlayerController? _plPlayerController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: DmBlockType.values.length,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _plPlayerController ??=
        ModalRoute.of(context)?.settings.arguments as PlPlayerController?;
  }

  @override
  void dispose() {
    final plController = _plPlayerController;
    if (plController != null) {
      final state = ref.read(danmakuBlockProvider);
      final ruleFilter = RuleFilter.fromRuleTypeEntries(
        state.rules.map((e) => e.toList()).toList(),
      );
      plController.filters = ruleFilter;
      GStorage.localCache.put(LocalCacheKey.danmakuFilterRules, ruleFilter);
    }
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(danmakuBlockProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('弹幕屏蔽'),
        bottom: TabBar(
          controller: tabController,
          tabs: DmBlockType.values
              .map(
                (e) => Tab(
                  text: '${e.label}(${state.rules[e.index].length})',
                ),
              )
              .toList(),
        ),
      ),
      body: tabBarView(
        controller: tabController,
        children: DmBlockType.values
            .map(
              (e) => KeepAliveWrapper(
                child: tabViewBuilder(e.index, state.rules[e.index]),
              ),
            )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加',
        onPressed: () =>
            _showAddDialog(DmBlockType.values[tabController.index]),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget tabViewBuilder(final int tabIndex, List<CoreSimpleRule> list) {
    if (list.isEmpty) {
      return scrollableError;
    }
    return ListView.builder(
      itemCount: list.length,
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
      ),
      itemBuilder: (context, itemIndex) {
        final CoreSimpleRule item = list[itemIndex];
        final child = iconButton(
          iconSize: 20,
          tooltip: '删除',
          icon: const Icon(Icons.delete_outlined),
          onPressed: () => showConfirmDialog(
            context: context,
            title: const Text('确定删除该规则？'),
            onConfirm: () => ref
                .read(danmakuBlockProvider.notifier)
                .danmakuFilterDel(
                  tabIndex,
                  itemIndex,
                  item.id,
                ),
          ),
        );
        return ListTile(
          title: Text(
            item.filter,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: tabIndex == 2
              ? child
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconButton(
                      iconSize: 20,
                      tooltip: '编辑',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showAddDialog(
                        DmBlockType.values[tabController.index],
                        initFilter: item.filter,
                        itemIndex: itemIndex,
                        itemId: item.id,
                      ),
                    ),
                    child,
                  ],
                ),
        );
      },
    );
  }

  void _showAddDialog(
    DmBlockType type, {
    String initFilter = '',
    int? itemIndex,
    int? itemId,
  }) {
    assert((itemIndex == null) == (itemId == null));
    String filter = initFilter;
    final hintText = switch (type) {
      DmBlockType.keyword => '输入过滤的关键词，其它类别请切换标签页后添加',
      DmBlockType.regex => '输入//之间的正则表达式，无需包含头尾的"/"',
      DmBlockType.uid => '输入用户UID',
    };
    final isUid = type == DmBlockType.uid;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${itemId != null ? "编辑" : "添加新的"}${type.label}规则'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hintText),
            TextFormField(
              autofocus: true,
              initialValue: filter,
              onChanged: (value) => filter = value,
              keyboardType: isUid ? TextInputType.number : null,
              inputFormatters: isUid
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            child: const Text('确定'),
            onPressed: () async {
              if (filter != initFilter) {
                Navigator.of(dialogContext).pop();
                final notifier = ref.read(danmakuBlockProvider.notifier);
                if (itemId != null) {
                  await notifier.danmakuFilterDel(
                    type.index,
                    itemIndex!,
                    itemId,
                  );
                }
                await notifier.danmakuFilterAdd(
                  filter: filter,
                  type: type.index,
                );
              } else {
                SmartDialog.showToast(
                  '输入内容${filter.isEmpty ? "不能为空" : "与上次相同"}',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
