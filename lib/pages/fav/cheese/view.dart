import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/fav/cheese/controller.dart';
import 'package:skf/pages/fav/cheese/widgets/item.dart';
import 'package:skf/pages/fav/fav_actions.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class FavCheesePage extends StatefulWidget {
  const FavCheesePage({super.key, this.actions});

  /// 收藏域导航契约（由 FavPage 注入）。
  final FavActions? actions;

  @override
  State<FavCheesePage> createState() => _FavCheesePageState();
}
class _FavCheesePageState extends State<FavCheesePage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  final FavCheeseController _controller = Get.put(FavCheeseController());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData theme = Theme.of(context);
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: ListenableBuilder(
              listenable: _controller,
              builder: (_, _) => _buildBody(theme, _controller.loadingState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<CoreSpaceCheeseItem>?> loadingState,
  ) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  final item = response[index];
                  return FavCheeseItem(
                    item: item,
                    onOpen: () => widget.actions?.onViewPugv?.call(
                      item.seasonId,
                    ),
                    onSaveImage: () => widget.actions?.onSaveImage?.call(
                      item.title,
                      item.cover,
                    ),
                    onRemove: () => showConfirmDialog(
                      context: context,
                      title: const Text('确定取消收藏该课堂？'),
                      onConfirm: () =>
                          _controller.onRemove(index, item.seasonId!),
                    ),
                  );
                },
                itemCount: response.length,
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }
}
