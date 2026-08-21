import 'package:skf/common/skeleton/msg_feed_top.dart';
import 'package:skf/common/skeleton/video_card_v.dart';
import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models/common/live/live_search_type.dart';
import 'package:skf/adapters/bilibili/pages/live_search/child/controller.dart';
import 'package:skf/adapters/bilibili/pages/live_search/widgets/live_search_room.dart';
import 'package:skf/adapters/bilibili/pages/live_search/widgets/live_search_user.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart'
    hide SliverGridDelegateWithMaxCrossAxisExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveSearchChildPage extends ConsumerStatefulWidget {
  const LiveSearchChildPage({
    super.key,
    required this.controller,
    required this.searchType,
  });

  final LiveSearchChildController controller;
  final LiveSearchType searchType;

  @override
  ConsumerState<LiveSearchChildPage> createState() => _LiveSearchChildPageState();
}

class _LiveSearchChildPageState extends ConsumerState<LiveSearchChildPage>
    with AutomaticKeepAliveClientMixin {
  LiveSearchChildController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double padding = widget.searchType == LiveSearchType.room ? 12 : 0;
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: padding,
              left: padding,
              right: padding,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: ListenableBuilder(listenable: _controller, builder: (_, __) => _buildBody(_controller.loadingState)),
          ),
        ],
      ),
    );
  }

  Widget get _buildLoading {
    return switch (widget.searchType) {
      LiveSearchType.room => SliverGrid.builder(
        gridDelegate: roomDelegate,
        itemBuilder: (context, index) => const VideoCardVSkeleton(),
        itemCount: 10,
      ),
      LiveSearchType.user => SliverGrid.builder(
        gridDelegate: userDelegate,
        itemBuilder: (context, index) => const MsgFeedTopSkeleton(),
        itemCount: 12,
      ),
    };
  }

  late final roomDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: Style.cardSpace,
    crossAxisSpacing: Style.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth,
    childAspectRatio: Style.aspectRatio,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(60),
  );

  late final userDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Grid.smallCardWidth * 2,
    mainAxisExtent: 60,
  );

  Widget _buildBody(LoadingState<List?> loadingState) {
    return switch (loadingState) {
      Loading() => _buildLoading,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? Builder(
                builder: (context) {
                  return switch (widget.searchType) {
                    LiveSearchType.room => SliverGrid.builder(
                      gridDelegate: roomDelegate,
                      itemBuilder: (context, index) {
                        if (index == response.length - 1) {
                          _controller.onLoadMore();
                        }
                        return LiveCardVSearch(
                          item: response[index],
                        );
                      },
                      itemCount: response.length,
                    ),
                    LiveSearchType.user => SliverGrid.builder(
                      gridDelegate: userDelegate,
                      itemBuilder: (context, index) {
                        if (index == response.length - 1) {
                          _controller.onLoadMore();
                        }
                        return LiveSearchUserItem(
                          item: response[index],
                        );
                      },
                      itemCount: response.length,
                    ),
                  };
                },
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  @override
  bool get wantKeepAlive => true;
}
