import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/adapters/bilibili/pages/member_season_series/controller.dart';
import 'package:skf/adapters/bilibili/pages/member_season_series/widget/season_series_card.dart';
import 'package:skf/adapters/bilibili/pages/member_video/view.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart';

class SeasonSeriesPage extends StatefulWidget {
  const SeasonSeriesPage({
    super.key,
    required this.mid,
    this.heroTag,
  });

  final int mid;
  final String? heroTag;

  @override
  State<SeasonSeriesPage> createState() => _SeasonSeriesPageState();
}

class _SeasonSeriesPageState extends State<SeasonSeriesPage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  late final SeasonSeriesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SeasonSeriesController(widget.mid);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
          ),
          sliver: ListenableBuilder(listenable: _controller, builder: (_, _) => _buildBody(_controller.loadingState)),
        ),
      ],
    );
  }

  Widget _buildBody(LoadingState<List<CoreSpaceSsModel>?> loadingState) {
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
                  CoreSpaceSsModel item = response[index];
                  return SeasonSeriesCard(
                    item: item,
                    onTap: () {
                      bool isSeason = item.meta!.seasonId != null;
                      AppNavigator.to(
                        Scaffold(
                          resizeToAvoidBottomInset: false,
                          appBar: AppBar(title: Text(item.meta!.name!)),
                          body: ViewSafeArea(
                            child: MemberVideo(
                              type: isSeason
                                  ? CoreContributeType.season
                                  : CoreContributeType.series,
                              heroTag: widget.heroTag,
                              mid: widget.mid,
                              seasonId: isSeason ? item.meta!.seasonId : null,
                              seriesId: isSeason ? null : item.meta!.seriesId,
                              title: item.meta!.name,
                            ),
                          ),
                        ),
                      );
                    },
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
