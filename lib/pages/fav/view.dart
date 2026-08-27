import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/fav/fav_actions.dart';
import 'package:skf/pages/fav/fav_type.dart';
import 'package:skf/pages/fav/video/controller.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/pages/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key, this.actions});

  /// 收藏域导航契约（适配器注入，见 bilibili bridge）。
  final FavActions? actions;

  @override
  State<FavPage> createState() => _FavPageState();
}
class _FavPageState extends State<FavPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final FavController _favController = Get.put(FavController());
  bool _showVideoFavMenu = false;

  void listener() {
    setState(() {
      _showVideoFavMenu = _tabController.index == 0;
    });
  }

  @override
  void initState() {
    super.initState();
    int initialIndex = AppNavigator.argsOf(context) is int ? AppNavigator.argsOf(context) as int : 0;
    _showVideoFavMenu = (initialIndex == 0);
    _tabController = TabController(
      length: FavTabType.values.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(listener);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(listener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('我的收藏'),
        actions: [
          _showVideoFavMenu
              ? IconButton(
                  onPressed: () => AppNavigator.toNamed('/createFav')?.then(
                    (data) {
                      if (data != null) {
                        final list =
                            _favController.loadingState.dataOrNull;
                        if (list != null && list.isNotEmpty) {
                          list.insert(1, data);
                          _favController.loadingState = _favController.loadingState;
                        } else {
                          _favController.loadingState = Success([data]);
                        }
                      }
                    },
                  ),
                  icon: const Icon(Icons.add),
                  tooltip: '新建收藏夹',
                )
              : const SizedBox.shrink(),
          _showVideoFavMenu
              ? IconButton(
                  onPressed: () {
                    if (_favController.loadingState.isSuccess) {
                      if (!_favController.isEnd) {
                        SmartDialog.showToast('加载全部收藏夹再排序');
                        return;
                      }
                      widget.actions?.onOpenFolderSort?.call(
                        _favController,
                      );
                    }
                  },
                  icon: const Icon(Icons.sort),
                  tooltip: '收藏夹排序',
                )
              : const SizedBox.shrink(),
          _showVideoFavMenu
              ? IconButton(
                  onPressed: () {
                    if (_favController.loadingState case Success(
                      :final response,
                    )) {
                      try {
                        if (response == null || response.isEmpty) return;
                        final item = response.first;
                        AppNavigator.toNamed(
                          '/favSearch',
                          arguments: {
                            'type': 1,
                            'mediaId': item.id,
                            'title': item.title,
                            'count': item.mediaCount,
                            'isOwner': true,
                          },
                        );
                      } catch (_) {}
                    }
                  },
                  icon: const Icon(Icons.search_outlined),
                  tooltip: '搜索',
                )
              : const SizedBox.shrink(),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: FavTabType.values.map((item) => Tab(text: item.title)).toList(),
          onTap: (index) {
            try {
              if (!_tabController.indexIsChanging) {
                switch (FavTabType.values[index]) {
                  case FavTabType.video:
                    _favController.scrollController.animToTop();
                  case FavTabType.article:
                    appRead(favArticleControllerProvider).scrollController
                        .animToTop();
                  case FavTabType.topic:
                    appRead(favTopicControllerProvider).scrollController.animToTop();
                  case FavTabType.cheese:
                    appRead(favCheeseControllerProvider).scrollController
                        .animToTop();
                  default:
                }
              }
            } catch (_) {}
          },
        ),
      ),
      body: ViewSafeArea(
        child: tabBarView(
          controller: _tabController,
          children: FavTabType.values
              .map((type) => favPageFor(type, actions: widget.actions))
              .toList(),
        ),
      ),
    );
  }
}
