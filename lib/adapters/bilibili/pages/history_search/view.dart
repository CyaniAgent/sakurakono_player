import 'package:skf/core/models/user_types.dart';

import 'package:skf/pages/common/search/common_search_page.dart';
import 'package:skf/adapters/bilibili/utils/history_actions.dart';
import 'package:skf/pages/history/widgets/item.dart';
import 'package:skf/adapters/bilibili/pages/history_search/controller.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart';

class HistorySearchPage extends StatefulWidget {
  const HistorySearchPage({super.key});

  @override
  State<HistorySearchPage> createState() => _HistorySearchPageState();
}

class _HistorySearchPageState
    extends
        CommonSearchPageState<HistorySearchPage, CoreHistoryData, CoreHistoryItemModel>
    with GridMixin {
  @override
  final HistorySearchController controller = HistorySearchController();

  @override
  Widget buildList(List<CoreHistoryItemModel> list) {
    return SliverGrid.builder(
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        if (index == list.length - 1) {
          controller.onLoadMore();
        }
        final item = list[index];
        return HistoryItem(
          item: item,
          actions: biliHistoryActions,
          ctr: controller,
          onDelete: (kid, business) =>
              controller.onDelHistory(index, kid, business),
        );
      },
      itemCount: list.length,
    );
  }
}
