import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/adapters/bilibili/common/widgets/video_card/video_card_h.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/adapters/bilibili/pages/rank/zone/controller.dart';
import 'package:skf/adapters/bilibili/pages/rank/zone/widget/pgc_rank_item.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart';

class ZonePage extends StatefulWidget {
  const ZonePage({super.key, this.rid, this.seasonType});

  final int? rid;
  final int? seasonType;

  @override
  State<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  late final ZoneController controller;

  @override
  void initState() {
    controller = ZoneController(rid: widget.rid, seasonType: widget.seasonType);
    zoneRegistry['${widget.rid}${widget.seasonType}'] = controller;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 7, bottom: 100),
            sliver: ListenableBuilder(
              listenable: controller,
              builder: (_, _) => _buildBody(controller.loadingState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LoadingState<List<dynamic>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  final item = response[index];
                  if (item is CoreHotVideoItemModel) {
                    return VideoCardH(
                      videoItem: ModelConverters.hotVideoItem(item),
                      onRemove: () {
                        final current = controller.loadingState;
                        if (current case Success(:final response)) {
                          response!.removeAt(index);
                          controller.loadingState = current;
                        }
                      },
                    );
                  }
                  return PgcRankItem(
                    item: ModelConverters.pgcRankItem(
                      item as CorePgcRankItemModel,
                    ),
                  );
                },
                itemCount: response.length,
              )
            : HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }
}
