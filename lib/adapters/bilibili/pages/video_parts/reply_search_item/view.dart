import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/adapters/bilibili/models/common/reply/reply_search_type.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply_search_item/child/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply_search_item/child/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply_search_item/controller.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReplySearchPage extends ConsumerStatefulWidget {
  const ReplySearchPage({
    super.key,
    required this.type,
    required this.oid,
  });

  final int type;
  final int oid;

  @override
  ConsumerState<ReplySearchPage> createState() => _ReplySearchPageState();
}

class _ReplySearchPageState extends ConsumerState<ReplySearchPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ReplySearchChildController _videoCtr;
  late final ReplySearchChildController _articleCtr;

  ({int type, int oid}) get _providerParam =>
      (type: widget.type, oid: widget.oid);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);

    final notifier =
        ref.read(replySearchProvider(_providerParam).notifier);
    _videoCtr =
        ReplySearchChildController(notifier, ReplySearchType.video);
    _articleCtr =
        ReplySearchChildController(notifier, ReplySearchType.article);

    _submit();
  }

  void _submit() {
    _videoCtr
      ..scrollController.jumpToTop()
      ..onReload();
    _articleCtr
      ..scrollController.jumpToTop()
      ..onReload();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoCtr.dispose();
    _articleCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier =
        ref.watch(replySearchProvider(_providerParam).notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: _submit,
            icon: const Icon(Icons.search, size: 22),
          ),
          const SizedBox(width: 10),
        ],
        title: TextField(
          autofocus: true,
          focusNode: notifier.focusNode,
          controller: notifier.editingController,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: '搜索',
            visualDensity: .standard,
            border: InputBorder.none,
            suffixIcon: IconButton(
              tooltip: '清空',
              icon: const Icon(Icons.clear, size: 22),
              onPressed: () {
                if (!notifier.tryClear()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ),
      body: ViewSafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '视频'),
                Tab(text: '专栏'),
              ],
              onTap: (index) {
                if (!_tabController.indexIsChanging) {
                  if (index == 0) {
                    _videoCtr.animateToTop();
                  } else {
                    _articleCtr.animateToTop();
                  }
                }
              },
            ),
            Expanded(
              child: tabBarView(
                controller: _tabController,
                children: [
                  ReplySearchChildPage(
                    controller: _videoCtr,
                    searchType: ReplySearchType.video,
                  ),
                  ReplySearchChildPage(
                    controller: _articleCtr,
                    searchType: ReplySearchType.article,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
