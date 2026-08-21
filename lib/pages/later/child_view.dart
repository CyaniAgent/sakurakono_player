import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/later/later_view_type.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/pages/later/base_controller.dart';
import 'package:skf/pages/later/controller.dart';
import 'package:skf/pages/later/later_actions.dart';
import 'package:skf/pages/later/widgets/video_card_h_later.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LaterViewChildPage extends ConsumerStatefulWidget {
  const LaterViewChildPage({
    super.key,
    required this.laterViewType,
    this.actions,
  });

  final LaterViewType laterViewType;

  /// 导航契约（适配器注入），null 时对应导航动作禁用。
  final LaterActions? actions;

  @override
  ConsumerState<LaterViewChildPage> createState() => _LaterViewChildPageState();
}

class _LaterViewChildPageState extends ConsumerState<LaterViewChildPage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  late final LaterController _laterController;

  @override
  void initState() {
    super.initState();
    _laterController = Get.put(
      LaterController(
        widget.laterViewType,
        actions: widget.actions,
      ),
      tag: widget.laterViewType.type.toString(),
    );
    _laterController.attachRef(ProviderScope.containerOf(context));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: _laterController.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _laterController.scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 85,
            ),
            sliver: Obx(
              () => _buildBody(_laterController.loadingState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LoadingState<List<CoreLaterItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _laterController.onLoadMore();
                  }
                  final videoItem = response[index];
                  return VideoCardHLater(
                    index: index,
                    videoItem: videoItem,
                    ctr: _laterController,
                    actions: widget.actions,
                    onViewLater: (cid) {
                      widget.actions?.onViewVideo?.call(
                        LaterVideoRequest(
                          bvid: videoItem.bvid,
                          cid: cid,
                          cover: videoItem.pic,
                          title: videoItem.title,
                          dimension: videoItem.dimension,
                          isWatchLaterPlaylist:
                              ref.read(laterBaseProvider).isPlayAll,
                          watchLaterExtra: {
                            'oid': videoItem.aid,
                            'count': ref.read(laterBaseProvider).counts[LaterViewType.all.index],
                            'favTitle': '稍后再看',
                            'mediaId': _laterController.mid,
                            'desc': _laterController.asc.value,
                            'isContinuePlaying': index != 0,
                          },
                        ),
                      );
                    },
                  );
                },
                itemCount: response.length,
              )
            : HttpError(onReload: _laterController.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _laterController.onReload,
      ),
    };
  }

  @override
  bool get wantKeepAlive => true;
}
