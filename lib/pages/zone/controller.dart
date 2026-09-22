import 'package:flutter/widgets.dart' show ScrollController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';

/// 单个分区的视频列表控制器(family: key = 分区 id)。
///
/// 分区列表为单批数据(适配器端无通用分页参数),首屏加载完即置
/// [isEnd],不再触发加载更多。
class ZoneController
    extends CommonListControllerRiverpod<List<CoreHotVideoItemModel>, CoreHotVideoItemModel> {
  ZoneController({required this.category});

  final int category;

  bool _requested = false;

  /// 分区页懒加载:family 常驻,首次进入才发请求。
  void ensureLoaded() {
    if (_requested) return;
    _requested = true;
    queryData();
  }

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>>> customGetData() async {
    final result = await appRead(
      videoRepositoryProvider,
    ).categoryVideoList(category: category, num: 50);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void checkIsEnd(int length) => isEnd = true;
}

final zoneControllerProvider = Provider.family<ZoneController, int>((
  ref,
  category,
) {
  return ZoneController(category: category);
});

/// 分区页对外(首页外壳)的滚动/刷新代理,与热门页 [HotCoordinator] 同构:
/// 双击回顶/下拉刷新代理到当前选中分区。
class ZoneCoordinator with ScrollOrRefreshMixin {
  ZoneCoordinator._();

  static final ZoneCoordinator instance = ZoneCoordinator._();

  static final ScrollController _detached = ScrollController();

  ScrollOrRefreshMixin? _active;

  static ScrollOrRefreshMixin? get active => instance._active;

  static set active(ScrollOrRefreshMixin? controller) =>
      instance._active = controller;

  @override
  ScrollController get scrollController =>
      _active?.scrollController ?? _detached;

  @override
  void animateToTop() => _active?.animateToTop();

  @override
  Future<void> onRefresh() => _active?.onRefresh() ?? Future<void>.value();

  @override
  void toTopOrRefresh() => _active?.toTopOrRefresh();
}
