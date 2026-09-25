import 'package:flutter/material.dart';
import 'package:skf/common/skeleton/video_card_v.dart' show VideoCardVSkeleton;
import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/rcmd/controller.dart';
import 'package:skf/pages/rcmd/widgets/home_slideshow.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/grid.dart';
import 'package:skf/utils/num_utils.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/utils/utils.dart';

/// 首页推荐页(框架级):数据来自 core `VideoRepository.rcmdVideoList /
/// rcmdVideoListApp`,由当前激活适配器提供实现。
class RcmdPage extends StatefulWidget {
  const RcmdPage({super.key});

  @override
  State<RcmdPage> createState() => _RcmdPageState();
}

class _RcmdPageState extends State<RcmdPage> with AutomaticKeepAliveClientMixin {
  final RcmdController controller = appRead(rcmdControllerProvider);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = ColorScheme.of(context);
    return Container(
      clipBehavior: .hardEdge,
      margin: const .symmetric(horizontal: Style.safeSpace),
      decoration: const BoxDecoration(borderRadius: Style.mdRadius),
      child: refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: HomeSlideshow()),
            SliverPadding(
              padding: const .only(top: Style.cardSpace, bottom: 100),
              sliver: ListenableBuilder(
                listenable: controller,
                builder: (_, _) =>
                    _buildBody(colorScheme, controller.loadingState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: Style.cardSpace,
    crossAxisSpacing: Style.cardSpace,
    maxCrossAxisExtent: Pref.recommendCardWidth,
    childAspectRatio: Style.aspectRatio,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
  );

  Widget _buildBody(
    ColorScheme colorScheme,
    LoadingState<List<dynamic>?> loadingState,
  ) {
    return switch (loadingState) {
      Loading() => SliverGrid.builder(
          gridDelegate: gridDelegate,
          itemCount: 10,
          itemBuilder: (context, index) => const VideoCardVSkeleton(),
        ),
      Error(:final errMsg) => SliverToBoxAdapter(
          child: HttpError(errMsg: errMsg, onReload: controller.onReload),
        ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemCount: response.length,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    controller.onLoadMore();
                  }
                  if (controller.lastRefreshAt != null) {
                    if (controller.lastRefreshAt == index) {
                      return GestureDetector(
                        onTap: () => controller
                          ..animateToTop()
                          ..onRefresh(),
                        child: Card(
                          child: Container(
                            alignment: Alignment.center,
                            padding: const .symmetric(horizontal: 10),
                            child: Text(
                              '上次看到这里\n点击刷新',
                              textAlign: .center,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final actualIndex = index > controller.lastRefreshAt!
                        ? index - 1
                        : index;
                    return _RcmdCard(item: response[actualIndex]);
                  }
                  return _RcmdCard(item: response[index]);
                },
              )
            : const VideoCardVSkeleton(),
    };
  }
}

class _RcmdCard extends StatelessWidget {
  const _RcmdCard({required this.item});

  final CoreRcmdVideoItemModel item;

  void _onTap() {
    if (item.goto != null && item.goto != 'av') return;
    AppNavigator.toNamed(
      '/videoV',
      preventDuplicates: false,
      arguments: <String, dynamic>{
        'aid': item.aid,
        'bvid': item.bvid,
        'cid': item.cid ?? 0,
        'cover': item.cover,
        'title': item.title,
        'heroTag': Utils.makeHeroTag(item.cid ?? item.aid),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Card(
      clipBehavior: .hardEdge,
      child: InkWell(
        onTap: _onTap,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: .expand,
                children: [
                  NetworkImgLayer(src: item.cover, width: 320, height: 180),
                  if ((item.duration ?? 0) > 0)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const .symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(item.duration),
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const .all(8),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title ?? '',
                        maxLines: 2,
                        overflow: .ellipsis,
                        style: const TextStyle(height: 1.3),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.slideshow,
                            size: 13, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          NumUtils.numFormat(
                            (item.stat?['view'] as int?) ?? 0,
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.subtitles_outlined,
                            size: 13, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          NumUtils.numFormat(
                            (item.stat?['danmaku'] as int?) ?? 0,
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.owner?['name'] ?? '',
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
