import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/loading_widget/loading_widget.dart'
    show m3eLoading;
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/fav/topic/controller.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/grid.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:flutter/material.dart'
    hide SliverGridDelegateWithMaxCrossAxisExtent;
import 'package:skf/core/container/app_container.dart';
import 'package:skf/pages/providers.dart';

class FavTopicPage extends StatefulWidget {
  const FavTopicPage({super.key});

  @override
  State<FavTopicPage> createState() => _FavTopicPageState();
}

class _FavTopicPageState extends State<FavTopicPage>
    with AutomaticKeepAliveClientMixin {
  final FavTopicController _controller = appRead(favTopicControllerProvider);

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
              left: Style.safeSpace,
              right: Style.safeSpace,
              top: Style.safeSpace,
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

  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    maxCrossAxisExtent: Grid.smallCardWidth,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(30),
  );

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<CoreFavTopicItem>?> loadingState,
  ) {
    return switch (loadingState) {
      Loading() => const SliverToBoxAdapter(
        child: SizedBox(
          height: 125,
          child: m3eLoading,
        ),
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  final item = response[index];

                  void onLongPress() => showConfirmDialog(
                    context: context,
                    title: const Text('确定取消收藏？'),
                    onConfirm: () => _controller.onDeleteTopic(index, item.id!),
                  );

                  return Material(
                    color: theme.colorScheme.onInverseSurface,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    child: InkWell(
                      onTap: () => AppNavigator.toNamed(
                        '/dynTopic',
                        parameters: {
                          'id': item.id!.toString(),
                          'name': item.name!,
                        },
                      ),
                      onLongPress: onLongPress,
                      onSecondaryTap: PlatformUtils.isMobile
                          ? null
                          : onLongPress,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6),
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        child: Text(
                          '# ${item.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
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
