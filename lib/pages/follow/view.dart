import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/common/widgets/dialog/simple_dialog_option.dart';
import 'package:skf/common/widgets/loading_widget/loading_widget.dart';
import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/core/models/member_types.dart' show CoreMemberTagItemModel;
import 'package:skf/pages/follow/child/child_controller.dart';
import 'package:skf/pages/follow/child/child_view.dart';
import 'package:skf/pages/follow/controller.dart';
import 'package:skf/pages/follow/follow_actions.dart' show FollowActions;
import 'package:skf/pages/follow/follow_models.dart' show isCustomFollowTag;
import 'package:skf/pages/follow_tag_sort/view.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/parse_int.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class FollowPage extends ConsumerStatefulWidget {
  const FollowPage({super.key});

  @override
  ConsumerState<FollowPage> createState() => _FollowPageState();

  static void toFollowPage({dynamic mid, String? name}) {
    if (mid == null) return;
    AppNavigator.toNamed(
      '/follow',
      arguments: {
        'mid': safeToInt(mid),
        'name': name,
      },
    );
  }
}

class _FollowPageState extends ConsumerState<FollowPage>
    with TickerProviderStateMixin {
  final _tag = Utils.generateRandomString(8);
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _syncTabController(List<CoreMemberTagItemModel> tabs) {
    if (tabs.isEmpty) return;
    final currentIndex = _tabController?.index.clamp(0, tabs.length - 1) ?? 0;
    _tabController?.dispose();
    _tabController = TabController(
      initialIndex: currentIndex,
      length: tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final followState = ref.watch(followControllerProvider);
    final notifier = ref.read(followControllerProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(followState, notifier),
      body: followState.isOwner
          ? _buildBody(followState, notifier)
          : _childPage(notifier, followState),
    );
  }

  PreferredSizeWidget _buildAppBar(
    FollowState followState,
    FollowControllerNotifier notifier,
  ) =>
      AppBar(
        title: followState.isOwner
            ? const Text('我的关注')
            : Text(followState.name != null ? '${followState.name}的关注' : ''),
        actions: followState.isOwner
            ? [
                IconButton(
                  onPressed: () => FollowActions.createFavTag(
                    context,
                    notifier.onCreateFavTag,
                  ),
                  icon: const Icon(Icons.add),
                  tooltip: '新建分组',
                ),
                IconButton(
                  onPressed: () {
                    if (followState.tabs.isEmpty) return;
                    _syncTabController(followState.tabs);
                    AppNavigator.to(
                      FollowTagSortPage(
                        notifier: notifier,
                        initialTabs: followState.tabs,
                      ),
                    );
                  },
                  icon: const Icon(Icons.sort),
                  tooltip: '分组排序',
                ),
                IconButton(
                  onPressed: () => AppNavigator.toNamed(
                    '/followSearch',
                    arguments: {
                      'mid': followState.mid,
                    },
                  ),
                  icon: const Icon(Icons.search_outlined),
                  tooltip: '搜索',
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => AppNavigator.toNamed('/blackListPage'),
                      child: const Row(
                        spacing: 10,
                        mainAxisSize: .min,
                        children: [
                          Icon(Icons.block, size: 19),
                          Text('黑名单管理'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
              ]
            : null,
      );

  Widget _childPage(
    FollowControllerNotifier notifier,
    FollowState followState, [
    CoreMemberTagItemModel? item,
  ]) =>
      FollowChildPage(
        tag: _tag,
        followState: followState,
        notifier: notifier,
        mid: followState.mid,
        tagid: item?.tagid,
      );

  Widget _buildBody(
    FollowState followState,
    FollowControllerNotifier notifier,
  ) {
    if (followState.isTagsLoading) return m3eLoading;
    if (followState.tabs.isEmpty) return _childPage(notifier, followState);
    _syncTabController(followState.tabs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewSafeArea(
          child: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            controller: _tabController,
            tabs: List.generate(followState.tabs.length, (index) {
              final item = followState.tabs[index];
              final int? count = item.count;
              if (isCustomFollowTag(item.tagid)) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onLongPress: () {
                    Feedback.forLongPress(context);
                    _onHandleTag(index, item, notifier);
                  },
                  onSecondaryTap: PlatformUtils.isMobile
                      ? null
                      : () => _onHandleTag(index, item, notifier),
                  child: Tab(
                    child: Row(
                      children: [
                        Text(
                          '${item.name}${count != null ? '($count)' : ''} ',
                        ),
                        const Icon(Icons.menu, size: 18),
                      ],
                    ),
                  ),
                );
              }
              return Tab(
                text: '${item.name}${count != null ? '($count)' : ''}',
              );
            }),
            onTap: (value) {
              if (_tabController != null && !_tabController!.indexIsChanging) {
                final item = followState.tabs[value];
                try {
                  appRead(
                    followChildControllerProvider('$_tag${item.tagid}'),
                  ).animateToTop();
                } catch (_) {}
              }
            },
          ),
        ),
        Expanded(
          child: tabBarView(
            controller: _tabController,
            children: followState.tabs
                .map(
                  (item) => _childPage(notifier, followState, item),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  void _onHandleTag(
    int index,
    CoreMemberTagItemModel item,
    FollowControllerNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          DialogOption(
            onPressed: () {
              AppNavigator.back();
              String tagName = item.name!;
              showConfirmDialog(
                context: context,
                title: const Text('编辑分组名称'),
                content: TextFormField(
                  autofocus: true,
                  initialValue: tagName,
                  onChanged: (value) => tagName = value,
                  inputFormatters: [LengthLimitingTextInputFormatter(16)],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                onConfirm: () {
                  if (tagName.isNotEmpty) {
                    notifier.onUpdateTag(item, tagName);
                  }
                },
              );
            },
            child: const Text('修改名称', style: TextStyle(fontSize: 14)),
          ),
          DialogOption(
            onPressed: () {
              AppNavigator.back();
              showConfirmDialog(
                context: context,
                title: const Text('删除分组'),
                content: const Text('删除后，该分组下的用户依旧保留？'),
                onConfirm: () => notifier.onDelTag(index, item.tagid!),
              );
            },
            child: const Text('删除分组', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
