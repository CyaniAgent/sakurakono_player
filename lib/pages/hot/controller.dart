import 'package:flutter/widgets.dart' show ScrollController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class HotController
    extends CommonListControllerRiverpod<List<CoreHotVideoItemModel>, CoreHotVideoItemModel> {
  HotController({this.timeLimitDays});

  /// 榜单时间窗口(天):7=本周 / 30=本月 / 90=本季;null=适配器默认窗口。
  final int? timeLimitDays;

  bool _requested = false;

  /// 子榜懒加载:provider family 常驻,首次进入页面时才发请求,
  /// 避免应用启动即拉满三个榜单。
  void ensureLoaded() {
    if (_requested) return;
    _requested = true;
    queryData();
  }

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>>> customGetData() async {
    final result = await (appRead(videoRepositoryProvider)).hotVideoList(
      pn: page,
      ps: 20,
      timeLimitDays: timeLimitDays,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}

/// 各时间窗口榜单的控制器(family: key = timeLimitDays)。
final hotControllerProvider = Provider.family<HotController, int>((
  ref,
  timeLimitDays,
) {
  return HotController(timeLimitDays: timeLimitDays);
});

/// 热门页对外(首页外壳)的滚动/刷新代理:热门内部是三个子榜 tab,
/// 外壳的双击回顶/下拉刷新应作用在**当前子榜**上;子页 build 时经
/// [bind] 注册自己的控制器。
class HotCoordinator with ScrollOrRefreshMixin {
  HotCoordinator._();

  static final HotCoordinator instance = HotCoordinator._();

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
