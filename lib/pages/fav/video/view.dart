import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/fav/fav_actions.dart';
import 'package:skf/pages/fav/video/controller.dart';
import 'package:skf/pages/fav/video/widgets/item.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/grid.dart';
import 'package:skf/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/adapters/bilibili/common/setting_providers.dart';
class FavVideoPage extends StatefulWidget {
  const FavVideoPage({super.key, this.actions});

  /// 收藏域导航契约（由 FavPage 注入）。
  final FavActions? actions;

  @override
  State<FavVideoPage> createState() => _FavVideoPageState();
}
class _FavVideoPageState extends State<FavVideoPage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  final FavController _favController = appRead(favControllerProvider);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: _favController.onRefresh,
      child: CustomScrollView(
        controller: _favController.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: 100 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            sliver: ListenableBuilder(
              listenable: _favController,
              builder: (_, __) => _buildBody(_favController.loadingState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LoadingState<List<CoreFavFolderInfo>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (BuildContext context, int index) {
                  if (index == response.length - 1) {
                    _favController.onLoadMore();
                  }
                  final item = response[index];
                  String heroTag = Utils.makeHeroTag(item.fid);
                  return FavVideoItem(
                    heroTag: heroTag,
                    item: item,
                    onSaveImage: () => widget.actions?.onSaveImage?.call(
                      item.title,
                      item.cover,
                    ),
                    onTap: () async {
                      final res = await AppNavigator.toNamed(
                        '/favDetail',
                        arguments: item,
                        parameters: {
                          'heroTag': heroTag,
                          'mediaId': item.id.toString(),
                        },
                      );
                      if (res == true) {
                        _favController.loadingState.data!.removeAt(index);
                        _favController.loadingState = _favController.loadingState;
                      }
                    },
                  );
                },
                itemCount: response.length,
              )
            : HttpError(onReload: _favController.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _favController.onReload,
      ),
    };
  }
}
