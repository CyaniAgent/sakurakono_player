import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/adapters/bilibili/models/common/live/live_search_type.dart';
import 'package:skf/adapters/bilibili/pages/live_search/child/view.dart';
import 'package:skf/adapters/bilibili/pages/live_search/child/controller.dart';
import 'package:skf/adapters/bilibili/pages/live_search/controller.dart';
import 'package:skf/core/models/live_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveSearchPage extends ConsumerStatefulWidget {
  const LiveSearchPage({
    super.key,
    this.mid,
    this.uname,
  });

  final String? mid;
  final String? uname;

  @override
  ConsumerState<LiveSearchPage> createState() => _LiveSearchPageState();
}

class _LiveSearchPageState extends ConsumerState<LiveSearchPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final LiveSearchChildController _roomCtr;
  late final LiveSearchChildController _userCtr;

  LiveSearchParams get _params =>
      LiveSearchParams(mid: widget.mid, uname: widget.uname);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    final notifier = ref.read(liveSearchProvider(_params).notifier);
    _roomCtr = LiveSearchChildController(notifier, CoreLiveSearchType.room);
    _userCtr = LiveSearchChildController(notifier, CoreLiveSearchType.user);
    _roomCtr.attachRef(ref);
    _userCtr.attachRef(ref);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onClear() {
    final notifier = ref.read(liveSearchProvider(_params).notifier);
    if (notifier.editingController.text.isNotEmpty) {
      notifier.clearSearchData();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onSubmit() {
    final notifier = ref.read(liveSearchProvider(_params).notifier);
    notifier.submitSearch(roomCtr: _roomCtr, userCtr: _userCtr);
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveSearchProvider(_params));
    final notifier = ref.read(liveSearchProvider(_params).notifier);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: _onSubmit,
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
            hintText: '搜索房间或主播',
            visualDensity: .standard,
            border: InputBorder.none,
            suffixIcon: IconButton(
              tooltip: '清空',
              icon: const Icon(Icons.clear, size: 22),
              onPressed: _onClear,
            ),
          ),
          onSubmitted: (_) => _onSubmit(),
          onChanged: (value) {
            if (value.isEmpty) {
              notifier.setHasData(false);
            }
          },
        ),
      ),
      body: ViewSafeArea(
        child: Opacity(
          opacity: liveState.hasData ? 1 : 0,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    text: '正在直播 ${liveState.counts[0] != -1 ? liveState.counts[0] : ''}',
                  ),
                  Tab(
                    text: '主播 ${liveState.counts[1] != -1 ? liveState.counts[1] : ''}',
                  ),
                ],
                onTap: (index) {
                  if (!_tabController.indexIsChanging) {
                    if (index == 0) {
                      _roomCtr.animateToTop();
                    } else {
                      _userCtr.animateToTop();
                    }
                  }
                },
              ),
              Expanded(
                child: tabBarView(
                  controller: _tabController,
                  children: [
                    LiveSearchChildPage(
                      controller: _roomCtr,
                      searchType: LiveSearchType.room,
                    ),
                    LiveSearchChildPage(
                      controller: _userCtr,
                      searchType: LiveSearchType.user,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
