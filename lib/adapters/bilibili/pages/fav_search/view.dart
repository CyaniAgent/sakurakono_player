import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/common/search/common_search_page.dart';
import 'package:skf/adapters/bilibili/pages/fav_detail/widget/fav_video_card.dart';
import 'package:skf/adapters/bilibili/pages/fav_search/controller.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/grid.dart';
import 'package:skf/adapters/bilibili/utils/request_utils.dart';
import 'package:flutter/material.dart';

class FavSearchPage extends StatefulWidget {
  const FavSearchPage({super.key});

  @override
  State<FavSearchPage> createState() => _FavSearchPageState();
}

class _FavSearchPageState
    extends
        CommonSearchPageState<FavSearchPage, CoreFavDetailData, CoreFavDetailItemModel>
    with GridMixin {
  @override
  final FavSearchController controller = FavSearchController();

  @override
  List<Widget>? get multiSelectActions {
    final btnStyle = TextButton.styleFrom(visualDensity: .compact);
    final textStyle = TextStyle(
      color: ColorScheme.of(context).onSurfaceVariant,
    );
    return [
      TextButton(
        style: btnStyle,
        onPressed: () => RequestUtils.onCopyOrMove<CoreFavDetailItemModel>(
          context: context,
          isCopy: true,
          ctr: controller,
          mediaId: controller.mediaId,
          mid: Accounts.main.mid,
        ),
        child: Text('复制', style: textStyle),
      ),
      TextButton(
        style: btnStyle,
        onPressed: () => RequestUtils.onCopyOrMove<CoreFavDetailItemModel>(
          context: context,
          isCopy: false,
          ctr: controller,
          mediaId: controller.mediaId,
          mid: Accounts.main.mid,
        ),
        child: Text('移动', style: textStyle),
      ),
    ];
  }

  @override
  List<Widget>? get extraActions => [
    ListenableBuilder(
      listenable: controller,
      builder: (_, _) {
        return PopupMenuButton<CoreFavOrderType>(
          icon: const Icon(Icons.sort),
          requestFocus: false,
          initialValue: controller.order,
          tooltip: '排序方式',
          onSelected: (value) => controller
            ..order = value
            ..onReload(),
          itemBuilder: (context) => CoreFavOrderType.values
              .map(
                (e) => PopupMenuItem(
                  value: e,
                  child: Text(e.label),
                ),
              )
              .toList(),
        );
      },
    ),
  ];

  @override
  Widget buildList(List<CoreFavDetailItemModel> list) {
    return SliverGrid.builder(
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        if (index == list.length - 1) {
          controller.onLoadMore();
        }
        final item = list[index];
        return FavVideoCardH(
          item: item,
          index: index,
          ctr: controller,
        );
      },
      itemCount: list.length,
    );
  }
}
